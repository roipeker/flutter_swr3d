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

      double deltaU1 = _texCoords[i1].getX() - _texCoords[i0].getX();
      double deltaV1 = _texCoords[i1].getY() - _texCoords[i0].getY();
      double deltaU2 = _texCoords[i2].getX() - _texCoords[i0].getX();
      double deltaV2 = _texCoords[i2].getY() - _texCoords[i0].getY();

      double dividend = (deltaU1 * deltaV2 - deltaU2 * deltaV1);
      double f = dividend == 0 ? 0.0 : 1.0 / dividend;

      Vector4f tangent = Vector4f(
          f * (deltaV2 * edge1.getX() - deltaV1 * edge2.getX()),
          f * (deltaV2 * edge1.getY() - deltaV1 * edge2.getY()),
          f * (deltaV2 * edge1.getZ() - deltaV1 * edge2.getZ()),
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
