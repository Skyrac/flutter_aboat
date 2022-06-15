import '../../models/playlist/playlist.model.dart';
import '../../models/search/search_result.model.dart';

class StateService {
  final Map<dynamic, List<SearchResult>> map = Map();
  final List<Playlist> playlists = List.empty();
}
