import "package:flutter/material.dart";
import "package:music_app/data/model/song.dart";
import "package:music_app/ui/discovery/discovery.dart";
import "package:music_app/ui/home/song_item_widget.dart";
import "package:music_app/ui/settings/setting.dart";
import "package:music_app/ui/user/User.dart";
import "package:music_app/viewmodel/home_viewmodel.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(0, 110, 255, 1.0),
        ),
        useMaterial3: true,
      ),
      home: SafeArea(child: MusicHomePage()),
      //   xóa debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [HomeTab(), Discovery(), Setting(), User()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // android phong cách material
    return Scaffold(
      appBar: AppBar(
        title: Text("Music App", style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.purpleAccent,
        ),),
        centerTitle: true,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary, // nó sẽ ăn theo cái theme đã tạo ở trên
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        // màu sắc của item được chọn
        onTap: _onItemTapped,
        unselectedItemColor: Color.fromRGBO(1, 1, 1, 1),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: "Discovery"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );

    // dưới này là phong cách Ios
    // return CupertinoPageScaffold(
    //   navigationBar: CupertinoNavigationBar(middle: Text("Music App  ")),
    //   child: CupertinoTabScaffold(
    //     tabBar: CupertinoTabBar(
    //       backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
    //       items: [
    //         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    //         BottomNavigationBarItem(
    //           icon: Icon(Icons.album),
    //           label: "Discovery",
    //         ),
    //         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
    //         BottomNavigationBarItem(
    //           icon: Icon(Icons.settings),
    //           label: "Settings",
    //         ),
    //       ],
    //     ),
    //     tabBuilder: (BuildContext context, int index) {
    //       return _tabs[index];
    //     },
    //   ),
  }
}

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
      final viewModel = context.watch<MusicAppViewModel>();

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
            Consumer<MusicAppViewModel>(
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
    // ✅ Lấy ViewModel từ Provider
    Future.delayed(Duration.zero, () {
      final viewModel = context.read<MusicAppViewModel>();
      viewModel.loadSongs(); // Gọi hàm load bài hát
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Lắng nghe ViewModel: UI sẽ tự cập nhật khi có thay đổi
    return Consumer<MusicAppViewModel>(
      builder: (context, viewModel, child) {
        // Nếu đang loading thì hiển thị vòng tròn chờ
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (viewModel.songs.isEmpty) {
          return Center(child: Text("Không có bài hát nào."));
        }
        //
        return ListView.separated(
          itemBuilder: (context, index) {
            return SongItemWidget(
                onTap:(){} ,
                song: viewModel.songs[index]);
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
        );
      },
    );
  }
}
//
// class _HomeTabPageState extends State<HomeTabPage> {
//   List<Song> songs = [];
//   late MusicAppViewModel _viewModel = MusicAppViewModel();
//
//   @override
//   void initState() {
//     _viewModel = MusicAppViewModel();
//     _viewModel.loadSongs();
//     observeData(); // Lắng nghe stream dữ liệu
//     super.initState();
//   }
//
//   // Lắng nghe stream để cập nhật danh sách bài hát khi có dữ liệu mới
//   void observeData() {
//     _viewModel.songStream.stream.listen((songList) {
//       setState(() {
//         songs.addAll(songList);
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: getBody());
//   }
//
//   @override
//   void dispose() {
//     _viewModel.songsStream.close(); // Đóng stream khi không còn sử dụng
//     super.dispose();
//   }
//
//   Widget getBody() {
//     bool isShowLoading = songs.isEmpty;
//     if (isShowLoading) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return ListView.separated(
//       // itemBuilder: Xây dựng từng phần tử (item) trong danh sách
//       itemBuilder: (context, position) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [Text(songs[position].title)],
//         );
//       },
//       // separatorBuilder: Xây dựng widget phân cách giữa 2 phần tử
//       separatorBuilder: (context, index) {
//         return Divider(
//           color: Colors.red, // Màu của đường kẻ phân cách
//           thickness: 1, // Độ dày của đường kẻ
//           indent: 24, // Khoảng cách thụt lề bên trái
//           endIndent: 24, // Khoảng cách thụt lề bên phải
//         );
//       },
//
//       itemCount: songs.length, // Tổng số phần tử trong danh sách
//
//       shrinkWrap: true,
//
//       // shrinkWrap = true giúp ListView chỉ chiếm đúng chiều cao nội dung của nó.
//     );
//   }
// }
