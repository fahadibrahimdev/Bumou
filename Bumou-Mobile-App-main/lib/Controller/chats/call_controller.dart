import 'dart:developer';

import 'package:app/Controller/chats/chat_controller.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/src/native/factory_impl.dart' as rtc;

class CallController extends GetxController {
  final String callerId, calleeId;

  CallController({
    required this.callerId,
    required this.calleeId,
  });

  final ChatController _chatController = Get.find<ChatController>();
  // videoRenderer for localPeer
  final localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? localStream;

  // RTC peer connection
  RTCPeerConnection? rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true, isSpeakerOn = true;

  @override
  void onInit() {
    localRTCVideoRenderer.initialize();
    remoteRTCVideoRenderer.initialize();
    setupPeerConnection();
    super.onInit();
  }

  Future<void> setupPeerConnection() async {
    rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302']
        }
      ]
    });

    // listen for remotePeer mediaTrack event
    rtcPeerConnection!.onTrack = (event) {
      remoteRTCVideoRenderer.srcObject = event.streams[0];
      update();
    };

    // get localStream
    localStream = await rtc.navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'} : false,
    });

    localStream!.getTracks().forEach((track) {
      rtcPeerConnection!.addTrack(track, localStream!);
    });
    localRTCVideoRenderer.srcObject = localStream;
    update();

    dynamic offer = _chatController.incomingSDPOffer;
    if (offer != null) {
      //! for incoming call
      _chatController.socket.on("IceCandidate", (data) {
        log("🧊 On -IceCandidate-: $data");
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];
        // add iceCandidate
        rtcPeerConnection?.addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
      });
      await rtcPeerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdpOffer']["sdp"], offer['sdpOffer']["type"]),
      );

      // create SDP answer
      RTCSessionDescription answer = await rtcPeerConnection!.createAnswer();

      // set SDP answer as localDescription for peerConnection
      rtcPeerConnection!.setLocalDescription(answer);
      Map<String, dynamic> answerMap = {
        "callerId": offer["callerId"],
        "calleeId": offer["calleeId"],
        "sdpAnswer": answer.toMap(),
      };
      log("=====> Answer Map: $answerMap");
      // send SDP answer to remote peer over signalling
      _chatController.socket.emit("answerCall", answerMap);
    } else {
      //! for outgoing call
      // listen for local iceCandidate and add it to the list of IceCandidate
      rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);
      // when call is accepted by remote peer
      _chatController.socket.on("callAnswered", (data) async {
        log("📞 Call Answered: $data");
        // set SDP answer as remoteDescription for peerConnection
        await rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        // send iceCandidate generated to remote peer over signalling
        for (RTCIceCandidate candidate in rtcIceCadidates) {
          _chatController.socket.emit("IceCandidate", {
            "calleeId": calleeId,
            "callerId": callerId,
            "iceCandidate": {"id": candidate.sdpMid, "label": candidate.sdpMLineIndex, "candidate": candidate.candidate}
          });
        }
      });

      // create SDP Offer
      RTCSessionDescription offer = await rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      _chatController.socket.emit('makeCall', {
        "calleeId": calleeId,
        "callerId": callerId,
        "sdpOffer": offer.toMap(),
      });
    }
  }

  void leaveCall() {
    _chatController.incomingSDPOffer = null;
    Get.back();
  }

  toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    update();
  }

  toggleSpeaker() {
    // change status
    isSpeakerOn = !isSpeakerOn;
    // enable or disable audio track
    localStream?.getAudioTracks().forEach((track) {
      track.enableSpeakerphone(isSpeakerOn);
    });
    update();
  }

  toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
      print("📷 Camera Enabled: ${track.enabled}");
      print("📷 Camera Enabled: ${track.kind}");
      print("📷 Camera Enabled: ${track.label}");
      print("📷 Camera Enabled: ${track.getSettings()}");
    });
    update();
  }

  switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    update();
  }

  @override
  void onClose() {
    log("Call Controller Closed----------> ");
    _chatController.incomingSDPOffer = null;
    localRTCVideoRenderer.dispose();
    remoteRTCVideoRenderer.dispose();
    rtcPeerConnection?.close();
    super.onClose();
  }

  @override
  void dispose() {
    log("Call Controller Disposed----------> ");
    _chatController.incomingSDPOffer = null;
    localRTCVideoRenderer.dispose();
    remoteRTCVideoRenderer.dispose();
    rtcPeerConnection?.close();
    super.dispose();
  }
}
