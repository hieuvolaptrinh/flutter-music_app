import "package:flutter/material.dart";
import "package:music_app/data/model/song.dart";

import "package:music_app/ui/home/song_item_widget.dart";
import "package:music_app/ui/now_playing/playing.dart";
import "package:music_app/viewmodel/audio_play_manager.dart";

import "package:music_app/viewmodel/home_viewmodel.dart";
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

/*
  * Nếu không có provider thì
  Tạo biến ViewModel trong mỗi StatefulWidget
  Quản lý vòng đời thủ công (gọi dispose() thủ công)
  Truyền ViewModel qua constructor từng Widget con
  Tự viết code cập nhật UI mỗi lần dữ liệu thay đổi
  Rất rối, không mở rộng được, đặc biệt với nhiều màn hình, nhiều trạng thái.
  * */
class _HomeTabPageState extends State<HomeTabPage> {
  // Trong initState(), bạn chỉ nên dùng context.read<T>(),
  /*
    * context.read<T>() – Lấy dữ liệu, KHÔNG tự rebuild
    * context.watch<T>() – Lấy dữ liệu, TỰ rebuild nếu dữ liệu thay đổi
    * ví dụ:
    * @override
      Widget build(BuildContext context) {
        final viewModel = context.watch<HomeViewmodel>();

        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: viewModel.songs.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(viewModel.songs[index].title));
          },
        );
  }  Khi isLoading hoặc songs thay đổi → build() sẽ tự động được gọi lại.
  *
  *
    * Consumer<T>() – Tái dựng UI theo cách TỐI ƯU Dùng khi bạn muốn chỉ một phần nhỏ của widget rebuild, tránh cả widget lớn bị rebuild.
    *@override
        Widget build(BuildContext context) {
          return Column(
            children: [
              Text("Music App", style: TextStyle(fontSize: 24)),
              // ✅ Chỉ phần này rebuild khi viewModel thay đổi
              Consumer<HomeViewmodel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) return CircularProgressIndicator();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: vm.songs.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(vm.songs[index].title));

    * */
  @override
  void initState() {
    super.initState();
  }

  // hàm
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Phát tất cả")),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigate(Song song, List<Song> songs) {
    // **CÁCH MỚI**: Cập nhật AudioPlayerManager trước khi navigate
    final audioPlayerManager = context.read<AudioPlayerManager>();
    final songIndex = songs.indexOf(song);

    // Cập nhật danh sách bài hát và bài đang chọn
    if(audioPlayerManager.selectedIndexItem != songIndex) {
      audioPlayerManager.updateSongs(songs, songIndex);
    }


    // Navigate không cần truyền dữ liệu - dùng Provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingPage(), // Không cần truyền tham số
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Lắng nghe ViewModel: UI sẽ tự cập nhật khi có thay đổi
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        // Nếu đang loading thì hiển thị vòng tròn chờ
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (viewModel.songs.isEmpty) {
          return Center(child: Text("Không có bài hát nào."));
        }
        //
        return Container(
          decoration: BoxDecoration(color: Colors.white70),
          child: ListView.separated(
            itemBuilder: (context, index) {
              return SongItemWidget(
                onTrailing: () {
                  showBottomSheet();
                },
                onTap: (context) {
                  navigate(viewModel.songs[index], viewModel.songs);
                },
                song: viewModel.songs[index],
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 24,
                endIndent: 24,
              );
            },
            itemCount: viewModel.songs.length,
            shrinkWrap: true,
          ),
        );
      },
    );
  }
}
