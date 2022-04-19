import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';
import 'package:whatsapp_stickers_handler_example/models/sticker_data.dart';
import 'package:whatsapp_stickers_handler_example/screens/sticker_pack_info_screen.dart';
import '../widgets/app_bar.dart' as app_bar;
import 'package:dio/dio.dart';

import '../widgets/sticker_pack_item.dart';

mixin constants {
  static String baseUrl =
      'https://mandj.sfo2.cdn.digitaloceanspaces.com/stickers_test/';
}

class StickersScreen extends StatefulWidget {
  static const routeName = '/';

  const StickersScreen({Key? key}) : super(key: key);

  @override
  State<StickersScreen> createState() => _StickersScreenState();
}

class _StickersScreenState extends State<StickersScreen> {
  bool _isLoading = false;

  late StickerData stickerData;

  List stickerPacks = [];
  List installedStickerPacks = [];
  late String stickerFetchType;
  late Dio dio;
  var downloads = <Future>[];
  var data;

  void _loadStickers() async {
    if (stickerFetchType == null || stickerFetchType == 'staticStickers') {
      data = await rootBundle.loadString("assets/contents.json");
    } else {
      dio = Dio();
      data = await dio.get("${constants.baseUrl}contents.json");
    }
    setState(() {
      stickerData = StickerData.fromJson(jsonDecode(data.toString()));
      _isLoading = false;
    });
  }

  @override
  didChangeDependencies() {
    var args = ModalRoute.of(context)?.settings.arguments as String?;
    stickerFetchType = args ?? "staticStickers";
    setState(() {
      _isLoading = true;
    });
    _loadStickers();
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: app_bar.AppBar(
        title: stickerFetchType == "staticStickers"
            ? "Static Stickers"
            : "Remote Stickers",
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stickerData.stickerPacks!.length,
              itemBuilder: (context, index) {
                return StickerPackItem(
                  stickerPack: stickerData.stickerPacks![index],
                  stickerFetchType: stickerFetchType,
                );
              },
            ),
    );
  }
}
