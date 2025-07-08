import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:music_app/data/model/song.dart';

import 'package:music_app/data/source/remote.dart';

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String response= await rootBundle.loadString("assets/songs.json");

    final jsonBody = jsonDecode(response) as Map;
    final songList = jsonBody['songs'] as List;
    List<Song> songs = songList.map((songJson) {
      return Song.fromJson(songJson as Map<String, dynamic>);
    }).toList();

    return songs;
  }
}
