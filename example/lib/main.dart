import 'package:flutter/material.dart';
import 'package:whatsapp_stickers_handler_example/screens/information_screen.dart';
import 'screens/sticker_pack_info_screen.dart';
import 'package:whatsapp_stickers_handler_example/screens/stickers_screen.dart';

enum PopupMenuOptions {
  staticStickers,
  remoteStickers,
  informations,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "whatsapp stickers handler example",
      initialRoute: StickersScreen.routeName,
      routes: {
        StickersScreen.routeName: (ctx) => const StickersScreen(),
        StickerPackInfoScreen.routeName: (ctx) => const StickerPackInfoScreen(),
        InformationScreen.routeName: (ctx) => const InformationScreen()
      },
    );
  }
}
