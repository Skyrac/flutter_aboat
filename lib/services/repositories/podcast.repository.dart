import '../../models/podcasts/episode.model.dart';

class PodcastRepository {
  PodcastRepository._() {}
  static List<Episode> getEpisodesMock(int podcastId) {
    return <Episode>[
      Episode(
          aboat_id: 1,
          audio:
              'https://d3ctxlq1ktw2nl.cloudfront.net/staging/2020-4-20/75037358-44100-2-edbe215bc27c8.m4a',
          Image:
              'https://static-cdn.sr.se/images/4826/3524003_1152_1152.jpg?preset=api-itunes-presentation-image',
          title: 'title',
          description: 'description',
          audio_length_sec: 100),
      Episode(
          aboat_id: 1,
          audio:
              'https://d3ctxlq1ktw2nl.cloudfront.net/staging/2020-4-20/75037358-44100-2-edbe215bc27c8.m4a',
          Image:
              'https://static-cdn.sr.se/images/4826/3524003_1152_1152.jpg?preset=api-itunes-presentation-image',
          title: 'title',
          description: 'description',
          audio_length_sec: 100),
      Episode(
          aboat_id: 1,
          audio:
              'https://d3ctxlq1ktw2nl.cloudfront.net/staging/2020-4-20/75037358-44100-2-edbe215bc27c8.m4a',
          Image:
              'https://static-cdn.sr.se/images/4826/3524003_1152_1152.jpg?preset=api-itunes-presentation-image',
          title: 'Some Title',
          description: 'Huhu',
          audio_length_sec: 100),
      Episode(
          aboat_id: 1,
          audio:
              'https://d3ctxlq1ktw2nl.cloudfront.net/staging/2020-4-20/75037358-44100-2-edbe215bc27c8.m4a',
          Image:
              'https://static-cdn.sr.se/images/4826/3524003_1152_1152.jpg?preset=api-itunes-presentation-image',
          title: 'Test2',
          description: 'o.o',
          audio_length_sec: 100)
    ];
  }
}
