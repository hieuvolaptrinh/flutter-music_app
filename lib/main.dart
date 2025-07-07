import "package:flutter/material.dart";
import "package:music_app/data/model/song.dart";
import "package:music_app/data/repository/repository.dart";

void main() async {
  var repository = DefaultRepository();
  var songs = await repository.loadData();

  if (songs != null) {
    for (var song in songs) {
      debugPrint(song.toString());
    }
  }
}

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
