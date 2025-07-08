import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';

class SongItemWidget extends StatelessWidget {
  // final ValueChanged<int> onTap; // callback nhận 1 int
  //  final int songId;
  final void Function(BuildContext) onTap; // Gọi về parent
  final VoidCallback onTrailing; // Gọi về parent
  final Song song;

  const SongItemWidget({
    super.key,
    required this.onTap,
    required this.song,
    required this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 24, right: 8),
      // tileColor: Colors.blue.shade50,       // màu nền khi bình thường
      selectedTileColor: Colors.lightBlueAccent,
      // màu khi selected = true
      leading: ClipRRect(
        // Bo tròn hình ảnh
        borderRadius: BorderRadius.circular(100),
        child: FadeInImage.assetNetwork(
          placeholder: "assets/music.png",
          // Hình ảnh tạm thời khi đang tải
          image: song.image,
          // tôi muốn bo tròn hình ảnh
          width: 50,
          height: 50,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/music.png", width: 50, height: 50);
          },
        ),
      ),
      title: Text(song.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: Color.fromRGBO(110, 102, 1, 1.0)),
      ),
      trailing: IconButton(icon: Icon(Icons.more_horiz), onPressed: () {
        onTrailing(); // Gọi callback về parent
      }),
      onTap: () {
        onTap(context); // Gọi callback về parent
      },
    );
  }
}
