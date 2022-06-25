part of swr;

class Vertex {
  late Vector4f _pos;
  late Vector4f _texCoords;
  late Vector4f _normal;

  double getX() => _pos.getX();

  double getY() => _pos.getY();

  Vector4f getPosition() => _pos;

  Vector4f getTexCoords() => _texCoords;

  Vector4f getNormal() => _normal;

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
        _pos.getX() / _pos.getW(),
        _pos.getY() / _pos.getW(),
        _pos.getZ() / _pos.getW(),
        _pos.getW(),
      ),
      _texCoords,
      _normal,
    );
  }

  double triangleAreaTimesTwo(Vertex b, Vertex c) {
    double x1 = b.getX() - _pos.getX();
    double y1 = b.getY() - _pos.getY();

    double x2 = c.getX() - _pos.getX();
    double y2 = c.getY() - _pos.getY();

    return (x1 * y2 - x2 * y1);
  }

  Vertex lerp(Vertex other, double lerpAmt) {
    return Vertex(
      _pos.lerp(other.getPosition(), lerpAmt),
      _texCoords.lerp(other.getTexCoords(), lerpAmt),
      _normal.lerp(other.getNormal(), lerpAmt),
    );
  }

  bool isInsideViewFrustum() {
    return _pos.getX().abs() <= _pos.getW().abs() &&
        _pos.getY().abs() <= _pos.getW().abs() &&
        _pos.getZ().abs() <= _pos.getW().abs();
  }

  double get(int index) {
    switch (index) {
      case 0:
        return _pos.getX();
      case 1:
        return _pos.getY();
      case 2:
        return _pos.getZ();
      case 3:
        return _pos.getW();
      default:
        throw Exception('Index is out of bounds');
    }
  }
}