import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/data/repository/song_repository.dart';


// cách 1: Sử dụng ChangeNotifier sử dụng provider để quản lý trạng thái
class MusicAppViewModel extends ChangeNotifier {
  final _repository = DefaultRepository();

  List<Song> _songs = [];
  bool _isLoading = false;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners(); // gửi tính hiệu đến UI để cập nhật trạng thái

    final data = await _repository.loadData();
    _songs = data ?? [];

    _isLoading = false;
    notifyListeners();
  }
}


//
// class MusicAppViewModel {
//   StreamController<List<Song>> songStream = StreamController();
//
//   void loadSongs() async {
//     final repository = DefaultRepository();
//     try {
//       final data = await repository.loadData();
//       songStream.add(data!);
//     } catch (e) {
//       songStream.addError('Lỗi khi tải dữ liệu: $e');
//     }
//   }
// }
