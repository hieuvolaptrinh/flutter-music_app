import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/duration_state.dart';
import 'package:rxdart/rxdart.dart';
//đáng lý ra là các sự kiện các nút sẽ viết ở đây, sau đó các nút sẽ gọi callback ở đây
class AudioPlayerManager {
  // 1. Tạo một instance của AudioPlayer từ thư viện just_audio
  final player = AudioPlayer();

  Stream<DurationState>? durationState;

  String songURl;

  AudioPlayerManager(this.songURl);

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
          // progress: thời gian đã phát → nên là position (dòng này bạn đang dùng bufferedPosition, nên điều chỉnh lại)
          progress: position,
          // buffered: đã nạp trước bao nhiêu → playbackEvent.bufferedPosition
          buffered: playbackEvent.bufferedPosition,
          // total: tổng thời lượng của bài → playbackEvent.duration (nullable)
          total: playbackEvent.duration,
        );
      },
    );
    player.setUrl(songURl);
  }

  void dispose() {
    // để giải phóng tài nguyên khi không cần thiết nữa= > thoát trang thì hết hát
    player.dispose();
  }
}
