part of swr;

/// A Vector4 that uses floats (double) components.
class Vector4f {
  final double x, y, z, w;

  static const empty = Vector4f(0, 0, 0, 0);

  const Vector4f([this.x = 0, this.y = 0, this.z = 0, this.w = 1]);

  /// Returns the length distance of the Vector.
  double length() {
    return math.sqrt(x * x + y * y + z * z + w * w);
  }

  /// Returns the maximum component value.
  double max() {
    return math.max(math.max(x, y), math.max(z, w));
  }

  /// Returns the dot product of the Vector.
  double dot(Vector4f r) {
    return x * r.x + y * r.y + z * r.z + w * r.w;
  }

  /// Returns the cross product of the Vector.
  Vector4f cross(Vector4f r) {
    double x_ = y * r.z - z * r.y;
    double y_ = z * r.x - x * r.z;
    double z_ = x * r.y - y * r.x;

    return Vector4f(x_, y_, z_, 0);
  }

  /// Gives back the normalized unit Vector.
  Vector4f normalized() {
    final len = length();
    return Vector4f(x / len, y / len, z / len, w / len);
  }

  /// Rotate this Vector4 evaluating the arguments.
  /// If a Quaternion is provided in `a` calls `RotateByQuaternion`
  /// Instead if `a` is a double and angle is provided, `RotateByAxisAngle`
  /// is called.
  Vector4f rotate(Object a, [double? angle]) {
    // assert(a is double && angle!=null,);
    if (a is Quaternion) return rotateByQuaternion(a);
    return rotateByAxisAngle(a as Vector4f, angle!);
  }

  Vector4f rotateByAxisAngle(Vector4f axis, double angle) {
    double sinAngle = math.sin(-angle);
    double cosAngle = math.cos(-angle);
    return cross(axis.mul(sinAngle)).add(//Rotation on local X
        (mul(cosAngle)).add(//Rotation on local Z
            axis.mul(dot(axis.mul(1 - cosAngle))))); //Rotation on local Y
  }

  Vector4f rotateByQuaternion(Quaternion rotation) {
    Quaternion conjugate = rotation.conjugate();
    Quaternion w = rotation.mul(this).mul(conjugate);
    return Vector4f(w.x, w.y, w.z, 1.0);
  }

  /// Returns the linear interpolation of this Vector4 with `dest`, with a ratio
  /// of `lerpFactor`.
  Vector4f lerp(Vector4f dest, double lerpFactor) {
    return dest.sub(this).mul(lerpFactor).add(this);
  }

  // Adds a double or a Vector4f
  Vector4f add(Object r) {
    if (r is double) return addDouble(r);
    return addVector4(r as Vector4f);
  }

  // Subtracts a double or a Vector4f
  Vector4f sub(Object r) {
    if (r is double) return subDouble(r);
    return subVector4(r as Vector4f);
  }

  /// Multiplies to a double or a Vector4f
  Vector4f mul(Object r) {
    if (r is double) return mulDouble(r);
    return mulVector4(r as Vector4f);
  }

  /// Divides to a double or a Vector4f
  Vector4f div(Object r) {
    if (r is double) return divDouble(r);
    return divVector4(r as Vector4f);
  }

  Vector4f addVector4(Vector4f r) {
    return Vector4f(x + r.x, y + r.y, z + r.z, w + r.w);
  }

  Vector4f addDouble(double r) {
    return Vector4f(x + r, y + r, z + r, w + r);
  }

  Vector4f subVector4(Vector4f r) {
    return Vector4f(x - r.x, y - r.y, z - r.z, w - r.w);
  }

  Vector4f subDouble(double r) {
    return Vector4f(x - r, y - r, z - r, w - r);
  }

  Vector4f mulVector4(Vector4f r) {
    return Vector4f(x * r.x, y * r.y, z * r.z, w * r.w);
  }

  Vector4f mulDouble(double r) {
    return Vector4f(x * r, y * r, z * r, w * r);
  }

  Vector4f divVector4(Vector4f r) {
    return Vector4f(x / r.x, y / r.y, z / r.z, w / r.w);
  }

  Vector4f divDouble(double r) {
    return Vector4f(x / r, y / r, z / r, w / r);
  }

  Vector4f abs() {
    return Vector4f(x.abs(), y.abs(), z.abs(), w.abs());
  }

  @override
  String toString() {
    return "($x, $y, $z, $w)";
  }

  // double getX() {
  //   return x;
  // }
  //
  // double getY() {
  //   return y;
  // }
  //
  // double getZ() {
  //   return z;
  // }
  //
  // double getW() {
  //   return w;
  // }

  bool equals(Vector4f r) {
    return x == r.x && y == r.y && z == r.z && w == r.w;
  }

  /// Compares two Vector4f for equality.
  @override
  bool operator ==(Object other) {
    return other is Vector4f &&
        other.x == x &&
        other.y == y &&
        other.z == z &&
        other.w == w;
  }

  @override
  int get hashCode => hashValues(x, y, z, w);

  double operator [](int index) {
    if (index == 0) {
      return x;
    } else if (index == 1) {
      return y;
    } else if (index == 2) {
      return z;
    } else if (index == 3) {
      return w;
    } else {
      throw Exception('Index $index is out of bounds [0...3]');
    }
  }
}
