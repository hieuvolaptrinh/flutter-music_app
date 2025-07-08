import "package:flutter/material.dart";
import "package:music_app/ui/home/home.dart";
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
