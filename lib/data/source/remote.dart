import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:music_app/data/model/song.dart';
import "package:http/http.dart" as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    try {
      const url = "https://thantrieu.com/resources/braniumapis/songs.json";
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(bodyContent) as Map<String, dynamic>;
        var songList = jsonData['songs'] as List;

        List<Song> songs = songList.map((songJson) {
          return Song.fromJson(songJson as Map<String, dynamic>);
        }).toList();

        return songs;
      } else {
        return null;
      }
    } catch (error) {

      return null;
    }
  }
}

