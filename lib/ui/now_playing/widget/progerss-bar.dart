import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:music_app/viewmodel/audio_play_manager.dart';

class ProgressBarWidget extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager ;
  const ProgressBarWidget({super.key, required this.audioPlayerManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DurationState>(
      stream: audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: audioPlayerManager.player.seek,
          // sự kiện khi người dùng kéo thanh tiến độ
          barHeight: 5,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.lightBlue.withOpacity(0.6),
          progressBarColor: Colors.indigo,
          bufferedBarColor: Colors.lightBlue,
          thumbColor: Colors.indigoAccent,
          thumbGlowColor: Colors.orange,
          thumbRadius: 10,
        );
      },
    );
  }
}
