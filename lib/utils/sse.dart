import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum SSERequestType { get, post }

class SSEModel {
  String? id = '';
  String? event = '';
  String? data = '';

  SSEModel({this.data, this.id, this.event});

  SSEModel.fromData(String data) {
    id = data.split("\n")[0].split('id:')[1];
    event = data.split("\n")[1].split('event:')[1];
    this.data = data.split("\n")[2].split('data:')[1];
  }
}

class SSEClient {
  static http.Client _client = http.Client();
  static void _retryConnection(
      {required SSERequestType method,
      required String url,
      required Map<String, String> header,
      required StreamController<SSEModel> streamController,
      Map<String, dynamic>? body}) {
    //print('---RETRY CONNECTION---');
    Future.delayed(const Duration(seconds: 5), () {
      subscribeToSSE(
        method: method,
        url: url,
        header: header,
        body: body,
        oldStreamController: streamController,
      );
    });
  }

  static Stream<SSEModel> subscribeToSSE(
      {required SSERequestType method,
      required String url,
      required Map<String, String> header,
      StreamController<SSEModel>? oldStreamController,
      Map<String, dynamic>? body}) {
    StreamController<SSEModel> streamController = StreamController();
    if (oldStreamController != null) {
      streamController = oldStreamController;
    }
    var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    //print("--SUBSCRIBING TO SSE---");
    while (true) {
      try {
        _client = http.Client();
        var request = http.Request(
          method == SSERequestType.get ? "GET" : "POST",
          Uri.parse(url),
        );

        /// Adding headers to the request
        header.forEach((key, value) {
          request.headers[key] = value;
        });

        /// Adding body to the request if exists
        if (body != null) {
          request.body = jsonEncode(body);
        }

        Future<http.StreamedResponse> response = _client.send(request);

        response.asStream().listen((data) {
          // ignore: avoid_single_cascade_in_expression_statements
          data.stream
            ..transform(const Utf8Decoder())
                .transform(const LineSplitter())
                .listen(
              (dataLine) {
                if (dataLine.isEmpty) {
                  /// This means that the complete event set has been read.
                  /// We then add the event to the stream
                  streamController.add(currentSSEModel);
                  currentSSEModel = SSEModel(data: '', id: '', event: '');
                  return;
                }

                /// Get the match of each line through the regex
                Match match = lineRegex.firstMatch(dataLine)!;
                var field = match.group(1);
                if (field!.isEmpty) {
                  return;
                }
                var value = '';
                if (field == 'data') {
                  // If the field is data, we get the data through the substring
                  value = dataLine.substring(
                    5,
                  );
                } else {
                  value = match.group(2) ?? '';
                }
                switch (field) {
                  case 'event':
                    currentSSEModel.event = value;
                    break;
                  case 'data':
                    currentSSEModel.data =
                        '${currentSSEModel.data ?? ''}$value\n';
                    break;
                  case 'id':
                    currentSSEModel.id = value;
                    break;
                  case 'retry':
                    break;
                  default:
                    // print('---ERROR---');
                    // print(dataLine);
                    _retryConnection(
                      method: method,
                      url: url,
                      header: header,
                      streamController: streamController,
                    );
                }
              },
              onError: (e, s) {
                // print('---ERROR---');
                // print(e);
                _retryConnection(
                  method: method,
                  url: url,
                  header: header,
                  body: body,
                  streamController: streamController,
                );
              },
            );
        }, onError: (e, s) {
          // print('---ERROR---');
          // print(e);
          _retryConnection(
            method: method,
            url: url,
            header: header,
            body: body,
            streamController: streamController,
          );
        });
      } catch (e) {
        // print('---ERROR---');
        // print(e);
        _retryConnection(
          method: method,
          url: url,
          header: header,
          body: body,
          streamController: streamController,
        );
      }
      return streamController.stream;
    }
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
