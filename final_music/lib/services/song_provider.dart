import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SongProvider with ChangeNotifier {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> allSongs = [];
  List<AlbumInfo> albumList = [];
  Map<String, Uint8List> _songsImages = {};
  Map<String, Uint8List> _aLbumImages = {};
  List<SongInfo> _currentSongList = [];
  SongInfo currentSong;
  double minimulValue = 0.0, maximunValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = -1;
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();
  SharedPreferences _prefs;

  Future<List<SongInfo>> getDeviceSongs() async {
    allSongs = await audioQuery.getSongs(sortType: SongSortType.DISPLAY_NAME);

    return [...allSongs];
  }

  Future<List<SongInfo>> getAlbumSongs(String albumId) async {
    return await audioQuery.getSongsFromAlbum(albumId: albumId);
  }

  void setCurrentSongList(List<SongInfo> x) {
    _currentSongList = x;
  }

  List<SongInfo> get currentSongList {
    return [..._currentSongList];
  }

  Map<String, Uint8List> get songsImages {
    Map<String, Uint8List> x = _songsImages;
    return x;
  }

  void setSongsImages(Map<String, Uint8List> x) {
    _songsImages = x;
  }

  void setalbumImages(Map<String, Uint8List> x) {
    _aLbumImages = x;
  }

  Map<String, Uint8List> get albumImages {
    Map<String, Uint8List> x = _aLbumImages;
    return x;
  }

  Future<List<AlbumInfo>> getDeviceAbums() async {
    albumList = await audioQuery.getAlbums(
        sortType: AlbumSortType.LESS_SONGS_NUMBER_FIRST);
    return [...albumList];
  }

  void setSong(SongInfo songInfo) async {
    currentSong = songInfo;

    // if (widget.image == null) await setImage(songInfo.id);
    //

    await player.setUrl(currentSong.uri);
    currentValue = minimulValue;
    maximunValue = player.duration.inMilliseconds.toDouble();

    currentTime = getDuration(currentValue);
    endTime = getDuration(maximunValue);

    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();

      currentTime = getDuration(currentValue);
      notifyListeners();

      if (currentValue >= maximunValue) {
        maximunValue = currentValue + 100;
        currentValue = 0.0;
        changeTrack(true);
        //changeStatus();
      }
    });
    notifyListeners();
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  void setCurrentIndex(int x) {
    currentIndex = x;
    notifyListeners();
  }

  void changeTrack(bool isNext) {
    print(currentIndex);
    if (isNext) {
      if (currentIndex != _currentSongList.length - 1) {
        currentIndex += 1;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex -= 1;
      }
    }
    print(currentIndex);
    setSong(_currentSongList[currentIndex]);
  }

  void changeStatus() {
    isPlaying = !isPlaying;

    if (isPlaying) player.play();
    if (!isPlaying) player.pause();
    notifyListeners();
  }

  void addImage(String songId, Uint8List image) {
    if (image != null) _songsImages.putIfAbsent(songId, () => image);
  }

  void addAlbumImage(String songId, Uint8List image) {
    _aLbumImages.putIfAbsent(songId, () => image);
  }

  void saveSongImages() {
    String sImages = json.encode(songsImages);
    _prefs.setString('songsImages', sImages);
  }

  void saveAlbumImage(String id, Uint8List image) {
    String aImages = String.fromCharCodes(image);
    _prefs.setString(id, aImages);
  }

  Uint8List getAlbumImages(String id) {
    if (_prefs.containsKey(id)) {
      String imageString = _prefs.getString(id);
      List<int> list = imageString.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      print(bytes);

      return bytes;
    }
    return null;
  }

  void setSharepPref() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
