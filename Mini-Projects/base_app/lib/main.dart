import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

// class CallJoinPage extends StatelessWidget {
//   const CallJoinPage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text("Call is Joined!"),
//             // Text(
//             //   '$_counter',
//             //   style: Theme.of(context).textTheme.headlineMedium,
//             // ),
//             FloatingActionButton(
//               onPressed: () {},
//               tooltip: 'Call Joined!',
//               backgroundColor: const Color.fromARGB(255, 30, 113, 196),
//               child: const Icon(Icons.local_phone_rounded),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class CallJoinPage extends StatefulWidget {
  CallJoinPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _CallJoinPageState createState() => _CallJoinPageState();
}

class _CallJoinPageState extends State<CallJoinPage> {
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
                onPressed: () {},
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
