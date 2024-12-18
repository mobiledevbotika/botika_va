import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;

class SocketClient {
  String baseUrl;
  Map auth;

  SocketClient(this.baseUrl, this.auth);

  socket_io_client.Socket channel(String name, [opts]) {
    return socket_io_client.io(
        '$baseUrl/$name',
        socket_io_client.OptionBuilder()
            .setAuth(auth)
            .setTransports(['websocket'])
            .disableForceNew()
            .disableForceNewConnection()
            .enableMultiplex()
            .build());
  }
}
