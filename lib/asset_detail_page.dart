import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'multi_video_player/multi_video_player_home.dart';

class AssetDetailPage extends StatelessWidget {
  final List<AssetEntity> entities;
  const AssetDetailPage({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Asset Detail",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          InkWell(
            onTap: () {},
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions.customChild(
                  maxScale: PhotoViewComputedScale.covered * 10.0,
                  minScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: entities[index].id),
                  initialScale: PhotoViewComputedScale.contained,
                  child: FutureBuilder(
                    future: entities[index].file,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const SizedBox();
                      } else if (snapshot.hasData) {
                        final List<File?> videoFiles = [snapshot.data];
                        return MultiVideoPlayer.file(
                            height: double.infinity,
                            width: double.infinity,
                            videoSourceList: videoFiles,
                            scrollDirection: Axis.horizontal,
                            preloadPagesCount: 1,
                            isRecoverPage: false,
                            // onPageChanged:
                            //     (videoPlayerController, index) {
                            //   controller.updateVideoController(
                            //       videoPlayerController);
                            // },
                            showVideoProgressIndicator: true,
                            showControlsOverlay: true,
                            playPauseWithTap: true);
                      } else {
                        debugPrint("error from asset detail page video");
                        return const SizedBox();
                      }
                    },
                  ),
                );
              },
              itemCount: entities.length,
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
              backgroundDecoration: const BoxDecoration(color: Colors.white),
              // pageController: pageController,
              onPageChanged: (index) {
                //controller.updatePageIndex(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
