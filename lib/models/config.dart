import 'package:botika_va/providers/jwt_provider.dart';

enum RequestVideoType { chunk, internal, none }

enum DownloadVideoMode { chunk, video }

enum ResponseVaType { api, sse, socket }

class VaConfig {
  // weebhook
  String? webHookAccessToken;
  String? webHookId;
  String? webHookRecipientId;
  String? webHooksenderId;

  // anima
  String? animaAccessToken;
  String? animaRequestId;
  String? animaTemplate;
  String? animaVoice;
  String? animaLanguage;
  String? animaSenderId;
  Map<String, String>? downloadHeaders;

  // profiling
  String? profilingToken;
  String? profileAccessToken;
  String? profileBotId;

  // socket
  String? jwt;

  // extra shenanigans
  // dont ask me, its just work around
  bool? voiceOnly;
  ResponseVaType responseVaType;

  RequestVideoType? requestVideoType;
  DownloadVideoMode? downloadVideoMode;
  bool? internalDownload;

  VaConfig({
    this.webHookAccessToken,
    this.webHookId,
    this.webHookRecipientId,
    this.webHooksenderId,
    this.animaAccessToken,
    this.animaRequestId,
    this.animaTemplate,
    this.animaVoice,
    this.animaLanguage,
    this.animaSenderId,
    this.downloadHeaders,
    this.profilingToken,
    this.profileAccessToken,
    this.profileBotId,
    this.voiceOnly = false,
    this.responseVaType = ResponseVaType.api,
    this.requestVideoType = RequestVideoType.none,
    this.downloadVideoMode = DownloadVideoMode.video,
    this.internalDownload = false,
  });

  Future<bool> login() async {
    if (webHookAccessToken == null || animaAccessToken == null) {
      return false;
    }

    JwtProvider jwtProvider = JwtProvider();
    String? result = await jwtProvider.getJwt(
      webHookAccessToken,
      animaAccessToken,
    );
    if (result == null) {
      return false;
    }

    this.jwt = result;

    return true;
  }
}
