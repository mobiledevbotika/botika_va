import 'package:botika_va/providers/base_provider.dart';

class JwtProvider extends BaseProvider {
  Future<String?> getJwt(String? webHookToken, String? animaToken) async {
    String? jwt;

    String url = "https://api.botika.online/private/auth/detail.php";
    Map<String, dynamic> body = {
      "accessToken": webHookToken,
      "token": animaToken,
    };

    Map<String, dynamic>? response = await post(
      url,
      body,
    );

    if (response == null) {
      return null;
    }

    try {
      jwt = response['data']['jwt'];
    } catch (e) {
      //
      errorMessage = "$e";
      return null;
    }

    return jwt;
  }
}
