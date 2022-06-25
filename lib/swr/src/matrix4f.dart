part of swr;

typedef MatrixValues = List<List<double>>;

/// A Matrix4 that uses floats (double) components.
class Matrix4f {
  MatrixValues m = [
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
  ];

  Matrix4f();

  Matrix4f initIdentity() {
    m[0][0] = 1;
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = 0;
    m[1][0] = 0;
    m[1][1] = 1;
    m[1][2] = 0;
    m[1][3] = 0;
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = 1;
    m[2][3] = 0;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;
    return this;
  }

  Matrix4f initScreenSpaceTransform(double halfWidth, double halfHeight) {
    m[0][0] = halfWidth;
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = halfWidth - 0.5;
    m[1][0] = 0;
    m[1][1] = -halfHeight;
    m[1][2] = 0;
    m[1][3] = halfHeight - 0.5;
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = 1;
    m[2][3] = 0;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  Matrix4f initTranslation(double x, double y, double z) {
    m[0][0] = 1;
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = x;
    m[1][0] = 0;
    m[1][1] = 1;
    m[1][2] = 0;
    m[1][3] = y;
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = 1;
    m[2][3] = z;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  Matrix4f initScale(double x, double y, double z) {
    m[0][0] = x;
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = 0;
    m[1][0] = 0;
    m[1][1] = y;
    m[1][2] = 0;
    m[1][3] = 0;
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = z;
    m[2][3] = 0;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  Matrix4f initPerspective(
    double fov,
    double aspectRatio,
    double zNear,
    double zFar,
  ) {
    double tanHalfFOV = math.tan(fov / 2);
    double zRange = zNear - zFar;

    m[0][0] = 1.0 / (tanHalfFOV * aspectRatio);
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = 0;

    ///
    m[1][0] = 0;
    m[1][1] = 1.0 / tanHalfFOV;
    m[1][2] = 0;
    m[1][3] = 0;

    ///
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = (-zNear - zFar) / zRange;
    m[2][3] = 2 * zFar * zNear / zRange; //
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 1;
    m[3][3] = 0;

    return this;
  }

  Matrix4f initOrthographic(
    double left,
    double right,
    double bottom,
    double top,
    double near,
    double far,
  ) {
    double width = right - left;
    double height = top - bottom;
    double depth = far - near;

    m[0][0] = 2 / width;
    m[0][1] = 0;
    m[0][2] = 0;
    m[0][3] = -(right + left) / width;
    m[1][0] = 0;
    m[1][1] = 2 / height;
    m[1][2] = 0;
    m[1][3] = -(top + bottom) / height;
    m[2][0] = 0;
    m[2][1] = 0;
    m[2][2] = -2 / depth;
    m[2][3] = -(far + near) / depth;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  /// To keep legacy implementation
  Matrix4f initRotation(Object a, Object b, [Object? c, Object? d]) {
    if (a is Vector4f && b is Vector4f) {
      if (d == null) {
        return initRotationByForwardUp(a, b);
      } else {
        return initRotationByForwardUpRight(a, b, c as Vector4f);
      }
    } else if (a is double && b is double && c is double) {
      if (d == null) {
        return initRotationByXYZ(a, b, c);
      } else {
        return initRotationByXYZAngle(a, b, c, d as double);
      }
    } else {
      throw Exception(
          "Unsupported argument Type ${a.runtimeType}. Use Vector4f or double instead");
    }
  }

  Matrix4f initRotationByXYZAngle(double x, double y, double z, double angle) {
    double sin = math.sin(angle);
    double cos = math.cos(angle);

    m[0][0] = cos + x * x * (1 - cos);
    m[0][1] = x * y * (1 - cos) - z * sin;
    m[0][2] = x * z * (1 - cos) + y * sin;
    m[0][3] = 0;
    m[1][0] = y * x * (1 - cos) + z * sin;
    m[1][1] = cos + y * y * (1 - cos);
    m[1][2] = y * z * (1 - cos) - x * sin;
    m[1][3] = 0;
    m[2][0] = z * x * (1 - cos) - y * sin;
    m[2][1] = z * y * (1 - cos) + x * sin;
    m[2][2] = cos + z * z * (1 - cos);
    m[2][3] = 0;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  Matrix4f initRotationByXYZ(double x, double y, double z) {
    Matrix4f rx = Matrix4f();
    Matrix4f ry = Matrix4f();
    Matrix4f rz = Matrix4f();

    rz.m[0][0] = math.cos(z);
    rz.m[0][1] = -math.sin(z);
    rz.m[0][2] = 0;
    rz.m[0][3] = 0;
    rz.m[1][0] = math.sin(z);
    rz.m[1][1] = math.cos(z);
    rz.m[1][2] = 0;
    rz.m[1][3] = 0;
    rz.m[2][0] = 0;
    rz.m[2][1] = 0;
    rz.m[2][2] = 1;
    rz.m[2][3] = 0;
    rz.m[3][0] = 0;
    rz.m[3][1] = 0;
    rz.m[3][2] = 0;
    rz.m[3][3] = 1;

    rx.m[0][0] = 1;
    rx.m[0][1] = 0;
    rx.m[0][2] = 0;
    rx.m[0][3] = 0;
    rx.m[1][0] = 0;
    rx.m[1][1] = math.cos(x);
    rx.m[1][2] = -math.sin(x);
    rx.m[1][3] = 0;
    rx.m[2][0] = 0;
    rx.m[2][1] = math.sin(x);
    rx.m[2][2] = math.cos(x);
    rx.m[2][3] = 0;
    rx.m[3][0] = 0;
    rx.m[3][1] = 0;
    rx.m[3][2] = 0;
    rx.m[3][3] = 1;

    ry.m[0][0] = math.cos(y);
    ry.m[0][1] = 0;
    ry.m[0][2] = -math.sin(y);
    ry.m[0][3] = 0;
    ry.m[1][0] = 0;
    ry.m[1][1] = 1;
    ry.m[1][2] = 0;
    ry.m[1][3] = 0;
    ry.m[2][0] = math.sin(y);
    ry.m[2][1] = 0;
    ry.m[2][2] = math.cos(y);
    ry.m[2][3] = 0;
    ry.m[3][0] = 0;
    ry.m[3][1] = 0;
    ry.m[3][2] = 0;
    ry.m[3][3] = 1;

    m = rz.mul(ry.mul(rx)).getM();

    return this;
  }

  Matrix4f initRotationByForwardUp(Vector4f forward, Vector4f up) {
    Vector4f f = forward.normalized();

    Vector4f r = up.normalized();
    r = r.cross(f);

    Vector4f u = f.cross(r);

    return initRotationByForwardUpRight(f, u, r);
  }

  Matrix4f initRotationByForwardUpRight(
    Vector4f forward,
    Vector4f up,
    Vector4f right,
  ) {
    Vector4f f = forward;
    Vector4f r = right;
    Vector4f u = up;

    m[0][0] = r.x;
    m[0][1] = r.y;
    m[0][2] = r.z;
    m[0][3] = 0;
    m[1][0] = u.x;
    m[1][1] = u.y;
    m[1][2] = u.z;
    m[1][3] = 0;
    m[2][0] = f.x;
    m[2][1] = f.y;
    m[2][2] = f.z;
    m[2][3] = 0;
    m[3][0] = 0;
    m[3][1] = 0;
    m[3][2] = 0;
    m[3][3] = 1;

    return this;
  }

  Vector4f transform(Vector4f r) {
    return Vector4f(
        m[0][0] * r.x +
            m[0][1] * r.y +
            m[0][2] * r.z +
            m[0][3] * r.w,
        m[1][0] * r.x +
            m[1][1] * r.y +
            m[1][2] * r.z +
            m[1][3] * r.w,
        m[2][0] * r.x +
            m[2][1] * r.y +
            m[2][2] * r.z +
            m[2][3] * r.w,
        m[3][0] * r.x +
            m[3][1] * r.y +
            m[3][2] * r.z +
            m[3][3] * r.w);
  }

  /// Returns a new Matrix multiplied by `r`.
  Matrix4f mul(Matrix4f r) {
    Matrix4f res = Matrix4f();

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        res.set(
            i,
            j,
            m[i][0] * r.get(0, j) +
                m[i][1] * r.get(1, j) +
                m[i][2] * r.get(2, j) +
                m[i][3] * r.get(3, j));
      }
    }

    return res;
  }

  MatrixValues getM() {
    return m.map((e) => List<double>.of(e)).toList(growable: false);
  }

  // float[][] GetM()
  // {
  //   float[][] res = float[4][4];
  //
  //   for(int i = 0; i < 4; i++)
  //     for(int j = 0; j < 4; j++)
  //       res[i][j] = m[i][j];
  //
  //   return res;
  // }

  /// Returns the matrix component @ x,y.
  double get(int x, int y) {
    return m[x][y];
  }

  /// Overrides this matrix contents with `value`.
  void setM(MatrixValues value) {
    // m.clear();
    // m.setAll(0, value);
    m = value;
  }

  /// Defines a single component value.
  void set(int x, int y, double value) {
    m[x][y] = value;
  }
}
