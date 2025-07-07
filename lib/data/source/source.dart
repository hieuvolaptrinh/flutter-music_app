import 'dart:convert';

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
        final jsonData = jsonDecode(bodyContent) as Map<String, dynamic>;
        final songList = jsonData['songs'] as List;

        List<Song> songs = songList.map((songJson) {
          return Song.fromJson(songJson as Map<String, dynamic>);
        }).toList();

        return songs;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error loading remote data: $error");
      return null;
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // TODO: implement loadData
    return null;
  }
}
