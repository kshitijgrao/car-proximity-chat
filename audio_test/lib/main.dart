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
    channel = IOWebSocketChannel.connect('ws://192.0.2.2:2000');
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

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key, required this.title}) : super(key: key);
  final String title;
  final String s = 'Press this button to join Proximity Chat!';
  final Color c = const Color.fromARGB(255, 30, 113, 196);
  final Icon i = const Icon(Icons.car_rental_rounded);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              s,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CallJoinPage(title: 'Call Joined');
                }));
              },
              tooltip: 'Join Chat!',
              backgroundColor: c,
              child: i,
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Base UI Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(title: 'Car Proximity Chat'),
    );
  }
}

class CallJoinPage extends StatefulWidget {
  CallJoinPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _CallJoinPageState createState() => _CallJoinPageState();
}

class _CallJoinPageState extends State<CallJoinPage> {
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
      "007eJxTYHiXPI9Pn+Or+RmxR2s+VH+wdD10to+jPk07RXP5RWtJZ34FBoOkFNO0ZCNjI4NEC5MUEzOLxORUS9PkRJNUEzNzcxPjbI3QlIZARoZpdzmZGRkgEMRnZchOL0rMZ2AAABfEHhc=";

  int uid = 0; // uid of the local user

  var remoteUsers =
      <int, double>{}; //map holding u ids and distances of other users

  int? docUID = 10; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     scaffoldMessengerKey: scaffoldMessengerKey,
  //     home: const FirstPage(title: 'Car Proximity Chat'),
  //   );
  // }

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
          docUID = connection.localUid;
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
            docUID = connection.localUid;
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
    return getVolumeFromDist(dist);
  }

  int getVolumeFromDist(double? dist) {
    if (dist == null) {
      return 0;
    }
    if (dist <= minDist) {
      return 100;
    } else {
      return max((100 - logScale * log(dist / minDist)).toInt(), 0);
    }
  }

  void setOtherVolumes(Map<int, double> dists) {
    for (int uidKey in dists.keys) {
      if (uidKey != uid) {
        agoraEngine.adjustUserPlaybackSignalVolume(
            uid: uidKey, volume: getVolumeFromDist(dists[uidKey]));
      }
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
      setOtherVolumes(remoteUsers);
    });
  }

  Icon muteIcon = Icon(Icons.mic);
  Color micCol = Color.fromARGB(255, 90, 80, 80);
  bool muteState = false;

  void _changeMute() {
    setState(() {
      muteState = !muteState;
      if (muteState) {
        muteIcon = Icon(Icons.mic_off);
        micCol = Color.fromARGB(255, 214, 39, 59);
      } else {
        muteIcon = Icon(Icons.mic);
        micCol = Color.fromARGB(255, 90, 80, 80);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Proximity Chat"),
      ),
      floatingActionButton: Wrap(
        //will break to another line on overflow
        direction: Axis.vertical, //use vertical to show  on vertical axis
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () {
                  join();
                },
                tooltip: 'Call Joined!',
                heroTag: "join",
                backgroundColor: const Color.fromARGB(255, 30, 113, 196),
                child: const Icon(Icons.local_phone_rounded),
              )), //button first

          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: _changeMute,
                tooltip: 'Mute!',
                heroTag: "mute",
                backgroundColor: micCol,
                child: muteIcon,
              )), // button second
        ],
      ),
    );
  }
}
