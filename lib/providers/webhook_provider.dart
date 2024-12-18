import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/providers/base_provider.dart';

class WebHookProvider extends BaseProvider {
  Future<WebHookModel?> send(VaConfig config, WebHookModel payload) async {
    WebHookModel? data;

    payload.id = config.webHookId;

    if (payload.data != null) {
      payload.data!.recipientId = null;
    }

    String? url = "https://webhook.botika.online/webhook/";

    if (config.responseVaType == ResponseVaType.socket) {
      url = "${url}webhook_push.php?method=socket";
    }

    Map<String, dynamic> body = payload.toJson();
    Map<String, String> header = {
      "Authorization": "Bearer ${config.webHookAccessToken}",
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
      header: header,
    );
    if (response == null) {
      return data;
    }

    try {
      data = WebHookModel.fromJson(response);
    } catch (e) {
      errorMessage = "$e";
      return null;
    }

    return data;
  }
}
