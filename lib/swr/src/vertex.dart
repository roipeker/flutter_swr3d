part of swr;

class Vertex {
  late Vector4f _pos;
  late Vector4f _texCoords;
  late Vector4f _normal;

  double get x => _pos.x;

  double get y => _pos.y;

  Vector4f get position => _pos;

  Vector4f get texCoords => _texCoords;

  Vector4f get normal => _normal;

  /// Creates a new Vertex in a usable state.
  Vertex(Vector4f pos, Vector4f texCoords, [Vector4f normal = Vector4f.empty]) {
    _pos = pos;
    _texCoords = texCoords;
    _normal = normal;
  }

  Vertex transform(Matrix4f transform, Matrix4f normalTransform) {
    // The normalized here is important if you're doing scaling.
    return Vertex(
      transform.transform(_pos),
      _texCoords,
      normalTransform.transform(_normal).normalized(),
    );
  }

  Vertex perspectiveDivide() {
    return Vertex(
      Vector4f(
        _pos.x / _pos.w,
        _pos.y / _pos.w,
        _pos.z / _pos.w,
        _pos.w,
      ),
      _texCoords,
      _normal,
    );
  }

  double triangleAreaTimesTwo(Vertex b, Vertex c) {
    double x1 = b.x - _pos.x;
    double y1 = b.y - _pos.y;

    double x2 = c.x - _pos.x;
    double y2 = c.y - _pos.y;

    return (x1 * y2 - x2 * y1);
  }

  Vertex lerp(Vertex other, double lerpAmt) {
    return Vertex(
      _pos.lerp(other._pos, lerpAmt),
      _texCoords.lerp(other._texCoords, lerpAmt),
      _normal.lerp(other._normal, lerpAmt),
    );
  }

  bool isInsideViewFrustum() {
    return _pos.x.abs() <= _pos.w.abs() &&
        _pos.y.abs() <= _pos.w.abs() &&
        _pos.z.abs() <= _pos.w.abs();
  }

  /// Returns the position value by index.
  double get(int index) {
    switch (index) {
      case 0:
        return _pos.x;
      case 1:
        return _pos.y;
      case 2:
        return _pos.z;
      case 3:
        return _pos.w;
      default:
        throw Exception('Index is out of bounds');
    }
  }

  // TODO: Maybe use storage List like Matrix4.
  double operator [](int index) {
    return _pos[index];
  }
}
