import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../services/team_service.dart';

/// Team/clan screen (Workstream 5: Social). Local-only for now.
///
/// NOTE: server sync via Supabase comes later; local-only for now.
///
/// Parent wiring: push via
///   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamScreen()));
///
/// String keys used (parent merges into strings.dart):
///   'team', 'teamName', 'teamNameHint', 'createTeam', 'joinTeam',
///   'teamNameInvalid', 'teamWins', 'emptyBoard', 'typeMessage', 'send',
///   'leaveTeam', 'leaveTeamConfirm', 'confirm'
/// Reuses existing key: 'cancel' (already in strings.dart).
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _joinMode = false;

  @override
  void initState() {
    super.initState();
    // Ensure persisted state is loaded (no-op if already loaded).
    TeamService.instance.init();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitName(S s) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final ok = _joinMode
        ? await TeamService.instance.joinTeam(name)
        : await TeamService.instance.createTeam(name);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.get('teamNameInvalid'))),
      );
    }
    _nameController.clear();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    // Player display name: reuse the first 12 chars of the team name as a
    // fallback author label; the name-entry workstream owns the real profile.
    final author = (TeamService.instance.teamName ?? '?');
    await TeamService.instance.postMessage(author, text);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmLeave(S s) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.get('leaveTeam')),
        content: Text(s.get('leaveTeamConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.get('confirm')),
          ),
        ],
      ),
    );
    if (leave == true) {
      await TeamService.instance.leaveTeam();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final scheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: TeamService.instance,
      child: Consumer<TeamService>(
        builder: (context, team, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(s.get('team')),
              actions: [
                if (team.inTeam)
                  IconButton(
                    tooltip: s.get('leaveTeam'),
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => _confirmLeave(s),
                  ),
              ],
            ),
            body: team.inTeam ? _buildBoard(context, s, scheme, team) : _buildJoinCreate(context, s, scheme),
          );
        },
      ),
    );
  }

  /// Create / join form shown when the player is not in a team.
  Widget _buildJoinCreate(BuildContext context, S s, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.groups, size: 72, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            s.get('team'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            maxLength: 24,
            decoration: InputDecoration(
              labelText: s.get('teamName'),
              hintText: s.get('teamNameHint'),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitName(s),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _submitName(s),
            child: Text(s.get(_joinMode ? 'joinTeam' : 'createTeam')),
          ),
          TextButton(
            onPressed: () => setState(() => _joinMode = !_joinMode),
            child: Text(s.get(_joinMode ? 'createTeam' : 'joinTeam')),
          ),
        ],
      ),
    );
  }

  /// Team board: header (name + wins), message list, input field + send.
  Widget _buildBoard(BuildContext context, S s, ColorScheme scheme, TeamService team) {
    return Column(
      children: [
        // Team header: name + total wins.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.teamName ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 18, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    '${s.get('teamWins')}: ${team.teamWins}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Message board.
        Expanded(
          child: team.messages.isEmpty
              ? Center(
                  child: Text(
                    s.get('emptyBoard'),
                    style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55)),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: team.messages.length,
                  itemBuilder: (ctx, i) {
                    final m = team.messages[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(m.name.isEmpty ? '?' : m.name[0].toUpperCase()),
                        ),
                        title: Text(m.name,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(m.text),
                      ),
                    );
                  },
                ),
        ),
        // Input field + send button.
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: s.get('typeMessage'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: s.get('send'),
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
