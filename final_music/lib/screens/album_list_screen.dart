import 'package:final_music/screens/album_playlist.dart';
import 'package:final_music/services/song_provider.dart';
import 'package:final_music/widgets/album_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class AlbumListScreen extends StatefulWidget {
  @override
  _AlbumListScreenState createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  bool isInit = true;
  List<AlbumInfo> albumList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      tryget(context);
    }
  }

  void tryget(BuildContext ctx) async {
    final songProvider = Provider.of<SongProvider>(ctx, listen: false);
    albumList = await songProvider.getDeviceAbums();

    setState(() {
      albumList = albumList;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final songProvider = Provider.of<SongProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
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
        child: StaggeredGridView.countBuilder(
          padding: EdgeInsets.only(bottom: 0, top: 5),
          crossAxisCount: 4,
          itemCount: albumList.length,
          itemBuilder: (context, index) => InkWell(
              onTap: () {
                final songProvider =
                    Provider.of<SongProvider>(context, listen: false);
                songProvider.setCurrentIndex(-1);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AlbumPlaylist(
                          album: albumList[index],
                        )));
              },
              child: AlbumItem(albumList[index])),
          staggeredTileBuilder: (index) =>
              StaggeredTile.count(2, index.isEven ? 2 : 3),
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        ),
      ),
    );
  }
}
