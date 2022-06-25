/// This "Renderer" is just a simple example of how to use the
/// 3d engine.

import 'package:flutter/material.dart' hide Transform;
import 'package:flutter/services.dart';

import 'swr/swr.dart';

class _Painter extends CustomPainter {
  final void Function(Canvas canvas, Size size) paintCallback;

  _Painter(this.paintCallback);

  @override
  void paint(Canvas canvas, Size size) {
    paintCallback(canvas, size);
  }

  @override
  bool shouldRepaint(oldDelegate) => true;
}

class MyRenderer {
  Size canvasSize = const Size(128, 128);

  CustomPainter get painter => _Painter(paint);
  late RenderContext _frame;
  final input = Input();
  int _quality = 1;

  Mesh? monkeyMesh;
  Mesh? terrainMesh;
  Mesh? foxMesh;
  Mesh? houseMesh;

  late Transform monkeyTransform;
  late Transform terrainTransform;
  late Transform foxTransform;
  late Transform houseTransform;

  late Camera camera;

  late Bitmap brick1Texture;
  late Bitmap brick2Texture;
  late Bitmap foxTexture;

  MyRenderer() {
    _init();
  }

  int getQuality() => _quality;

  void setQuality(int quality) {
    if (_quality == quality) {
      return;
    }
    _quality = quality;
    double size = 128.0 * _quality;
    canvasSize = Size(size, size);
    _initFrame();
  }

  void _initFrame() {
    _frame = RenderContext(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
  }

  void _init() {
    _initFrame();
    camera = Camera(
      Matrix4f().initPerspective(
        toRadians(70),
        _frame.width / _frame.height,
        0.1,
        1000,
      ),
    );

    /// flip camera away from the center.
    camera.move(const Vector4f(0, 0, 1), 6);
    camera.rotate(const Vector4f(0, 1, 0), toRadians(140));

    monkeyTransform = Transform(
      const Vector4f(1, 1.2, 3, 1),
      Quaternion.fromAxisAngle(const Vector4f(1, 0, 0), toRadians(28)),
      const Vector4f(1, 1.5, 1.3, 1),
    );

    terrainTransform = Transform(
      const Vector4f(0, -1, 1.9),
    );

    houseTransform = Transform(
      const Vector4f(0, -1, 12),
    );

    foxTransform = Transform(
      const Vector4f(0.4, -.8, -5.9),
      null,
      /// scale down the fox
      const Vector4f(.1, .1, .1),
    );

    /// load the scene.
    loadAssets();
  }

  Future<Mesh> loadMesh(String objKey) async {
    var modelString = await rootBundle.loadString(objKey);
    return Mesh(modelString);
  }

  Future<Bitmap> loadTexture(String assetKey) async {
    final bytes = await rootBundle.load(assetKey);
    final pixels = bytes.buffer.asUint8List();
    final image = await decodeImageFromList(pixels);
    final bmp = Bitmap(image.width, image.height);
    bmp.copyImage(image);
    image.dispose();
    return bmp;
  }

  Future<void> loadAssets() async {
    brick1Texture = await loadTexture('assets/bricks.jpg');
    brick2Texture = await loadTexture('assets/bricks2.jpg');
    foxTexture = await loadTexture('assets/fox.png');
    monkeyMesh = await loadMesh('assets/smoothMonkey2.obj');
    terrainMesh = await loadMesh('assets/terrain2.obj');
    foxMesh = await loadMesh('assets/fox.obj');
    houseMesh = await loadMesh('assets/House_OBJ.obj');
  }

  void paint(Canvas canvas, Size size) {
    double delta = .02;

    camera.update(input, delta);

    Matrix4f vp = camera.viewProjection;

    monkeyTransform = monkeyTransform.rotate(
      Quaternion.fromAxisAngle(const Vector4f(0, .5, 0), delta),
    );

    _frame.clear(0x0);
    _frame.clearDepthBuffer();

    monkeyMesh?.draw(
      _frame,
      vp,
      monkeyTransform.transformMatrix,
      brick2Texture,
    );

    terrainMesh?.draw(
      _frame,
      vp,
      terrainTransform.transformMatrix,
      brick1Texture,
    );

    foxMesh?.draw(
      _frame,
      vp,
      foxTransform.transformMatrix,
      foxTexture,
    );

    houseMesh?.draw(
      _frame,
      vp,
      houseTransform.transformMatrix,
      brick2Texture,
    );

    _frame.render();
    _frame.paint(canvas);

    /// --- Sample to draw a pixels..
    ///
    // _frame.clear(0x80);
    // _frame.drawPixel(100, 100, 0x00, 0x00, 0x00, 0xFF);
    //
    /// If mouse down....
    // if (input.getMouse(1)) {
    //   _frame.drawPixel(
    //       input.getMouseX(), input.getMouseY(), 0xff, 0x00, 0x00, 0xFF);
    // }
  }
}
