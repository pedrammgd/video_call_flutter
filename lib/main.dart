import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

const appId = 'c7009dfddf01460081a55bb3ba4e3115';
const token =
    '006c7009dfddf01460081a55bb3ba4e3115IAC3ggT+yDSqfqtWLvrE35dHhhaVP1rhxgLBE26guRyp4kD6g3QAAAAAEABUm4+szwSnYgEAAQDOBKdi';
const channelId = 'firstChannel';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _remoteUId;
  late RtcEngine _engine;
  bool muted = false;
  // static final _users = <int>[];

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    // if (Platform.isAndroid) {
    //   await [
    //     Permission.camera,
    //     Permission.microphone,
    //   ].request();
    // }
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();

    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        print('local user $uid joined');
        // setState(() {
        //   _remoteUId = uid;
        // });
      },
      userJoined: (uid, elapsed) {
        print('local user $uid joined');
        setState(() {
          _remoteUId = uid;
          // _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        print('local user $uid left');
        setState(() {
          _remoteUId = null;
          // _users.remove(uid);
        });
      },
    ));

    await _engine.joinChannel(token, channelId, null, 0);
  }

  @override
  void dispose() {
    super.dispose();
    // _users.clear();

    _engine.leaveChannel();
    _engine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        Center(
          // child:
          // ListView.builder(
          //   itemBuilder: (context, index) => _getRenderViews()[index],
          //   itemCount: _users.length,
          // ),

          child: _renderRemoteVideo(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 100,
            height: 100,
            child: Center(child: _renderLocalPreview()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 30),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      _engine.switchCamera();
                    },
                    icon: const Icon(Icons.switch_camera)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      muted = !muted;
                    });

                    _engine.muteLocalAudioStream(muted);
                  },
                  icon: Icon(muted ? Icons.mic_off_rounded : Icons.mic_rounded),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _renderLocalPreview() {
    return const RtcLocalView.SurfaceView(
        // channelId: channelId,
        );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUId != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUId!,
        channelId: channelId,
      );
    } else {
      return const Text('please wait for remote');
    }
  }

  // List<Widget> _getRenderViews() {
  //   final List<Widget> list = [];
  //   // list.add(const RtcLocalView.SurfaceView());
  //   if (_users.isNotEmpty) {
  //     for (var uid in _users) {
  //       list.add(SizedBox(
  //         height: 500,
  //         width: 100,
  //         child: RtcRemoteView.SurfaceView(
  //           uid: uid,
  //           channelId: channelId,
  //         ),
  //       ));
  //     }
  //   }
  //   return list;
  // }
}
