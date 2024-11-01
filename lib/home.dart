import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fvp_crash_example/asset_detail_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<AssetEntity> videos = [];
  List<AssetPathEntity> albums = [];

  @override
  void initState() {
    getVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "FVP Crash Example",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: PopScope(
        child: Column(
          children: [
            if (videos.isEmpty)
              ElevatedButton(
                onPressed: () async {
                  await getVideos();
                  setState(() {});
                },
                child: const Text(
                  "Get Videos",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomScrollView(
                  slivers: [
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return InkWell(
                            onTap: () {
                              goToAssetDetailPage(
                                entities: videos,
                                initialIndex: 0,
                              );
                            },
                            child: AssetEntityImage(
                              videos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              isOriginal: false,
                              thumbnailSize: const ThumbnailSize(600, 600),
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return const SizedBox();
                              },
                            ),
                          );
                        },
                        childCount: videos.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getVideos() async {
    videos.clear();
    await getAllAlbums();
    await Future.delayed(const Duration(seconds: 2));
    final videosAlbum = albums.firstWhere((album) => album.name == "Videos");
    int videosAlbumLength = await videosAlbum.assetCountAsync;
    final deviceVideos =
        await videosAlbum.getAssetListRange(start: 0, end: videosAlbumLength);
    print("videos: $videosAlbumLength");
    videos = deviceVideos;
    setState(() {});
  }

  getAllAlbums() async {
    try {
      albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );
      setState(() {});
    } on PlatformException catch (e) {
      debugPrint("PlatformException Get All Albums: $e");
    } catch (e) {
      debugPrint('Error getting albums: $e');
    }
  }

  goToAssetDetailPage({
    required List<AssetEntity> entities,
    required int initialIndex,
  }) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AssetDetailPage(entities: entities)));
  }
}
