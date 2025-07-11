import 'package:flutter/material.dart';

import 'package:music_app/data/model/song.dart';
import 'package:music_app/viewmodel/audio_play_manager.dart';
import 'package:music_app/ui/now_playing/widget/media-button.dart';
import 'package:music_app/ui/now_playing/widget/progerss-bar.dart';
import 'package:provider/provider.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  late AudioPlayerManager audioPlayerManager;

  @override
  void initState() {
    super.initState();
    audioPlayerManager = AudioPlayerManager(
      widget.songs.indexOf(widget.playingSong),
      widget.songs,
    )..init();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //= Sử dụng PopScope để đảm bảo dispose được gọi khi thoát
    return PopScope(
      onPopInvoked: (didPop) {
        // Đảm bảo dispose được gọi khi người dùng thoát
        if (didPop) {
          audioPlayerManager.dispose();
        }
      },
      child: ChangeNotifierProvider.value(
        value: audioPlayerManager,
        child: NowPlayingPage(),
      ),
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Sửa: Khởi tạo AnimationController trong AudioPlayerManager
    final audioPlayerManager = Provider.of<AudioPlayerManager>(
      context,
      listen: false,
    );
    audioPlayerManager.initAnimationController(this); // Truyền vsync từ widget
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return Consumer<AudioPlayerManager>(
      builder: (context, audioPlayerManager, child) {
        final currentSong = audioPlayerManager.currentSong;
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 10,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Now Playing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
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
                  Text(
                    "${currentSong.album} ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text("~~~~~~~~~~~~~~~~~~~~~~~~~~"),
                  SizedBox(height: 20),
                  RotationTransition(
                    turns: Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(audioPlayerManager.imageAnimationController!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/music.png",
                        image: currentSong.image,
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
                              currentSong.title,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                                  ),
                            ),
                            Text(
                              currentSong.artist,
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
                    child: ProgressBarWidget(
                      audioPlayerManager: audioPlayerManager,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                      left: 24,
                      right: 24,
                      bottom: 8,
                    ),
                    child: MediaControl(audioPlayerManager: audioPlayerManager),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
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
