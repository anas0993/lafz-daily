/// Standard Wordle guess evaluation, including correct duplicate-letter
/// handling (two-pass algorithm).
enum LetterState { unknown, absent, present, correct }

List<LetterState> evaluateGuess(List<String> guess, List<String> answer) {
  assert(guess.length == answer.length);
  final n = guess.length;
  final result = List<LetterState>.filled(n, LetterState.absent);
  final remaining = <String, int>{};

  // Pass 1: mark correct letters, count the rest of the answer's letters.
  for (var i = 0; i < n; i++) {
    if (guess[i] == answer[i]) {
      result[i] = LetterState.correct;
    } else {
      remaining[answer[i]] = (remaining[answer[i]] ?? 0) + 1;
    }
  }
  // Pass 2: mark present letters, consuming from the remaining pool so
  // duplicates are never over-counted.
  for (var i = 0; i < n; i++) {
    if (result[i] == LetterState.correct) continue;
    final count = remaining[guess[i]] ?? 0;
    if (count > 0) {
      result[i] = LetterState.present;
      remaining[guess[i]] = count - 1;
    }
  }
  return result;
}

/// Merges a letter's new state into the keyboard map, keeping the best
/// state seen so far (correct > present > absent > unknown).
int _rank(LetterState s) => switch (s) {
      LetterState.correct => 3,
      LetterState.present => 2,
      LetterState.absent => 1,
      LetterState.unknown => 0,
    };

LetterState mergeState(LetterState oldS, LetterState newS) =>
    _rank(newS) > _rank(oldS) ? newS : oldS;
