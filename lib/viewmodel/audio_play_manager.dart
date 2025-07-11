import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:music_app/data/model/song.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager extends ChangeNotifier {
  final player = AudioPlayer();
  AnimationController? imageAnimationController;
  double currentAnimationPosition = 0.0;
  Stream<DurationState>? durationState;

  // Sử dụng late để khởi tạo sau
  late List<Song> songs;
  late int selectedIndexItem;

  bool isShuffle = false;
  late LoopMode loopMode;

  // Thêm flag để kiểm tra đã khởi tạo chưa
  bool _isInitialized = false;

  AudioPlayerManager(this.selectedIndexItem, this.songs) {
    _initializePlayer();
  }

  // Getter an toàn
  Song get currentSong =>
      songs.isNotEmpty ? songs[selectedIndexItem] : Song.empty();

  bool get isInitialized => _isInitialized;

  // **THÊM METHOD MỚI**: Cập nhật danh sách bài hát và bài đang chọn
  void updateSongs(List<Song> newSongs, int newSelectedIndex) {
    songs = newSongs;
    selectedIndexItem = newSelectedIndex;
    _isInitialized = true;

    // Khởi tạo player với bài hát mới
    player.setUrl(songs[selectedIndexItem].source);
    notifyListeners();
  }

  void _initializePlayer() {
    loopMode = LoopMode.off;

    // Khởi tạo durationState
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
  }

  void initAnimationController(TickerProvider vsync) {
    // ✅ Dispose animation controller cũ nếu có
    if (imageAnimationController != null) {
      imageAnimationController!.dispose();
    }

    imageAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 12000),
    );

    // ✅ Reset animation position khi tạo controller mới
    currentAnimationPosition = 0.0;
  }

  void setCurrentAnimationPosition(double value) {
    currentAnimationPosition = value;
    notifyListeners();
  }

  void togglePlayPause() {
    if (!_isInitialized || songs.isEmpty) return;

    final proc = player.playbackEvent.processingState;
    if (proc == ProcessingState.loading || proc == ProcessingState.buffering) {
      return;
    }
    if (proc == ProcessingState.completed) {
      player.seek(Duration.zero);
      imageAnimationController?.reset();
      imageAnimationController?.repeat();
    } else if (player.playing) {
      player.pause();
      imageAnimationController?.stop();
      setCurrentAnimationPosition(imageAnimationController?.value ?? 0.0);
    } else {
      player.play();
      imageAnimationController?.forward(from: currentAnimationPosition);
      imageAnimationController?.repeat();
    }
    notifyListeners();
  }

  void skipNext() {
    if (!_isInitialized || songs.isEmpty) return;

    if (isShuffle) {
      var random = Random();
      selectedIndexItem = random.nextInt(songs.length);
    } else if (loopMode == LoopMode.all &&
        selectedIndexItem == songs.length - 1) {
      selectedIndexItem = 0;
    } else if (selectedIndexItem < songs.length - 1) {
      selectedIndexItem++;
    } else {
      selectedIndexItem = 0;
    }

    imageAnimationController?.reset();
    player.setUrl(songs[selectedIndexItem].source);
    player.play();
    imageAnimationController?.repeat();
    notifyListeners();
  }

  void skipPrevious() {
    if (!_isInitialized || songs.isEmpty) return;

    if (isShuffle) {
      var random = Random();
      selectedIndexItem = random.nextInt(songs.length);
    } else if (loopMode == LoopMode.all && selectedIndexItem == 0) {
      selectedIndexItem = songs.length - 1;
    } else if (selectedIndexItem > 0) {
      selectedIndexItem--;
    } else {
      selectedIndexItem = songs.length - 1;
    }

    player.setUrl(songs[selectedIndexItem].source);
    player.play();
    imageAnimationController?.reset();
    imageAnimationController?.repeat();
    notifyListeners();
  }

  // Các method khác giữ nguyên...
  Color? getShuffleColor() {
    return isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void shuffle() {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  Color? getRepeatingIconColor() {
    return switch (loopMode) {
      LoopMode.one => Colors.deepPurple,
      LoopMode.all => Colors.deepPurple,
      _ => Colors.grey,
    };
  }

  IconData repeatingIcon() {
    return switch (loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  void repeat() {
    if (loopMode == LoopMode.off) {
      loopMode = LoopMode.one;
    } else if (loopMode == LoopMode.one) {
      loopMode = LoopMode.all;
    } else {
      loopMode = LoopMode.off;
    }
    player.setLoopMode(loopMode);
    notifyListeners();
  }

  @override
  void dispose() {
    if (imageAnimationController != null) {
      imageAnimationController!.stop();
      imageAnimationController!.dispose();
      imageAnimationController = null;
    }

    player.stop();
    player.dispose();
    super.dispose();
  }
}
