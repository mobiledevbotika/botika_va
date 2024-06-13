# Botika VA SDK Flutter

This is the Botika VA SDK Flutter

## Installation

To integrate the plugin in your Flutter App, you need
to add the plugin to your `pubspec.yaml`

```yaml

dependencies:
  botika_va : '^0.1.1'

```

## Initialization

```dart
import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/models/anima_model.dart';

class _MyAppState extends State<MyApp> implements BotikaVaHandler {
  BotikaVa botikaVa = BotikaVa();
  VaConfig vaConfig = VaConfig(/* you can put your own config here as param */);

  @override
  void initState() {
    super.initState();

    botikaVa.addSubscriber("MyController", this);
    botikaVa.init("YOUR_USER_ID", vaConfig);
  }

  @override
  void dispose() {
    super.dispose();

    botikaVa.removeSubscriber("MyController");
    botikaVa.dispose();
  }

  @override
  void onVaError(String message) {
    // display error message
  }

  @override
  void onVaResponse(MessageModel msg, List<DownloadVideoModel> videos) {
    // display message get from : msg.value

    for (DownloadVideoModel r in videos) {
      // get data video by using : r.getUri()
      // header can be obtain from : vaConfig.downloadHeaders!
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}

```