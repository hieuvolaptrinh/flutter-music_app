import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:music_app/data/model/song.dart';
import 'package:rxdart/rxdart.dart';

//đáng lý ra là các sự kiện các nút sẽ viết ở đây, sau đó các nút sẽ gọi callback ở đây
class AudioPlayerManager extends ChangeNotifier {
  // 1. Tạo một instance của AudioPlayer từ thư viện just_audio
  final player = AudioPlayer();

  Stream<DurationState>? durationState;

  final List<Song> songs;
  int _selectedIndexItem;

  // final ValueNotifier<int> selectedIndexItem; // Cách 1:nếu dùng ValueNotifier để có thể cập nhật giao diện khi thay đổi

  AudioPlayerManager(this._selectedIndexItem, this.songs);

  // getter/setter
  int get selectedIndexItem => _selectedIndexItem;

  Song get currentSong => songs[_selectedIndexItem];

  // 5.ức init() dùng để thiết lập stream durationState bằng cách
  //    kết hợp hai stream có sẵn của player: positionStream và playbackEventStream
  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      // a) player.positionStream phát ra Duration – vị trí (position) hiện tại
      player.positionStream,
      // b) player.playbackEventStream phát ra PlaybackEvent – chứa bufferedPosition, duration, vv.
      player.playbackEventStream,
      // c) lambda để "kết hợp" hai giá trị trên thành một DurationState
      (position, playbackEvent) {
        return DurationState(
          progress: position,
          buffered: playbackEvent.bufferedPosition,
          total: playbackEvent.duration,
        );
      },
    );
    player.setUrl(songs[_selectedIndexItem].source);
    // player.setUrl(songs[selectedIndexItem.value].source); //Cách 1
  }

  /// Toggle play/pause hoặc replay nếu đã hoàn thành
  void togglePlayPause() {
    final proc = player.playbackEvent.processingState;
    if (proc == ProcessingState.loading || proc == ProcessingState.buffering) {
      // có thể hiện loading, không thay đổi
      return;
    }
    if (proc == ProcessingState.completed) {
      player.seek(Duration.zero);
    } else if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    notifyListeners(); // Thông báo để cập nhật giao diện
  }

  void skipNext() {
    if (_selectedIndexItem < songs.length - 1) {
      _selectedIndexItem++;
      player.setUrl(songs[_selectedIndexItem].source);
      player.play();
      notifyListeners(); // Thông báo để cập nhật giao diện
    }
  }

  void skipPrevious() {
    if (_selectedIndexItem > 0) {
      _selectedIndexItem--;
      player.setUrl(songs[_selectedIndexItem].source);
      player.play();
      notifyListeners();
    }
  }

  void shuffle() {
    // TODO: Triển khai shuffle
    notifyListeners();
  }

  void repeat() {
    // TODO: Triển khai repeat
    notifyListeners();
  }

  void dispose() {
    super.dispose();

    // để giải phóng tài nguyên khi không cần thiết nữa= > thoát trang thì hết hát
    player.dispose();
  }
}
