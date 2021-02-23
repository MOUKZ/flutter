import 'dart:typed_data';
import 'package:final_music/services/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:bordered_text/bordered_text.dart';
import 'dart:ui';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;

  Map<String, Uint8List> songsImages;

  MusicPlayer({this.songInfo, this.songsImages});

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  Uint8List unLoadedImage;
  bool isFirst = true;
  MediaQueryData mediaQueryData;
  double widthScreen = 0.0;
  double heightScreen = 0.0;
  double paddingBottom = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirst) {
      isFirst = false;
      final songProvider = Provider.of<SongProvider>(context, listen: true);
      getImage(songProvider);
      setState(() {
        unLoadedImage = unLoadedImage;
      });
      mediaQueryData = MediaQuery.of(context);
      widthScreen = mediaQueryData.size.width;
      heightScreen = mediaQueryData.size.height;
      paddingBottom = mediaQueryData.padding.bottom;
    }
  }

  void getImage(SongProvider songProvider) async {
    unLoadedImage = await songProvider.audioQuery.getArtwork(
      type: ResourceType.SONG,
      id: songProvider.currentSong.id,
    );
    songProvider.addImage(songProvider.currentSong.id, unLoadedImage);
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: true);

    return Stack(
      children: [
        Container(
          height: heightScreen * 0.5,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: (songProvider.songsImages[songProvider.currentSong.id] !=
                            null &&
                        songProvider.songsImages[songProvider.currentSong.id]
                            .isNotEmpty)
                    ? MemoryImage(
                        songProvider.songsImages[songProvider.currentSong.id])
                    : AssetImage("assets/images/no_album2.jpg"),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              height: heightScreen * 0.8,
              color: Colors.white.withOpacity(0.0),
            ),
          ),
        ),
        Container(
          height: heightScreen * 0.8,
          margin: EdgeInsets.fromLTRB(5, 40, 5, 0),
          child: Column(
            children: [
              (songProvider.songsImages[songProvider.currentSong.id] != null &&
                      songProvider
                          .songsImages[songProvider.currentSong.id].isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(songProvider
                          .songsImages[songProvider.currentSong.id]),
                      radius: 150,
                    )
                  : (unLoadedImage != null && unLoadedImage.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(unLoadedImage),
                          radius: 150,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/no_album2.jpg"),
                          radius: 150,
                        ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: BorderedText(
                  strokeColor: Colors.white,
                  child: Text(
                    songProvider.currentSong.title,
                    style: TextStyle(
                      fontSize: 25,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.red,
                    ),
                  ),
                  strokeWidth: 1.0,
                ),
              ),
              Slider(
                  min: songProvider.minimulValue,
                  max: songProvider.maximunValue,
                  inactiveColor: Colors.black12,
                  activeColor: Colors.black,
                  value: songProvider.currentValue > songProvider.maximunValue
                      ? songProvider.maximunValue
                      : songProvider.currentValue,
                  onChanged: (value) {
                    songProvider.currentValue = value;

                    if (songProvider.currentValue ==
                        songProvider.maximunValue) {
                      songProvider.changeTrack(true);
                    }
                    return songProvider.player
                        .seek(Duration(milliseconds: value.round()));
                  }),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                transform: Matrix4.translationValues(0, -5, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(songProvider.currentTime),
                    Text(songProvider.endTime),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        iconSize: 55,
                        icon: Icon(Icons.skip_previous),
                        onPressed: () {
                          isFirst = true;
                          songProvider.changeTrack(false);
                        }),
                    IconButton(
                        iconSize: 75,
                        icon: Icon(songProvider.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed: () {
                          songProvider.changeStatus();
                        }),
                    IconButton(
                        iconSize: 55,
                        icon: Icon(Icons.skip_next),
                        onPressed: () {
                          isFirst = true;
                          songProvider.changeTrack(true);
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetBackgroundCoverAlbum(
      double widthScreen, double heightScreen) {
    return Container(
      width: widthScreen,
      height: heightScreen / 2,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/salma5.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Container(
          color: Colors.white.withOpacity(0.0),
        ),
      ),
    );
  }

  Widget _buildWidgetContainerContent(double widthScreen, double heightScreen) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: widthScreen,
        height: heightScreen / 1.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(48.0),
            topRight: Radius.circular(48.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Colors.blueGrey[300],
              Colors.white,
            ],
            stops: [
              0.1,
              0.9,
            ],
          ),
        ),
      ),
    );
  }
}
