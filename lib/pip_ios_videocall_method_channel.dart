import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pip_ios_videocall_platform_interface.dart';

/// An implementation of [PipIosVideocallPlatform] that uses method channels.
class MethodChannelPipIosVideocall extends PipIosVideocallPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pip_ios_videocall');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<void> createPipVideoCall({
    required String remoteStreamId,
    required String peerConnectionId,
    String myAvatar = "https://avatars.githubusercontent.com/u/60530946?v=4",
    bool isRemoteCameraEnable = true,
  }) async {
    await methodChannel.invokeMethod("createPiP", {
      "remoteStreamId": remoteStreamId,
      "peerConnectionId": peerConnectionId,
      "isRemoteCameraEnable": isRemoteCameraEnable,
      "myAvatar": myAvatar,
    });
  }

  Future<void> disposePiP() async {
    await methodChannel.invokeMethod("disposePiP");
  }
}
