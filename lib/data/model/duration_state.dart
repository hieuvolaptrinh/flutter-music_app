

/// Model giữ 3 mốc thời gian để UI vẽ progress bar:
/// - [progress]: thời gian đã phát đến đâu
/// - [buffered]: đã nạp trước đến đâu
/// - [total]: tổng độ dài của track
class DurationState {
  final Duration progress; // e.g. đang ở 00:01:15
  final Duration buffered; // e.g. đã buffer đến 00:02:00
  final Duration? total; // e.g. tổng dài 00:03:30 (nullable nếu chưa biết)

  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
}

