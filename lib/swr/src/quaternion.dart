part of swr;

class Quaternion {
  late double _x;
  late double _y;
  late double _z;
  late double _w;

  Quaternion(double x, double y, double z, double w) {
    _x = x;
    _y = y;
    _z = z;
    _w = w;
  }

  factory Quaternion.fromAxisAngle(Vector4f axis, double angle) {
    double sinHalfAngle = math.sin(angle / 2);
    double cosHalfAngle = math.cos(angle / 2);
    return Quaternion(
      axis.getX() * sinHalfAngle,
      axis.getY() * sinHalfAngle,
      axis.getZ() * sinHalfAngle,
      cosHalfAngle,
    );
  }

  //From Ken Shoemake's "Quaternion Calculus and Fast Animation" article
  factory Quaternion.fromMatrix4f(Matrix4f rot) {
    double trace = rot.get(0, 0) + rot.get(1, 1) + rot.get(2, 2);
    final obj = Quaternion(0, 0, 0, 0);

    if (trace > 0) {
      double s = 0.5 / math.sqrt(trace + 1.0);
      obj._w = 0.25 / s;
      obj._x = (rot.get(1, 2) - rot.get(2, 1)) * s;
      obj._y = (rot.get(2, 0) - rot.get(0, 2)) * s;
      obj._z = (rot.get(0, 1) - rot.get(1, 0)) * s;
    } else {
      if (rot.get(0, 0) > rot.get(1, 1) && rot.get(0, 0) > rot.get(2, 2)) {
        double s = 2.0 *
            math.sqrt(1.0 + rot.get(0, 0) - rot.get(1, 1) - rot.get(2, 2));
        obj._w = (rot.get(1, 2) - rot.get(2, 1)) / s;
        obj._x = 0.25 * s;
        obj._y = (rot.get(1, 0) + rot.get(0, 1)) / s;
        obj._z = (rot.get(2, 0) + rot.get(0, 2)) / s;
      } else if (rot.get(1, 1) > rot.get(2, 2)) {
        double s = 2.0 *
            math.sqrt(1.0 + rot.get(1, 1) - rot.get(0, 0) - rot.get(2, 2));
        obj._w = (rot.get(2, 0) - rot.get(0, 2)) / s;
        obj._x = (rot.get(1, 0) + rot.get(0, 1)) / s;
        obj._y = 0.25 * s;
        obj._z = (rot.get(2, 1) + rot.get(1, 2)) / s;
      } else {
        double s = 2.0 *
            math.sqrt(1.0 + rot.get(2, 2) - rot.get(0, 0) - rot.get(1, 1));
        obj._w = (rot.get(0, 1) - rot.get(1, 0)) / s;
        obj._x = (rot.get(2, 0) + rot.get(0, 2)) / s;
        obj._y = (rot.get(1, 2) + rot.get(2, 1)) / s;
        obj._z = 0.25 * s;
      }
    }

    final len = math.sqrt(
        obj._x * obj._x + obj._y * obj._y + obj._z * obj._z + obj._w * obj._w);
    obj._x /= len;
    obj._y /= len;
    obj._z /= len;
    obj._w /= len;
    return obj;
  }

  double length() {
    return math.sqrt(_x * _x + _y * _y + _z * _z + _w * _w);
  }

  Quaternion normalized() {
    final len = length();
    return Quaternion(_x / len, _y / len, _z / len, _w / len);
  }

  /// Returns the transposed (or reversed) Quaternion.
  Quaternion conjugate() {
    return Quaternion(-_x, -_y, -_z, _w);
  }

  Quaternion mul(Object r) {
    if (r is double) {
      return mulDouble(r);
    } else if (r is Vector4f) {
      return mulVector4f(r);
    } else {
      return mulQuaternion(r as Quaternion);
    }
  }

  /// We don't have method overload in Dart :(

  Quaternion mulDouble(double r) {
    return Quaternion(_x * r, _y * r, _z * r, _w * r);
  }

  Quaternion mulQuaternion(Quaternion r) {
    double w_ = _w * r.getW() - _x * r.getX() - _y * r.getY() - _z * r.getZ();
    double x_ = _x * r.getW() + _w * r.getX() + _y * r.getZ() - _z * r.getY();
    double y_ = _y * r.getW() + _w * r.getY() + _z * r.getX() - _x * r.getZ();
    double z_ = _z * r.getW() + _w * r.getZ() + _x * r.getY() - _y * r.getX();

    return Quaternion(x_, y_, z_, w_);
  }

