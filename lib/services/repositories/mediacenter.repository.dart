import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/podcasts/podcast.model.dart';

class MediacenterRepository {
  MediacenterRepository._();

  Future<List<Podcast>> getLibrary() async {
    final response = await http.get(Uri.parse('s'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body)
          .map((data) => Podcast.fromJson(data))
          .toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
