import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_stickers_handler/exceptions.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';
import 'package:whatsapp_stickers_handler_example/models/sticker_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:whatsapp_stickers_handler_example/screens/stickers_screen.dart';

import '../screens/sticker_pack_info_screen.dart';

class StickerPackItem extends StatelessWidget {
  final StickerPacks stickerPack;
  final String stickerFetchType;

  const StickerPackItem({
    Key? key,
    required this.stickerPack,
    required this.stickerFetchType,
  }) : super(key: key);

  Widget addStickerPackButton(
      bool isInstalled, WhatsappStickersHandler _whatsappStickersHandler) {
    stickerPack.isInstalled = isInstalled;

    return IconButton(
      icon: Icon(
        isInstalled ? Icons.check : Icons.add,
      ),
      color: Colors.teal,
      tooltip: isInstalled
          ? 'Add Sticker to WhatsApp'
          : 'Sticker is added to WhatsApp',
      onPressed: () async {
        Map<String, List<String>> stickers = <String, List<String>>{};
        var tryImage = '';
        if (stickerFetchType == 'staticStickers') {
          for (var e in stickerPack.stickers!) {
            stickers[WhatsappStickerImageHandler.fromAsset(
                    "assets/${stickerPack.identifier}/${e.imageFile as String}")
                .path] = e.emojis as List<String>;
          }
          tryImage = WhatsappStickerImageHandler.fromAsset(
                  "assets/${stickerPack.identifier}/${stickerPack.trayImageFile}")
              .path;
        } else {
          final dio = Dio();
          final downloads = <Future>[];
          var applicationDocumentsDirectory =
              await getApplicationDocumentsDirectory();
          var stickersDirectory = Directory(
              //'${applicationDocumentsDirectory.path}/stickers/${stickerPack.identifier}');
              '${applicationDocumentsDirectory.path}/${stickerPack.identifier}');
          await stickersDirectory.create(recursive: true);

          downloads.add(
            dio.download(
              "${constants.baseUrl}${stickerPack.identifier}/${stickerPack.trayImageFile}",
              "${stickersDirectory.path}/${stickerPack.trayImageFile!.toLowerCase()}",
            ),
          );
          tryImage = WhatsappStickerImageHandler.fromFile(
                  "${stickersDirectory.path}/${stickerPack.trayImageFile!.toLowerCase()}")
              .path;

          for (var e in stickerPack.stickers!) {
            var urlPath =
                "${constants.baseUrl}${stickerPack.identifier}/${(e.imageFile as String)}";
            var savePath =
                "${stickersDirectory.path}/${(e.imageFile as String).toLowerCase()}";
            downloads.add(
              dio.download(
                urlPath,
                savePath,
              ),
            );

            stickers[WhatsappStickerImageHandler.fromFile(
                    "${stickersDirectory.path}/${(e.imageFile as String).toLowerCase()}")
                .path] = e.emojis as List<String>;
          }

          await Future.wait(downloads);
        }
        try {
          await _whatsappStickersHandler.addStickerPack(
            stickerPack.identifier,
            stickerPack.name as String,
            stickerPack.publisher as String,
            tryImage,
            stickerPack.publisherWebsite,
            stickerPack.privacyPolicyWebsite,
            stickerPack.licenseAgreementWebsite,
            stickerPack.animatedStickerPack ?? false,
            stickers,
          );
        } on WhatsappStickersException catch (e) {
          print(e.cause);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final WhatsappStickersHandler _whatsappStickersHandler =
        WhatsappStickersHandler();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed(StickerPackInfoScreen.routeName, arguments: {
            'stickerPack': stickerPack,
            'stickerFetchType': stickerFetchType,
          });
        },
        title: Text(stickerPack.name ?? ""),
        subtitle: Text(stickerPack.publisher ?? ""),
        leading: stickerFetchType == "remoteStickers"
            ? FadeInImage(
                placeholder: const AssetImage("assets/images/loading.gif"),
                image: NetworkImage(
                    "${constants.baseUrl}/${stickerPack.identifier}/${stickerPack.trayImageFile}"),
              )
            : Image.asset(
                "assets/${stickerPack.identifier}/${stickerPack.trayImageFile}"),
        trailing: FutureBuilder(
            future: _whatsappStickersHandler
                .isStickerPackInstalled(stickerPack.identifier as String),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? const Text("+")
                  : addStickerPackButton(
                      snapshot.data as bool,
                      _whatsappStickersHandler,
                    );
            }),
      ),
    );
  }
}
