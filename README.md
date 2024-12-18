# Botika VA SDK Flutter

A new Flutter plugin of botika Virtual Avatar, providing component to send text and then receive response text and video 

## Installation

To integrate the plugin in your Flutter App, you need
to add this plugin to your `pubspec.yaml`

## Code

```dart
import 'package:botika_va/handlers/va_handler.dart';
import 'package:botika_va/models/config.dart';
import 'package:botika_va/models/webhook_model.dart';
import 'package:botika_va/models/anima_model.dart';

class _MyAppState extends State<MyApp> implements BotikaVaHandler {
  BotikaVa botikaVa = BotikaVa();
  VaConfig vaConfig = VaConfig(
    webHookAccessToken: "YOUR_WEBHOOK_ACCESS_TOKEN",
    webHookId: "WEBHOOK_ID",
    webHookRecipientId: "YOUR_WEBHOOK_RECEPIENT_ID",
    webHooksenderId: "YOUR_WEBHOOK_SENDER_ID",
    animaAccessToken: "YOUR_ANIMA_ACCESS_TOKEN",
    animaRequestId: "YOUR_ANIMA_REQUEST_ID",
    animaTemplate: "AVATAR_TEMPLATE",
    animaVoice: "YOUR_ANIMA_VOICE_ID",
    animaLanguage: "YOUR_ANIMA_VOICE_LANGUAGE",
    animaSenderId: "YOUR_ANIMA_SENDER_ID",
    downloadHeaders: const {
      "Authorization": "Bearer YOUR_ANIMA_ACCESS_TOKEN",
      "Cache-Control": "no-cache",
      "Pragma": "no-cache",
      "Accept": "*/*",
      "Accept-Encoding": "gzip, deflate, br",
      "Connection": "keep-alive",
    },
    profilingToken: "YOUR_PROFILING_TOKEN",
    profileAccessToken: "YOUR_PROFILING_ACCESS_TOKEN",
    profileBotId: "YOUR_PROFILING_BOT_ID",

    // set to true, for response with text + audio
    // set to false, for response with text + video
    voiceOnly: false,

    // set to true, and get response from SSE
    // set to false, and get response from API
    // some va still use API while other might use SSE
    // but in the future, all will use web socket
    useSSE: false,

    // keep all this param default fow now
    requestVideoType: RequestVideoType.none,
    downloadVideoMode: DownloadVideoMode.video,
    internalDownload: false,
  );

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

  void send() async {
    // send message to your VA by using
    // sendMessage() function
    await botikaVa.sendMessage("hello...");
  }

  void stopResponse() {
    // use this function
    // to stop current response
    // warning : you can call this function after
    // botikaVa.sendMessage function finish proccess
    botikaVa.stopResponse();
  }

  @override
  void onVaError(String message) {
    // display error message
  }

  @override
  void onVaResponseVoice(String responseId, MessageModel msg, List<String?> audios) {
    if (msg.type == "text") {
      // display message get from : msg.value
    } else if (msg.type == "button") {
      // display buttons get from msg.getButtons()
    }

    // list of audio will not be empty
    // msg.type == "text"
    for (String? url in audios) {
      // url of audio
    }
  }

  @override
  void onVaResponse(String responseId, MessageModel msg, List<DownloadVideoModel> videos) async {
    if (msg.type == "text") {
      // display message get from : msg.value
    } else if (msg.type == "button") {
      // display buttons get from msg.getButtons()
    }

    // list of video will not be empty
    // msg.type == "text"
    for (DownloadVideoModel r in videos) {
      // get blob data video by using : r.getUri()
      // header can be obtain from : vaConfig.downloadHeaders!
      Uri uri = r.getUri();

      // or if r.getUri() dont work
      // you can use this call bellow
      String? url = await botikaVa.getVideoUrl(r);
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