/// Stub: notifications disabled in the clean build. Same public API, no plugin.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {}
  Future<bool> requestPermission() async => false;
  Future<void> scheduleDaily() async {}
  Future<void> cancelDaily() async {}
  bool get isEnabled => false;
  String get timeLabel => '';
}
