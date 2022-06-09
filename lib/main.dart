// ignore_for_file: library_prefixes, constant_identifier_names, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
void main() {
  runApp( const MyApp());
}
/// Define App ID and Token
const APP_ID = '5ccc4a48379c40a998bdc758e48192f5';
const Token = '0065ccc4a48379c40a998bdc758e48192f5IABnMZ3f1yKrOLTOSUOjG51DT5W9IyTFem7POOnaESCKa7ZCE0UAAAAAEABF5qhUEY+jYgEAAQARj6Ni';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

// App state class
class _MyAppState extends State<MyApp> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Init the app
  Future<void> initPlatformState() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
           await [Permission.microphone, Permission.camera].request();
    }

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(APP_ID);
    var engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess $channel $uid');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name as 123
    await engine.joinChannel(Token, 'letmekissyou', null, 0);
  }


  // Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter example app'),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                    _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                  ),
                ), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Local video rendering
  Widget _renderLocalPreview() {
    if (_joined && defaultTargetPlatform == TargetPlatform.android ||
            _joined && defaultTargetPlatform == TargetPlatform.iOS) {
      return const RtcLocalView.SurfaceView();
    } 

    if (_joined && defaultTargetPlatform == TargetPlatform.windows ||
            _joined && defaultTargetPlatform == TargetPlatform.macOS) {
      return const RtcLocalView.TextureView();
    } 

    else {
      return const Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote video rendering
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.android || _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.iOS) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: "letmekissyou",
      );
    } 

    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.windows || _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.macOS) {
      return RtcRemoteView.TextureView(
        uid: _remoteUid,
        channelId: "letmekissyou",
      );
    } 

    else {
      return const Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}