import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  List<Song>? _cachedSongs;

  final Uri songsUri = Uri.https(
    'pychey-the-best-learning-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    if (_cachedSongs != null && !forceFetch) {
      return _cachedSongs!;
    }

    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      _cachedSongs = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<int> likeSong(String songId, int currentLikes) async {
    final int newLikes = currentLikes + 1;

    final Uri likeUri = Uri.https(
      'pychey-the-best-learning-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs/$songId/likes.json',
    );

    final http.Response response = await http.put(
      likeUri,
      body: json.encode(newLikes),
    );

    if (response.statusCode == 200) {
      return newLikes;
    } else {
      throw Exception('Failed to like song');
    }
  }
}
