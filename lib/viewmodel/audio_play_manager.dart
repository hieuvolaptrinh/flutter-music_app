import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:music_app/data/model/song.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager extends ChangeNotifier {
  final player = AudioPlayer();

  AnimationController? _imageAnimationController;
  double _currentAnimationPosition = 0.0;
  bool _isDisposed = false; // Flag để tránh dispose nhiều lần

  Stream<DurationState>? durationState;
  final List<Song> songs;
  int _selectedIndexItem;

  AudioPlayerManager(this._selectedIndexItem, this.songs);

  // Getter để truy cập từ bên ngoài
  int get selectedIndexItem => _selectedIndexItem;

  Song get currentSong => songs[_selectedIndexItem];

  AnimationController? get imageAnimationController =>
      _imageAnimationController;

  double get currentAnimationPosition => _currentAnimationPosition;

  // Setter để cập nhật vị trí animation
  void setCurrentAnimationPosition(double value) {
    _currentAnimationPosition = value;
    notifyListeners(); // Thông báo để widget lắng nghe cập nhật
  }

  void initAnimationController(TickerProvider vsync) {
    _imageAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 12000),
    );
  }

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) {
        return DurationState(
          progress: position,
          buffered: playbackEvent.bufferedPosition,
          total: playbackEvent.duration,
        );
      },
    );
    player.setUrl(songs[_selectedIndexItem].source);
  }

  void togglePlayPause() {
    final proc = player.playbackEvent.processingState;
    if (proc == ProcessingState.loading || proc == ProcessingState.buffering) {
      return;
    }
    if (proc == ProcessingState.completed) {
      player.seek(Duration.zero);
      _imageAnimationController?.reset(); // Reset animation khi replay
      _imageAnimationController?.repeat();
    } else if (player.playing) {
      player.pause();
      _imageAnimationController?.stop(); // Dừng animation khi pause
      setCurrentAnimationPosition(
        _imageAnimationController?.value ?? 0.0,
      ); // Lưu vị trí animation
    } else {
      player.play();
      _imageAnimationController?.forward(
        from: _currentAnimationPosition,
      ); // Tiếp tục từ vị trí đã lưu
      _imageAnimationController?.repeat();
    }
    notifyListeners();
  }

  void skipNext() {
    if (_selectedIndexItem < songs.length - 1) {
      _selectedIndexItem++;
      _imageAnimationController?.reset(); // Reset animation ngay
      // Set URL và chờ nhạc load
      player.setUrl(songs[_selectedIndexItem].source);        // Sau khi set URL xong, play nhạc
        player.play();

      _imageAnimationController?.repeat();
      notifyListeners();
    }
  }

  void skipPrevious() {
    if (_selectedIndexItem > 0) {
      _selectedIndexItem--;
      player.setUrl(songs[_selectedIndexItem].source);
      player.play();
      _imageAnimationController?.reset(); // Reset animation cho bài mới
      _imageAnimationController?.repeat();
      notifyListeners();
    }
  }

  void shuffle() {
    // TODO: Triển khai shuffle
    notifyListeners();
  }

  void repeat() {
    // TODO: Triển khai repeat
    notifyListeners();
  }

  @override
  void dispose() {
    // Kiểm tra xem đã dispose chưa để tránh dispose nhiều lần
    if (_isDisposed) return;
    _isDisposed = true;

    // Dừng phát nhạc ngay lập tức
    try {
      player.stop();
      player.dispose();
    } catch (e) {
      // Nếu có lỗi, vẫn cố gắng dispose
      try {
        player.dispose();
      } catch (_) {}
    }
    _imageAnimationController?.dispose();
    super.dispose();
  }
}
