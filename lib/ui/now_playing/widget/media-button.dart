import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/viewmodel/audio_play_manager.dart';
import 'package:music_app/ui/now_playing/playing.dart';

class MediaControl extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;

  const MediaControl({super.key, required this.audioPlayerManager});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MediaButtonControl(
          function: () => audioPlayerManager.shuffle(),
          icon: Icons.shuffle,
          color: audioPlayerManager.getShuffleColor(),
          size: 24,
        ),
        MediaButtonControl(
          function: () => audioPlayerManager.skipPrevious(),
          icon: Icons.skip_previous,
          color: Colors.deepPurple,
          size: 36,
        ),
        PlayButton(audioPlayerManager: audioPlayerManager, size: 48),
        MediaButtonControl(
          function: () => audioPlayerManager.skipNext(),
          icon: Icons.skip_next,
          color: Colors.deepPurple,
          size: 36,
        ),
        MediaButtonControl(
          function: () => audioPlayerManager.repeat(),
          icon: audioPlayerManager.repeatingIcon(),
          color: audioPlayerManager.getRepeatingIconColor(),
          size: 24,
        ),
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final double size;

  const PlayButton({
    super.key,
    required this.audioPlayerManager,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing == true;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          );
        } else if (!playing) {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.play();
              // Khi nhấn play: Tiếp tục animation từ vị trí hiện tại và lặp lại
              audioPlayerManager.imageAnimationController?.forward(
                from: audioPlayerManager.currentAnimationPosition ?? 0.0,
              );
              audioPlayerManager.imageAnimationController?.repeat();
            },
            icon: Icons.play_arrow,
            size: size,
            color: null,
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.pause();
              // Khi nhấn pause: Dừng animation và lưu vị trí hiện tại
              audioPlayerManager.imageAnimationController?.stop();
              audioPlayerManager.setCurrentAnimationPosition(
                audioPlayerManager.imageAnimationController?.value ?? 0.0,
              );
            },
            icon: Icons.pause,
            size: size,
            color: null,
          );
        } else {
          if (processingState == ProcessingState.completed) {
            // Nếu đã hoàn thành phát=> dừng quay
            // audioPlayerManager.imageAnimationController?.stop();

          }
          return MediaButtonControl(

            function: () {
              audioPlayerManager.player.seek(Duration.zero);
              // Khi nhấn replay: Reset và quay lại từ đầu
              audioPlayerManager.imageAnimationController?.reset();
              audioPlayerManager.imageAnimationController?.repeat();
            },
            icon: Icons.replay,
            size: size,
            color: null,
          );
        }
      },
    );
  }
}
