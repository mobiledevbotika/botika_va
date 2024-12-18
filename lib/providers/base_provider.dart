import 'dart:convert';
//import 'dart:developer';
import 'package:http/http.dart' as http;

class BaseProvider {
  int? statusCode;
  String? errorMessage;

  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? header,
  }) async {
    Map<String, dynamic>? responseBody;
    http.Response? res;

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (header != null) {
      headers.addAll(header);
    }

    try {
      res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      errorMessage = "$e";
    }

    // log("luna - $body");
    // log("luna - $header");
    // log("luna - ${res!.body}");

    if (res == null) {
      return null;
    }

    statusCode = res.statusCode;

    try {
      String bodyString = utf8.decode(res.bodyBytes);
      responseBody = jsonDecode(bodyString.trim());
    } catch (e) {
      errorMessage = "$e";
      return null;
    }

    return responseBody;
  }

  Future<Map<String, dynamic>?> get(
    String url, {
    Map<String, String>? header,
  }) async {
    Map<String, dynamic>? responseBody;
    http.Response? res;

    try {
      res = await http.get(
        Uri.parse(url),
        headers: header,
      );
    } catch (e) {
      errorMessage = "$e";
    }

    // log("luna - $url");
    // log("luna - $header");
    // log("luna - ${res!.body}");

    if (res == null) {
      return null;
    }

    statusCode = res.statusCode;

    try {
      String bodyString = utf8.decode(res.bodyBytes);
      responseBody = jsonDecode(bodyString.trim());
    } catch (e) {
      errorMessage = "$e";
      return null;
    }

    return responseBody;
  }
}
