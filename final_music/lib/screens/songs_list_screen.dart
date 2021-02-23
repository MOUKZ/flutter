import 'dart:convert';
import 'dart:typed_data';

import 'package:final_music/widgets/music_player.dart';
import 'package:final_music/services/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongsListScreen extends StatefulWidget {
  @override
  _SongsListScreenState createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen>
    with AutomaticKeepAliveClientMixin {
  bool isInit = true;

  List<SongInfo> x = [];

  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();

  @override
  bool get wantKeepAlive => true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      tryget(context);
    }
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.setCurrentSongList(x);
  }

  void tryget(BuildContext ctx) async {
    final songProvider = Provider.of<SongProvider>(ctx, listen: false);
    x = await songProvider.getDeviceSongs();
    setState(() {
      x = x;
    });
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.3),
                Colors.white,
              ],
              stops: [
                0.1,
                0.9,
              ]),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemCount: x.length,
          separatorBuilder: (ctx, i) => const Divider(),
          itemBuilder: (ctx, i) {
            return ListTile(
              title: Text(x[i].title),
              leading: (songProvider.songsImages[x[i].id] != null &&
                      songProvider.songsImages[x[i].id].isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage:
                          MemoryImage(songProvider.songsImages[x[i].id]),
                    )
                  : FutureBuilder<Uint8List>(
                      future: songProvider.audioQuery.getArtwork(
                        type: ResourceType.SONG,
                        id: x[i].id,
                      ),
                      builder: (_, snapshot) {
                        if (snapshot.data == null) {
                          return const CircleAvatar(
                            child: const CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.data.isEmpty) {
                          return CircleAvatar(
                            backgroundImage: const AssetImage(
                                "assets/images/music_gradient.jpg"),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          songProvider.addImage(x[i].id, snapshot.data);
                          songProvider.setCurrentSongList(x);
                        }

                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: MemoryImage(
                            snapshot.data,
                          ),
                        );
                      }),
              trailing: Consumer<SongProvider>(
                builder: (_, sp, child) => i == sp.currentIndex
                    ? IconButton(
                        icon: sp.isPlaying
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow),
                        onPressed: () {
                          songProvider.changeStatus();
                          // songProvider.currentIndex = -1;
                          setState(() {});
                        })
                    : Icon(
                        Icons.play_arrow,
                        color: Colors.transparent,
                      ),
              ),
              onTap: () {
                songProvider.setCurrentSongList(x);
                if (i != songProvider.currentIndex) {
                  songProvider.setSong(x[i]);
                  songProvider.currentIndex = i;
                }
                if (i == songProvider.currentIndex) {
                  if (!songProvider.player.playing) {
                    songProvider.changeStatus();
                  }
                }
                // showBottomSheet(
                //   context: context,
                //   builder: (context) => MiniPlayer(
                //     title: x[i].title,
                //   ),
                // );
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => MusicPlayer(
                          songInfo: x[i],
                          songsImages: songProvider.songsImages,
                        ));
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
