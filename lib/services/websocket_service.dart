import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/services/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;

class WebSocketService {
  final Map<String, WebsocketHandler> _subscriber =
      <String, WebsocketHandler>{};

  final SocketClient _socketClient = SocketClient(
    'https://websocket.botika.online',
    {},
  );
  // ignore: non_constant_identifier_names
  socket_io_client.Socket? _socketChannel;

  Function()? onConnect;
  Function(dynamic error)? onError;
  Function(dynamic error)? onConnectError;

  WebSocketService();

  void addWebSocketSubscriber(String name, WebsocketHandler handler) {
    if (_subscriber.containsKey(name)) {
      return;
    }
    _subscriber[name] = handler;
  }

  void removeWebSocketSubscriber(String name) {
    if (!_subscriber.containsKey(name)) {
      return;
    }
    _subscriber.remove(name);
  }

  void disconnectSocket() {
    _subscriber.clear();
    if (_socketChannel != null) {
      _socketChannel!.dispose();
      _socketChannel = null;
    }
  }

  void dispose() {
    disconnectSocket();
  }

  void connectSocket(String channel, String jwt) {
    if (_socketChannel != null) {
      _socketChannel!.dispose();
      _socketChannel = null;
    }

    _socketClient.auth = {"token": jwt};
    _socketChannel = _socketClient.channel(channel);

    //_socketChannel!.onAny((event, data) => print("luna - $event $data"));

    _socketChannel!.onConnect((_) {
      if (onConnect != null) {
        onConnect!();
      }
    });

    _socketChannel!.onError((d) {
      if (onError != null) {
        onError!(d);
      }
    });

    _socketChannel!.onConnectError((d) {
      if (onConnectError != null) {
        onConnectError!(d);
      }
    });

    _socketChannel!.on("message", (data) {
      _subscriber.forEach((_, value) {
        WebHookModel? d;

        try {
          d = WebHookModel.fromJson(data);
        } catch (_) {}

        if (d == null) {
          return;
        }

        value.onWebsocketMessage(d);
      });
    });

    _socketChannel!.connect();
  }
}

abstract class WebsocketHandler {
  void onWebsocketMessage(WebHookModel msg);
}
