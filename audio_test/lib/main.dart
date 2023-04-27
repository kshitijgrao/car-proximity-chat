import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:math';
import 'package:web_socket_channel/io.dart';

import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = "0bd5fc2320a84d468ace95ca4e467743";

// This function will send the message to our backend.
void sendUpdate(msg) {
  IOWebSocketChannel? channel;
  // We use a try - catch statement, because the connection might fail.
  try {
    // Connect to our backend.
    channel = IOWebSocketChannel.connect('ws://localhost:2000');
  } catch (e) {
    // If there is any error that might be because you need to use another connection.
    print("Error on connecting to websocket: " + e.toString());
  }
  // Send message to backend
  channel?.sink.add(msg);

  // Listen for any message from backend
  channel?.stream.listen((event) {
    // Just making sure it is not empty
    if (event!.isNotEmpty) {
      print(event);
      // Now only close the connection and we are done here!
      channel!.sink.close();
    }
  });
}

void main() async {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //location things
  Position? _currentPosition;
  Position? _remoteUserPosition =
      Position.fromMap({'latitude': 37.7857, 'longitude': -122.4063});

  int volume = 100;
  double dist = 0;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  String channelName = "kgrao";
  String token =
      "007eJxTYGia9mZzZ2NjwYap/dOybM7tTmzW+JbbZBGYuS++r+qwlYYCg0FSimlaspGxkUGihUmKiZlFYnKqpWlyokmqiZm5uYlx3zSvlIZARoYnzI0MjFAI4rMyZKcXJeYzMAAAxsAgdQ==";

  int uid = 0;
  int? docUID = 10; // uid of the local user

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
              SizedBox(height: 100, child: Center(child: _status())),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Join"),
                      onPressed: () => {join(), _getCurrentPosition()},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Leave"),
                      onPressed: () => {leave()},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Update"),
                      onPressed: () => {
                        _getCurrentPosition(),
                        sendUpdate(
                            "${docUID},${_currentPosition?.latitude},${_currentPosition?.longitude}")
                      },
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

    statusText = statusText +
        'VOL: ${volume} DIST: ${dist} LOCAL: lat: ${_currentPosition?.latitude ?? ""}, long: ${_currentPosition?.longitude ?? ""} and REM: lat: ${_remoteUserPosition?.latitude ?? ""}, long: ${_remoteUserPosition?.longitude ?? ""}';

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
          docUID = connection.localUid;
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

  //minimum distance in meters used to scale volume
  static const double minDist = 0.5;
  static const double logScale = 21;
  //equation: volume = 100 - logScale * log(dist / minDist)
  //desmos: https://www.desmos.com/calculator/4ru6fkksrt

  int getVolume(Position? pos1, Position? pos2) {
    if (pos1 == null || pos2 == null) {
      return 0;
    }
    dist = Geolocator.distanceBetween(
        pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
    if (dist <= minDist) {
      return 100;
    } else {
      return max((100 - logScale * log(dist / minDist)).toInt(), 0);
    }
  }

  //location stuff
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      if (!hasPermission) return;
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });
      _getCurrentPosition();
      if (_remoteUid != null) {
        agoraEngine.adjustUserPlaybackSignalVolume(
            uid: _remoteUid!,
            volume: getVolume(_currentPosition, _remoteUserPosition));
      }

      volume = getVolume(_currentPosition, _remoteUserPosition);
    });
  }
}
