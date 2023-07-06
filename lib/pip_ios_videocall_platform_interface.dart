import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pip_ios_videocall_method_channel.dart';

abstract class PipIosVideocallPlatform extends PlatformInterface {
  /// Constructs a PipIosVideocallPlatform.
  PipIosVideocallPlatform() : super(token: _token);

  static final Object _token = Object();

  static PipIosVideocallPlatform _instance = MethodChannelPipIosVideocall();

  /// The default instance of [PipIosVideocallPlatform] to use.
  ///
  /// Defaults to [MethodChannelPipIosVideocall].
  static PipIosVideocallPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PipIosVideocallPlatform] when
  /// they register themselves.
  static set instance(PipIosVideocallPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
