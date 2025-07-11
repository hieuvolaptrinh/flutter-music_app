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
  final List<Song> songs;
  int selectedIndexItem;

  bool isShuffle = false; // để trộn bài hát

  AudioPlayerManager(this.selectedIndexItem, this.songs);

  Song get currentSong => songs[selectedIndexItem];

  // Setter để cập nhật vị trí animation
  void setCurrentAnimationPosition(double value) {
    currentAnimationPosition = value;
    notifyListeners(); // Thông báo để widget lắng nghe cập nhật
  }

  void initAnimationController(TickerProvider vsync) {
    imageAnimationController = AnimationController(
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
    player.setUrl(songs[selectedIndexItem].source);
  }

  void togglePlayPause() {
    final proc = player.playbackEvent.processingState;
    if (proc == ProcessingState.loading || proc == ProcessingState.buffering) {
      return;
    }
    if (proc == ProcessingState.completed) {
      player.seek(Duration.zero);
      imageAnimationController?.reset(); // Reset animation khi replay
      imageAnimationController?.repeat();
    } else if (player.playing) {
      player.pause();
      imageAnimationController?.stop(); // Dừng animation khi pause
      setCurrentAnimationPosition(
        imageAnimationController?.value ?? 0.0,
      ); // Lưu vị trí animation
    } else {
      player.play();
      imageAnimationController?.forward(
        from: currentAnimationPosition,
      ); // Tiếp tục từ vị trí đã lưu
      imageAnimationController?.repeat();
    }
    notifyListeners();
  }

  void skipNext() {
    if (selectedIndexItem < songs.length - 1) {
      if (isShuffle) {
        var random = Random();
        selectedIndexItem = random.nextInt(songs.length - 1);
      } else {
        selectedIndexItem++;
      }
    } else {
      selectedIndexItem = 0;
    }
    imageAnimationController?.reset(); // Reset animation ngay
    // Set URL và chờ nhạc load
    player.setUrl(
      songs[selectedIndexItem].source,
    ); // Sau khi set URL xong, play nhạc
    player.play();

    imageAnimationController?.repeat();
    notifyListeners();
  }

  void skipPrevious() {
    if (selectedIndexItem > 0) {
      if (isShuffle) {
        var random = Random();
        selectedIndexItem = random.nextInt(songs.length - 1);
      } else {
        selectedIndexItem--;
      }
    } else {
      selectedIndexItem = songs.length - 1;
    }
    player.setUrl(songs[selectedIndexItem].source);
    player.play();
    imageAnimationController?.reset(); // Reset animation cho bài mới
    imageAnimationController?.repeat();
    notifyListeners();
  }

  Color? getShuffleColor() {
    return isShuffle
        ? Colors.deepPurple
        : Colors.grey; // Trả về màu xanh nếu đang shuffle
  }

  void shuffle() {
    isShuffle = !isShuffle;

    notifyListeners();
  }

  void repeat() {
    // TODO: Triển khai repeat
    notifyListeners();
  }

  @override
  void dispose() {
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
    imageAnimationController?.dispose();
    super.dispose();
  }
}
