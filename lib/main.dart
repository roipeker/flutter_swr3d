import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'renderer.dart';
import 'swr/swr.dart';

void main() {
  runApp(const MyApp());
}

final rootKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootKey,
      title: '3D Software Render',
      // debugShowCheckedModeBanner: false,
      home: const AppPage(),
    );
  }
}

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  late final ticker = createTicker(_onTick);
  final renderer = MyRenderer();
  final keyboardFocus = FocusNode();

  @override
  void initState() {
    ticker.start();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      keyboardFocus.requestFocus();
    });
    super.initState();
  }

  void _onTick(Duration e) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: keyboardFocus,
      onKey: (e) {
        if (e is RawKeyUpEvent) {
          final numberKey = e.physicalKey.usbHidUsage - 0x0007001e;
          if (numberKey >= 0 && numberKey < 9) {
            renderer.setQuality(numberKey + 1);
          }
          renderer.input.keyReleased(e.physicalKey);
        } else if (e is RawKeyDownEvent) {
          renderer.input.keyPressed(e.physicalKey);
        }
      },
      child: Listener(
        onPointerDown: (e) => renderer.input.mousePressed(e.mouseEvent),
        onPointerMove: (e) => renderer.input.mouseMoved(e.mouseEvent),
        onPointerUp: (e) => renderer.input.mouseReleased(e.mouseEvent),
        child: Scaffold(
          backgroundColor: const Color(0xff000000),
          body: SizedBox.expand(
            child: FittedBox(
              child: CustomPaint(
                size: renderer.canvasSize,
                painter: renderer.painter,
                willChange: true,
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(6),
            color: Colors.grey.shade800,
            child: Row(
              children: [
                const FlutterLogo(size: 12),
                Text(
                  ' 3d software render.  cam transform: ARROWS and A W S D - Bitmap $bitmapTextSize',
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get bitmapTextSize {
    final size = 128 * renderer.getQuality();
    return '$size x $size';
  }
}

extension PointerEventExt on PointerEvent {
  MouseEvent get mouseEvent {
    return MouseEvent(localPosition.dx, localPosition.dy, buttons);
  }
}
