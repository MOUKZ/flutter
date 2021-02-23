import 'dart:typed_data';
import 'package:final_music/services/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';

class AlbumItem extends StatefulWidget {
  final AlbumInfo album;
  AlbumItem(this.album);

  @override
  _AlbumItemState createState() => _AlbumItemState();
}

class _AlbumItemState extends State<AlbumItem> {
  bool isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (isInit) {

    // }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    Uint8List image = songProvider.getAlbumImages(widget.album.id);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        (image != null)
            ? Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  image: DecorationImage(
                    image: image.isNotEmpty
                        ? MemoryImage(image)
                        : AssetImage("assets/images/no_album2.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : FutureBuilder<Uint8List>(
                future: songProvider.audioQuery
                    .getArtwork(type: ResourceType.ALBUM, id: widget.album.id),
                builder: (_, imSnapshot) {
                  if (imSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  songProvider.saveAlbumImage(widget.album.id, imSnapshot.data);
                  return Container(
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          image: DecorationImage(
                              image: (imSnapshot.data.isNotEmpty)
                                  ? MemoryImage(imSnapshot.data)
                                  : AssetImage("assets/images/no_album2.jpg"),
                              fit: BoxFit.cover)));
                }),
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0xf0, 0xff, 0xff, 0.5),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  child: Text(
                widget.album.title,
                //  maxLines: widget.album.titleMaxLines,
                //  style: widget.album.titleTextStyle,
              )),
              Flexible(child: Text(widget.album.artist)),
              Flexible(child: Text(widget.album.numberOfSongs)),
            ],
          ),
        ),
      ],
    );
  }
}
