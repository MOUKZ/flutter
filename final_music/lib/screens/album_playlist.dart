import 'dart:ui';
import 'package:final_music/services/song_provider.dart';
import 'package:final_music/widgets/music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';

class AlbumPlaylist extends StatefulWidget {
  AlbumInfo album;
  List<SongInfo> albumSongs;

  AlbumPlaylist({this.album, this.albumSongs});
  @override
  _AlbumPlaylistState createState() => _AlbumPlaylistState();
}

class _AlbumPlaylistState extends State<AlbumPlaylist> {
  bool isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      tryget(context);
    }
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.setCurrentSongList(widget.albumSongs);
  }

  void tryget(BuildContext ctx) async {
    final songProvider = Provider.of<SongProvider>(ctx, listen: false);
    widget.albumSongs = await songProvider.getAlbumSongs(widget.album.id);
    setState(() {
      widget.albumSongs = widget.albumSongs;
    });
  }

  @override
  void dispose() {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.setCurrentIndex(-1);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;
    double paddingBottum = mediaQueryData.padding.bottom;
    return WillPopScope(
      onWillPop: () {
        songProvider.setCurrentIndex(-1);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: Container(
          width: widthScreen,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildWidgetBackgroundCoverAlbum(
                      widthScreen, context, songProvider),
                  _buildWidgetListMusic(context, paddingBottum, widthScreen,
                      heightScreen, widget.albumSongs, songProvider),
                ],
              ),
              _buildWidgetButtonPlayAll(songProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetListMusic(
      BuildContext ctx,
      double paddingBottum,
      double width,
      double height,
      List<SongInfo> songs,
      SongProvider songProvider) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: paddingBottum > 0 ? paddingBottum : 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.7),
                Colors.white70.withOpacity(0.7),
              ],
              stops: [
                0.1,
                0.9,
              ]),
        ),
        child: Column(
          children: [
            SizedBox(height: 48.0),
            Row(
              children: [
                Expanded(
                    child: Text('play list',
                        style: Theme.of(ctx).textTheme.headline6)),
                // ShuffleButton(),
                SizedBox(
                  width: 24,
                ),
                //  RepeatButton(),
              ],
            ),
            SizedBox(height: 8.0),
            // PlaylistMusic(songs, width, height, paddingBottum),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: songs.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(widget.album.title),
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
                    songProvider.setCurrentSongList(widget.albumSongs);
                    if (i != songProvider.currentIndex) {
                      songProvider.setSong(widget.albumSongs[i]);
                      songProvider.currentIndex = i;
                    }
                    if (i == songProvider.currentIndex) {
                      if (!songProvider.player.playing) {
                        songProvider.changeStatus();
                      }
                    }

                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => MusicPlayer(
                              songInfo: widget.albumSongs[i],
                              songsImages: songProvider.songsImages,
                            ));
                    setState(() {});
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButtonPlayAll(SongProvider songProvider) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 92.0,
        decoration: BoxDecoration(
            color: Color(0xFFAE1947),
            borderRadius: BorderRadius.all(Radius.circular(48)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Color(0xFFAE1947),
              ),
            ]),
        child: IconButton(
          icon: Icon(
            Icons.play_arrow,
          ),
          color: Colors.white,
          onPressed: () {
            songProvider.setCurrentIndex(0);
            songProvider.setSong(widget.albumSongs[0]);
          },
        ),
      ),
    );
    //ToDO: do something
  }

  Widget _buildWidgetBackgroundCoverAlbum(
      double width, BuildContext ctx, SongProvider songProvider) {
    var image = songProvider.getAlbumImages(widget.album.id);
    return Expanded(
        child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (image != null && image.isNotEmpty)
                  ? MemoryImage(image)
                  : AssetImage('assets/images/no_album2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black,
                Colors.black.withOpacity(0.1),
              ],
              stops: [0.0, 0.7],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: width / 2.5,
            height: width / 2.5,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: (image != null && image.isNotEmpty)
                      ? MemoryImage(image)
                      : AssetImage('assets/images/no_album2.jpg'),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 15.0,
                )),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: width / 1.45),
              SizedBox(height: 4.0),
              Text(
                'the album name',
                style: Theme.of(ctx).textTheme.headline6.merge(
                      TextStyle(color: Colors.white),
                    ),
              ),
              SizedBox(height: 4.0),
              Text(
                '22 songs * 1 hr 30 min',
                style: Theme.of(ctx).textTheme.subtitle2.merge(
                      TextStyle(color: Colors.grey),
                    ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
