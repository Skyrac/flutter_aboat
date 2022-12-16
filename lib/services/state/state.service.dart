import '../../models/playlist/playlist.model.dart';
import '../../models/search/search_result.model.dart';

class StateService {
  final Map<dynamic, List<SearchResult>> map = {};
  final List<Playlist> playlists = List.empty();
  var isDetailPlayerOpen = true;
  Function? miniplayerFunction;

  //#region Miniplayer
  void setMiniplayerFunction(Function miniplayerFunction) {
    this.miniplayerFunction = miniplayerFunction;
  }

  openDetailPlayer() {
    isDetailPlayerOpen = true;
    if (miniplayerFunction != null) {
      miniplayerFunction!();
    }
  }

  closeDetailPlayer() {
    isDetailPlayerOpen = false;
    if (miniplayerFunction != null) {
      miniplayerFunction!();
    }
  }
  //#endregion
}
