import 'package:music_app/data/model/song.dart';
import 'package:music_app/data/source/source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    try {
      // Thử load từ remote trước
      final remoteSongs = await _remoteDataSource.loadData();
      if (remoteSongs != null && remoteSongs.isNotEmpty) {
        return remoteSongs;
      }

      // Nếu remote không có dữ liệu, thử load từ local
      final localSongs = await _localDataSource.loadData();
      return localSongs;
    } catch (error) {
      print("Error loading data: $error");
      return null;
    }
  }
}
