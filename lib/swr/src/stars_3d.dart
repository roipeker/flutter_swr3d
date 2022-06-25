/// legacy sample code.
part of swr;

final _random = math.Random().nextDouble;

double toRadians(double degrees) => degrees * math.pi / 180.0;

class Stars3D {
  /// How much the stars are spread out in 3D space, on average. */
  double spread;

  /// How quickly the stars move towards the camera */
  double speed;

  /// The star positions on the X axis */
  late final List<double> _starX;

  /// The star positions on the Y axis */
  late final List<double> _starY;

  /// The star positions on the Z axis */
  late final List<double> _starZ;
  Bitmap? bitmap;

  /// Creates a 3D star field in a usable state.
  ///
  /// @param numStars The number of stars in the star field
  /// @param spread   How much the stars spread out, on average.
  /// @param speed    How quickly the stars move towards the camera
  Stars3D(int numStars, this.spread, this.speed) {
    // _spread = spread;
    _starX = List.filled(numStars, 0);
    _starY = List.filled(numStars, 0);
    _starZ = List.filled(numStars, 0);

    for (int i = 0; i < _starX.length; i++) {
      initStar(i);
    }
    // _bitmap = Bitmap("./res/bricks.jpg");
  }

  /// Initializes a star to a pseudo-random location in 3D space.
  ///
  /// @param i The index of the star to initialize.
  void initStar(int i) {
    //The random values have 0.5 subtracted from them and are multiplied
    //by 2 to remap them from the range (0, 1) to (-1, 1).
    _starX[i] = 2 * (_random() - 0.5) * spread;
    _starY[i] = 2 * (_random() - 0.5) * spread;
//For Z, the random value is only adjusted by a small amount to stop
//a star from being generated at 0 on Z.
    _starZ[i] = (_random() + 0.00001) * spread;
  }

  /// Updates every star to a position, and draws the starfield in a
  /// bitmap.
  ///
  /// @param target The bitmap to render to.
  /// @param delta  How much time has passed since the last update.
  void updateAndRender(RenderContext target, double delta) {
    // if (bitmap != null) {
    //   target.Clear(0x80);
    //   for (var i = 0; i < 200; ++i) {
    //     for (var j = 0; j < 200; ++j) {
    //       target.CopyPixel(i, j, i, j, bitmap!, 1.0);
    //     }
    //   }
    //   return;
    // }

    final double tanHalfFOV = math.tan(toRadians(90.0 / 2.0));
    //Stars are drawn on a black background
    target.clear(0x80);

    double halfWidth = target.getWidth() / 2.0;
    double halfHeight = target.getHeight() / 2.0;
    int triangleBuilderCounter = 0;

    int x1 = 0;
    int y1 = 0;
    int x2 = 0;
    int y2 = 0;
    for (int i = 0; i < _starX.length; i++) {
      //Update the Star.

      //Move the star towards the camera which is at 0 on Z.
      _starZ[i] -= delta * speed;

      //If star is at or behind the camera, generate a position for
      //it.
      if (_starZ[i] <= 0) {
        initStar(i);
      }

      //Render the Star.

      //Multiplying the position by (size/2) and then adding (size/2)
      //remaps the positions from range (-1, 1) to (0, size)

      //Division by z*tanHalfFOV moves things in to create a perspective effect.
      int x = ((_starX[i] / (_starZ[i] * tanHalfFOV)) * halfWidth + halfWidth)
          .floor();
      int y = ((_starY[i] / (_starZ[i] * tanHalfFOV)) * halfHeight + halfHeight)
          .floor();
//
//			int x = ((_starX[i]) * halfWidth + halfWidth).floor();
//			int y = ((_starY[i]) * halfHeight + halfHeight).floor();

      //If the star is not within range of the screen, then generate a
      //position for it.
      if (x < 0 ||
          x >= target.getWidth() ||
          (y < 0 || y >= target.getHeight())) {
        initStar(i);
        continue;
      } else {
        //Otherwise, it is safe to draw this star to the screen.
        // target.DrawPixel(x, y, 0xFF, 0xFF, 0xFF, 0xFF);
      }

      triangleBuilderCounter++;
      if (triangleBuilderCounter == 1) {
        x1 = x;
        y1 = y;
      } else if (triangleBuilderCounter == 2) {
        x2 = x;
        y2 = y;
      } else if (triangleBuilderCounter == 3) {
        triangleBuilderCounter = 0;
        Vertex v1 = Vertex(
          Vector4f(x1 / 400 - 1, y1 / 300 - 1, 0, 1),
          const Vector4f(1, 0, 0, 0),
        );
        Vertex v2 = Vertex(
          Vector4f(x2 / 400 - 1, y2 / 300 - 1, 0, 1),
          const Vector4f(1, 1, 0, 0),
        );
        Vertex v3 = Vertex(
          Vector4f(x / 400 - 1, y / 300 - 1, 0, 1),
          const Vector4f(0, 1, 0, 0),
        );
        if (bitmap != null) {
          target.drawTriangle(v1, v2, v3, bitmap!);
        }
      }
    }
  }
}
