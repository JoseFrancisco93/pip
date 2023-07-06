
import 'pip_ios_videocall_platform_interface.dart';

class PipIosVideocall {
  Future<String?> getPlatformVersion() {
    return PipIosVideocallPlatform.instance.getPlatformVersion();
  }
}
