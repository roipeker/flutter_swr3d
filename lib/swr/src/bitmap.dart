part of swr;

class Bitmap {
  // The width, in pixels, of the image
  final int _width;

  // The height, in pixels, of the image
  final int _height;

  // Every pixel component in the image
  late final List<int> _components;

  Image? _lastFrame;
  final imagePaint = Paint();

  int getWidth() => _width;

  int getHeight() => _height;

  int getComponent(int index) {
    if (index >= _components.length) {
      return 0x0;
    }
    return _components[index];
  }

  /// Creates and initializes a Bitmap.
  ///
  /// @param width The width, in pixels, of the image.
  /// @param height The height, in pixels, of the image.
  Bitmap(this._width, this._height) {
    _components = List.filled(_width * _height * 4, 0);
  }

  Future<void> copyImage(Image img) async {
    final data2 = await img.toByteData(format: ImageByteFormat.rawRgba);
    final pixelData = data2!.buffer.asUint8List();
    _components.setAll(0, pixelData);
    // for (int i = 0; i < pixelData.length; i++) {
    //   _components[i] = pixelData[i];
    // }
  }

  /// Sets every pixel in the bitmap to a specific shade of grey
  /// (0 is black, 255 is white)
  void clear(int shade) {
    _components.fillRange(0, _components.length, shade);
    // Arrays.fill(m_components, shade);
  }

  void render() {
    _captureBitmap();
  }

  void _captureBitmap() {
    final ints = Uint8List.fromList(_components);
    decodeImageFromPixels(ints, _width, _height, PixelFormat.rgba8888, (image) {
      _lastFrame = image;
    });
  }

  void paint(Canvas canvas) {
    if (_lastFrame == null) {
      return;
    }
    canvas.drawImage(_lastFrame!, Offset.zero, imagePaint);
  }

  /// Sets the pixel at (x, y) to the color specified by (a,b,g,r).
  ///
  /// @param x Pixel location in X
  /// @param y Pixel location in Y
  /// @param a Alpha component
  /// @param b Blue component
  /// @param g Green component
  /// @param r Red component
  ///
  void drawPixel(int x, int y, int a, int b, int g, int r) {
    int index = (x + y * _width) * 4;
    _components[index] = a;
    _components[index + 1] = b;
    _components[index + 2] = g;
    _components[index + 3] = r;
  }

  void copyPixel(
    int destX,
    int destY,
    int srcX,
    int srcY,
    Bitmap src,
    double lightAmt,
  ) {
    int destIndex = (destX + destY * _width) * 4;
    int srcIndex = (srcX + srcY * src.getWidth()) * 4;
    if (destIndex < 0 || destIndex > _components.length) return;

    // lightAmt = -.2;

    final r = ((src.getComponent(srcIndex) & 0xFF) * lightAmt).floor();
    final g = ((src.getComponent(srcIndex + 1) & 0xFF) * lightAmt).floor();
    final b = ((src.getComponent(srcIndex + 2) & 0xFF) * lightAmt).floor();
    final a = ((src.getComponent(srcIndex + 3) & 0xFF) * lightAmt).floor();
    _components[destIndex] = r;
    _components[destIndex + 1] = g;
    _components[destIndex + 2] = b;
    _components[destIndex + 3] = a;
  }

  /// Copies the Bitmap into a BGRA List<int> (`dest`).
  ///
  void copyTointArray(List<int> dest) {
    for (int i = 0; i < _width * _height; i++) {
      dest[i * 3] = _components[i * 4 + 1];
      dest[i * 3 + 1] = _components[i * 4 + 2];
      dest[i * 3 + 2] = _components[i * 4 + 3];
    }
  }
}

/// TODO : Missing implementation from the port.
///
//   Bitmap.fromPath(String fileName) throws IOException
//   {
//   int width = 0;
//   int height = 0;
//   int[] components = null;
//
//   BufferedImage image = ImageIO.read(new File(fileName));
//
//   width = image.getWidth();
//   height = image.getHeight();
//
//   int imgPixels[] = new int[width * height];
//   image.getRGB(0, 0, width, height, imgPixels, 0, width);
//   components = new int[width * height * 4];
//
//   for(int i = 0; i < width * height; i++)
//   {
//   int pixel = imgPixels[i];
//
//   components[i * 4]     = (int)((pixel >> 24) & 0xFF); // A
//   components[i * 4 + 1] = (int)((pixel      ) & 0xFF); // B
//   components[i * 4 + 2] = (int)((pixel >> 8 ) & 0xFF); // G
//   components[i * 4 + 3] = (int)((pixel >> 16) & 0xFF); // R
//   }
//
//   m_width = width;
//   m_height = height;
//   m_components = components;
// }
