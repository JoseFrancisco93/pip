import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pip_ios_videocall/pip_ios_videocall_method_channel.dart';

void main() {
  MethodChannelPipIosVideocall platform = MethodChannelPipIosVideocall();
  const MethodChannel channel = MethodChannel('pip_ios_videocall');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