  Quaternion mulVector4f(Vector4f r) {
    double w_ = -_x * r.getX() - _y * r.getY() - _z * r.getZ();
    double x_ = _w * r.getX() + _y * r.getZ() - _z * r.getY();
    double y_ = _w * r.getY() + _z * r.getX() - _x * r.getZ();
    double z_ = _w * r.getZ() + _x * r.getY() - _y * r.getX();

    return Quaternion(x_, y_, z_, w_);
  }

  Quaternion sub(Quaternion r) {
    return Quaternion(
        _x - r.getX(), _y - r.getY(), _z - r.getZ(), _w - r.getW());
  }

  Quaternion add(Quaternion r) {
    return Quaternion(
        _x + r.getX(), _y + r.getY(), _z + r.getZ(), _w + r.getW());
  }

  double dot(Quaternion r) {
    return _x * r.getX() + _y * r.getY() + _z * r.getZ() + _w * r.getW();
  }

  Quaternion nlerp(Quaternion dest, double lerpFactor, bool shortest) {
    Quaternion correctedDest = dest;

    if (shortest && dot(dest) < 0) {
      correctedDest =
          Quaternion(-dest.getX(), -dest.getY(), -dest.getZ(), -dest.getW());
    }

    return correctedDest.sub(this).mul(lerpFactor).add(this).normalized();
  }

  Quaternion slerp(Quaternion dest, double lerpFactor, bool shortest) {
    const kEpsilon = 1e3;

    double cos = dot(dest);
    Quaternion correctedDest = dest;

    if (shortest && cos < 0) {
      cos = -cos;
      correctedDest =
          Quaternion(-dest.getX(), -dest.getY(), -dest.getZ(), -dest.getW());
    }

    if (cos.abs() >= 1 - kEpsilon) {
      return nlerp(correctedDest, lerpFactor, false);
    }

    double sin = math.sqrt(1.0 - cos * cos);
    double angle = math.atan2(sin, cos);
    double invSin = 1.0 / sin;

    double srcFactor = math.sin((1.0 - lerpFactor) * angle) * invSin;
    double destFactor = math.sin((lerpFactor) * angle) * invSin;

    return mul(srcFactor).add(correctedDest.mul(destFactor));
  }

  Vector4f getForward() {
    return const Vector4f(0, 0, 1, 1).rotate(this);
  }

  Vector4f getBack() {
    return const Vector4f(0, 0, -1, 1).rotate(this);
  }

  Vector4f getUp() {
    return const Vector4f(0, 1, 0, 1).rotate(this);
  }

  Vector4f getDown() {
    return const Vector4f(0, -1, 0, 1).rotate(this);
  }

  Vector4f getRight() {
    return const Vector4f(1, 0, 0, 1).rotate(this);
  }

  Vector4f getLeft() {
    return const Vector4f(-1, 0, 0, 1).rotate(this);
  }

  double getX() => _x;

  double getY() => _y;

  double getZ() => _z;

  double getW() => _w;

  /// Compares two Quaternions for equality.
  @override
  bool operator ==(Object other) {
    return other is Quaternion &&
        other._x == _x &&
        other._y == _y &&
        other._z == _z &&
        other._w == _w;
  }

  @override
  int get hashCode => hashValues(_x, _y, _z, _w);

  @override
  String toString() =>
      'Quaternion(${_x.toStringAsFixed(1)}, ${_y.toStringAsFixed(1)}, ${_z.toStringAsFixed(1)}, ${_w.toStringAsFixed(1)})';

  // bool equals(Quaternion r) {
  //   return _x == r.getX() && _y == r.getY() && _z == r.getZ() && _w == r.getW();
  // }

  Matrix4f toRotationMatrix() {
    Vector4f forward = Vector4f(
      2.0 * (_x * _z - _w * _y),
      2.0 * (_y * _z + _w * _x),
      1.0 - 2.0 * (_x * _x + _y * _y),
    );
    Vector4f up = Vector4f(
      2.0 * (_x * _y + _w * _z),
      1.0 - 2.0 * (_x * _x + _z * _z),
      2.0 * (_y * _z - _w * _x),
    );
    Vector4f right = Vector4f(
      1.0 - 2.0 * (_y * _y + _z * _z),
      2.0 * (_x * _y - _w * _z),
      2.0 * (_x * _z + _w * _y),
    );
    return Matrix4f().initRotation(forward, up, right);
  }
}
