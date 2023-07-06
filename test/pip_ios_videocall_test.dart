import 'package:flutter_test/flutter_test.dart';
import 'package:pip_ios_videocall/pip_ios_videocall.dart';
import 'package:pip_ios_videocall/pip_ios_videocall_platform_interface.dart';
import 'package:pip_ios_videocall/pip_ios_videocall_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPipIosVideocallPlatform
    with MockPlatformInterfaceMixin
    implements PipIosVideocallPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PipIosVideocallPlatform initialPlatform = PipIosVideocallPlatform.instance;

  test('$MethodChannelPipIosVideocall is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPipIosVideocall>());
  });

  test('getPlatformVersion', () async {
    PipIosVideocall pipIosVideocallPlugin = PipIosVideocall();
    MockPipIosVideocallPlatform fakePlatform = MockPipIosVideocallPlatform();
    PipIosVideocallPlatform.instance = fakePlatform;

    expect(await pipIosVideocallPlugin.getPlatformVersion(), '42');
  });
}
