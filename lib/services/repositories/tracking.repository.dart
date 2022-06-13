import '../../configuration/dio.config.dart';

class TrackingRepository {
  TrackingRepository._();

  static const API = "/v1/media";

  static dynamic createRequestData(String owner, String asset, int playTime) {
    return {"Owner": owner, "Asset": asset, "PlayTime": playTime};
  }

  static Future<void> Play(String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/play');
    print(response.data);
  }

  static Future<void> Pause(String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/pause');
    print(response.data);
  }

  static Future<void> Stop(String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/stop');
    print(response.data);
  }

  static Future<void> Mute(String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/mute');
    print(response.data);
  }

  static Future<void> Unmute(String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/unmute');
    print(response.data);
  }

  static Future<void> Heartbeat(
      String owner, String asset, int playTime) async {
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/heartbeat');
    print(response.data);
  }
}
