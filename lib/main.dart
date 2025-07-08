import "package:flutter/material.dart";
import "package:music_app/ui/discovery/discovery.dart";
import "package:music_app/ui/home/home.dart";
import "package:music_app/ui/settings/setting.dart";
import "package:music_app/ui/user/User.dart";
import "package:music_app/viewmodel/home_viewmodel.dart";
import "package:provider/provider.dart";

void main() {
  return runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MusicAppViewModel())],
      child: const MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
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
        elevation: 10,
        // độ cao của appbar
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Xử lý sự kiện khi bấm nút bên phải
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Xử lý sự kiện khi bấm nút bên phải
            },
          ),
        ],
        title: Text(
          "Music App",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
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
  }
}
