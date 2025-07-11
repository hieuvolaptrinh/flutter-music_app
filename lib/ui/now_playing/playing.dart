import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/now_playing/audio_play_manager.dart';
import 'package:music_app/ui/now_playing/widget/media-button.dart';
import 'package:music_app/ui/now_playing/widget/progess-bar.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  final Song playingSong;
  final List<Song> songs;

  const NowPlayingPage({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(widget.playingSong.source);
    _audioPlayerManager.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(
      context,
    ).size.width; // Lấy chiều rộng của màn hình

    const delta = 64;
    // bán kính cong
    final radius = (screenWidth - delta) / 2; // Tính bán kính cong dựa trên

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          // Nút back bên trái
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          // Tiêu đề ở giữa
          title: Text(
            'Now Playing',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // Icon ba chấm + badge đỏ số 1
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //  widget. để lấy biến từidget cha
              Text(
                "${widget.playingSong.album} ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text("~~~~~~~~~~~~~~~~~~~~~~~~~~"),
              SizedBox(height: 20),
              // để xoay hình ảnh
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_imageAnimationController),

                // hình ảnh của bài hát
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: "assets/music.png",
                    image: widget.playingSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/music.png",
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          widget.playingSong.title,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                              ),
                        ),

                        Text(
                          widget.playingSong.artist,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite),
                      color: Theme.of(context).colorScheme.surfaceDim,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 12,
                  left: 24,
                  right: 24,
                  bottom: 12,
                ),
                child: ProgressBarWidget(audioPlayerManager: _audioPlayerManager),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  left: 24,
                  right: 24,
                  bottom: 8,
                ),
                child: MediaControl(audioPlayerManager: _audioPlayerManager),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayerManager
        .dispose(); // Giải phóng tài nguyên của AudioPlayerManager=> nghĩa là hủy bỏ việc bài hát đang phát nếu thoát màn hình
    super.dispose();
  }

  // thanh tiến độ phát nhạc
 

  // sự kiện khi nhấn nút play
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        // trạng thái hiện tại của nút play
        final playState = snapshot.data;
        final progressingState = playState?.playing;
        final playing = playState?.playing;

        // nếu đang load hoặc đang tải dữ liệu
        if (progressingState == ProcessingState.loading ||
            progressingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8),
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          );
        }
        // nếu ko phải đang phát
        else if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play(); // gọi hàm play của AudioPlayer
            },
            icon: Icons.play_arrow,
            color: null,
            size: 48,
          );
        }
        // nếu chưa phát hết
        else if (progressingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player
                  .pause(); // gọi hàm pause của AudioPlayer
            },
            icon: Icons.pause,
            color: null,
            size: 48,
          );
        }
        // nếu
        else {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(
                Duration.zero,
              ); // gọi hàm seek để quay lại đầu bài hát
            },
            icon: Icons.replay,
            color: null,
            size: 48,
          );
        }
      },
    );
  }
}

class MediaButtonControl extends StatefulWidget {
  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
