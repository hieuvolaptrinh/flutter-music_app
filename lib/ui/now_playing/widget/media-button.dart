import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/viewmodel/audio_play_manager.dart';
import 'package:music_app/ui/now_playing/playing.dart';

class MediaControl extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;

  //
  // final VoidCallback? onShuffle; // trộn bài
  // final VoidCallback? onPrevious; // bài trước
  // final bool isPlaying; // trạng thái đang phát hay không
  // final VoidCallback onPlayPause; // phát hoặc tạm dừng
  // final VoidCallback? onNext; // bài tiếp theo
  // final VoidCallback? onRepeat; // lặp lại bài

  const MediaControl({
    super.key,
    // this.onShuffle,
    // this.onPrevious,
    // required this.isPlaying,
    // required this.onPlayPause,
    // this.onNext,
    // this.onRepeat,
    required this.audioPlayerManager,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Nút trộn bài
        MediaButtonControl(
          function: ()=> audioPlayerManager.shuffle(),
          icon: Icons.shuffle,
          color: Colors.deepPurple,
          size: 24,
        ),
        // Nút bài trước
        MediaButtonControl(
          function: () {
            audioPlayerManager.skipPrevious();
          },
          icon: Icons.skip_previous,
          color: Colors.deepPurple,
          size: 36,
        ),
        // Nút phát/tạm dừng
        PlayButton(audioPlayerManager: audioPlayerManager, size: 48),
        // Nút bài tiếp theo
        MediaButtonControl(
          function: () {
            audioPlayerManager.skipNext();
          },
          icon: Icons.skip_next,
          color: Colors.deepPurple,
          size: 36,
        ),
        // Nút lặp lại bài
        MediaButtonControl(
          function: ()=>audioPlayerManager.repeat(),
          icon: Icons.repeat,
          color: Colors.deepPurple,
          size: 24,
        ),
      ],
    );
  }
}

/// PlayButton widget: tùy theo trạng thái của audio player, hiển thị
/// nút loading, play, pause hoặc replay.
class PlayButton extends StatelessWidget {
  // Đối tượng quản lý audio, chứa instance của just_audio AudioPlayer
  final AudioPlayerManager audioPlayerManager;
  final double size;

  const PlayButton({
    Key? key,
    required this.audioPlayerManager,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // StreamBuilder sẽ lắng nghe playerStateStream và rebuild khi state thay đổi
    return StreamBuilder<PlayerState>(
      stream: audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        // Lấy trạng thái hiện tại của player (có thể null nếu chưa có dữ liệu)
        final playerState = snapshot.data;
        // processingState có thể là loading, buffering, ready, completed, ...
        final processingState = playerState?.processingState;
        // playing == true khi audio đang phát, false khi paused hoặc chưa load
        final playing = playerState?.playing == true;

        // 1. Nếu đang loading hoặc buffering, show indicator
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          );
        }
        // 2. Nếu chưa play (paused hoặc chưa bắt đầu), show nút Play
        else if (!playing) {
          return MediaButtonControl(
            function: () => audioPlayerManager.player.play(),
            icon: Icons.play_arrow,
            size: size,
            color: null, // sử dụng màu mặc định của MediaButtonControl
          );
        }
        // 3. Nếu đang phát (playing) và chưa kết thúc, show nút Pause
        else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () => audioPlayerManager.player.pause(),
            icon: Icons.pause,
            size: size,
            color: null,
          );
        }
        // 4. Nếu bài đã kết thúc (completed), show nút Replay
        else {
          return MediaButtonControl(
            function: () => audioPlayerManager.player.seek(Duration.zero),
            icon: Icons.replay,
            size: size,
            color: null,
          );
        }
      },
    );
  }
}
