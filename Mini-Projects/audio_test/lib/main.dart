import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = "0bd5fc2320a84d468ace95ca4e467743";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String channelName = "test_rao-ks";
  String token =
      "007eJxTYHh/pePztTuBriUnJC9Ix4pMv3z+lP2xyfty0tmDF20wP/RdgcEgKcU0LdnI2Mgg0cIkxcTMIjE51dI0OdEk1cTM3NzEeK2MdEpDICMD/65uZkYGCATxuRlKUotL4osS83WzixkYAAIII78=";

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Get started with Voice Calling'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Status text
              SizedBox(height: 40, child: Center(child: _status())),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Join"),
                      onPressed: () => {join()},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Leave"),
                      onPressed: () => {leave()},
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null) {
      statusText = 'Waiting for a remote user to join...';
    } else {
      statusText = 'Connected to remote user, uid:$_remoteUid';
    }

    return Text(
      statusText,
    );
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVoiceSDKEngine();
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
