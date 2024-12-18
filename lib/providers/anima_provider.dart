import 'package:botika_va/models/anima_model.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/providers/base_provider.dart';

class AnimaProvider extends BaseProvider {
  static String baseAnimaUrl = "https://anima.botika.online/api/public";

  Future<AnimaVideoResponseModel?> generateVideo(
    VaConfig config,
    AnimaVideoRequestModel payload,
  ) async {
    AnimaVideoResponseModel? data;

    String url = "$baseAnimaUrl/video";
    Map<String, dynamic> body = payload.toJson();
    Map<String, String> header = {
      "Authorization": "Bearer ${config.animaAccessToken}",
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
      header: header,
    );
    if (response == null) {
      return null;
    }

    try {
      bool ok = response['status'] ?? false;

      if (!ok) {
        errorMessage = "${response['message']}";
        return null;
      }

      data = AnimaVideoResponseModel.fromJson(response);
    } catch (e) {
      //
      errorMessage = "$e";
      return null;
    }

    return data;
  }

  Future<String?> generateAudio(VaConfig config, String text) async {
    String? videoUrl;

    AnimaAudioRequestModel payload = AnimaAudioRequestModel(
      filetype: "mpeg",
      paidPlan: false,
      returnType: "url",
      language: config.animaLanguage,
      voice: config.animaVoice,
      text: text,
    );

    String url = "$baseAnimaUrl/tts";
    Map<String, dynamic> body = payload.toJson();
    Map<String, String> header = {
      "Authorization": "Bearer ${config.animaAccessToken}",
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
      header: header,
    );
    if (response == null) {
      return null;
    }

    try {
      bool ok = response['status'] ?? false;

      if (!ok) {
        errorMessage = "${response['message']}";
        return null;
      }

      videoUrl = response['data'];
    } catch (e) {
      //
      errorMessage = "$e";
      return null;
    }

    return videoUrl;
  }

  Future<String?> getVideoUrl(
    VaConfig config,
    DownloadVideoModel payload,
  ) async {
    String? data;

    payload.returnType = "url";

    Map<String, String> header = {
      "Authorization": "Bearer ${config.animaAccessToken}",
    };

    Map<String, dynamic>? response = await get(
      payload.getUri().toString(),
      header: header,
    );
    if (response == null) {
      return null;
    }

    try {
      bool ok = response['status'] ?? false;

      if (!ok) {
        errorMessage = "${response['message']}";
        return null;
      }

      data = response["data"]["video"];
    } catch (e) {
      //
      errorMessage = "$e";
      return null;
    }

    return data;
  }

  Future<List<DownloadVideoModel>> generateVideos(
      VaConfig config, String text) async {
    AnimaVideoResponseModel? response = await generateVideo(
      config,
      AnimaVideoRequestModel(
        requestVideoType: config.requestVideoType!,
        id: config.animaRequestId,
        template: config.animaTemplate,
        voice: config.animaVoice,
        language: config.animaLanguage,
        text: text,
      ),
    );

    if (response == null) {
      return [];
    }

    List<DownloadVideoModel> payloads = [];

    if (config.downloadVideoMode == DownloadVideoMode.video) {
      payloads.add(
        DownloadVideoModel(
          senderId: config.animaSenderId,
          videoId: response.video,
          downloadVideoMode: config.downloadVideoMode!,
          isInternal: config.internalDownload!,
        ),
      );

      return payloads;
    }

    if (response.videoChunk == null) {
      return payloads;
    }

    for (String chunk in response.videoChunk!) {
      payloads.add(
        DownloadVideoModel(
          downloadVideoMode: config.downloadVideoMode!,
          isInternal: config.internalDownload!,
          senderId: config.animaSenderId,
          videoId: chunk,
        ),
      );
    }

    return payloads;
  }
}
