part of swr;

class IndexedModel {
  final _positions = <Vector4f>[];
  final _texCoords = <Vector4f>[];
  final _normals = <Vector4f>[];
  final _tangents = <Vector4f>[];
  final _indices = <int>[];

  IndexedModel();

  void calcNormals() {
    for (int i = 0; i < _indices.length; i += 3) {
      int i0 = _indices[i];
      int i1 = _indices[i + 1];
      int i2 = _indices[i + 2];

      Vector4f v1 = _positions[i1].sub(_positions[i0]);
      Vector4f v2 = _positions[i2].sub(_positions[i0]);

      Vector4f normal = v1.cross(v2).normalized();

      _normals[i0] = _normals[i0].add(normal);
      _normals[i1] = _normals[i1].add(normal);
      _normals[i2] = _normals[i2].add(normal);
    }

    for (var i = 0; i < _normals.length; i++) {
      _normals[i] = _normals[i].normalized();
    }
  }

  void calcTangents() {
    for (int i = 0; i < _indices.length; i += 3) {
      int i0 = _indices[i];
      int i1 = _indices[i + 1];
      int i2 = _indices[i + 2];

      Vector4f edge1 = _positions[i1].sub(_positions[i0]);
      Vector4f edge2 = _positions[i2].sub(_positions[i0]);

      double deltaU1 = _texCoords[i1].x - _texCoords[i0].x;
      double deltaV1 = _texCoords[i1].y - _texCoords[i0].y;
      double deltaU2 = _texCoords[i2].x - _texCoords[i0].x;
      double deltaV2 = _texCoords[i2].y - _texCoords[i0].y;

      double dividend = (deltaU1 * deltaV2 - deltaU2 * deltaV1);
      double f = dividend == 0 ? 0.0 : 1.0 / dividend;

      Vector4f tangent = Vector4f(
          f * (deltaV2 * edge1.x - deltaV1 * edge2.x),
          f * (deltaV2 * edge1.y - deltaV1 * edge2.y),
          f * (deltaV2 * edge1.z - deltaV1 * edge2.z),
          0);

      _tangents[i0] = _tangents[i0].add(tangent);
      _tangents[i1] = _tangents[i1].add(tangent);
      _tangents[i2] = _tangents[i2].add(tangent);
    }

    for (int i = 0; i < _tangents.length; i++) {
      _tangents[i] = _tangents[i].normalized();
    }
  }

  /// TODO: implement getters instead.
  List<Vector4f> getPositions() => _positions;

  List<Vector4f> getTexCoords() => _texCoords;

  List<Vector4f> getNormals() => _normals;

  List<Vector4f> getTangents() => _tangents;
  List<int> getIndices() => _indices;
}
