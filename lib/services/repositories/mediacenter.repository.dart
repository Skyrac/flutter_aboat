import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/podcasts/podcast.model.dart';

class MediacenterRepository {
  MediacenterRepository._();

  static List<Podcast> getLibraryMock() {
    return <Podcast>[
      Podcast(
          aboatId: 1,
          image:
              'https://static-cdn.sr.se/images/4826/3524003_1152_1152.jpg?preset=api-itunes-presentation-image',
          title: 'Test Podcast 1'),
      Podcast(
          aboatId: 2,
          image:
              'https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/14163336/14163336-1617293886597-924340d44fdbf.jpg',
          title: 'Test Podcast 2')
    ];
  }

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
