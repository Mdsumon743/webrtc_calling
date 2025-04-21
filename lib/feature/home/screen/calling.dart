import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';


class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final _roomIdController = TextEditingController();
  late FirebaseFirestore _firestore;
  DocumentReference? _roomRef;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _firestore = FirebaseFirestore.instance;
    getCameraAndMicPermissions();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }


  Future<bool> getCameraAndMicPermissions() async {

    PermissionStatus cameraStatus = await Permission.camera.request();


    PermissionStatus micStatus = await Permission.microphone.request();


    if (cameraStatus.isGranted && micStatus.isGranted) {
      return true;
    } else {
    
      return false;
    }
  }


  Future<void> _openCamera() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });
    _localStream = stream;
    _localRenderer.srcObject = stream;
  }

  Future<void> _createRoom() async {
    await _openCamera();
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final roomRef = _firestore.collection('rooms').doc();
    _roomRef = roomRef;
    _roomId = roomRef.id;
    _roomIdController.text = _roomId!;

    _peerConnection?.onIceCandidate = (candidate) {
      roomRef.collection('callerCandidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await roomRef.set({'offer': offer.toMap()});

    roomRef.snapshots().listen((snapshot) async {
      if (snapshot.data()?['answer'] != null && (await _peerConnection?.getRemoteDescription()) == null) {
        final answer = snapshot.data()!['answer'];
        final description = RTCSessionDescription(answer['sdp'], answer['type']);
        await _peerConnection?.setRemoteDescription(description);
      }
    });

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          ));
        }
      }
    });
  }

  Future<void> _joinRoom() async {
    await _openCamera();
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final roomRef = _firestore.collection('rooms').doc(_roomIdController.text);
    _roomRef = roomRef;

    _peerConnection?.onIceCandidate = (candidate) {
      roomRef.collection('calleeCandidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    final roomSnapshot = await roomRef.get();
    final data = roomSnapshot.data();
    if (data == null || data['offer'] == null) return;

    final offer = data['offer'];
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await roomRef.update({'answer': answer.toMap()});

    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('WebRTC Video Call'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
         
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),

       
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RTCVideoView(_remoteRenderer),
              ),
            ),

            TextField(
              controller: _roomIdController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter Room ID',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Create Room'),
                ),
                ElevatedButton.icon(
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Join Room'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
