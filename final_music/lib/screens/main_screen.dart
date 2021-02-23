import 'package:final_music/screens/album_list_screen.dart';
import 'package:final_music/screens/songs_list_screen.dart';
import 'package:final_music/services/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      isInit = false;
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      songProvider.setSharepPref();

      print(songProvider.songsImages.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                color: Colors.black,
                size: 30,
              ),
              SizedBox(
                width: 5,
              ),
              Text('Smoukiz music'),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    Colors.blueGrey, //.withOpacity(0.7),
                    Colors.white, //.withOpacity(0.7),
                  ],
                  stops: [
                    0.1,
                    0.9,
                  ]),
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          Colors.blueGrey, //.withOpacity(0.7),
                          Colors.white70, //.withOpacity(0.7),
                        ],
                        stops: [
                          0.1,
                          0.9,
                        ]),
                  ),
                  child: TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.blueGrey[700],
                    tabs: [
                      Tab(
                        text: 'All Songs',
                        icon: Icon(Icons.music_note),
                      ),
                      Tab(
                        text: 'Albums',
                        icon: Icon(Icons.album),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    /* Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(99)),
                          color: Colors.red,
                          /*gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                              colors: [
                                Colors.blueGrey.withOpacity(0.7),
                                Colors.white70.withOpacity(0.7),
                              ],
                              stops: [
                                0.1,
                                0.9,
                              ]),*/
                        ),
                        child: Center(child: Text('Alboms'))),*/
                    SongsListScreen(),
                    AlbumListScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
