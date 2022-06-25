part of swr;

class Mesh {
  late List<Vertex> _vertices;
  late List<int> _indices;

  Mesh(String data) {
    IndexedModel model = OBJModel(data).toIndexedModel();
    _vertices = <Vertex>[];
    final pos = model.getPositions();
    for (int i = 0; i < pos.length; i++) {
      _vertices.add(
        Vertex(
          pos.elementAt(i),
          model.getTexCoords().elementAt(i),
          model.getNormals().elementAt(i),
        ),
      );
    }
    _indices = model.getIndices();
  }

  void draw(
    RenderContext context,
    Matrix4f viewProjection,
    Matrix4f transform,
    Bitmap texture,
  ) {
    Matrix4f mvp = viewProjection.mul(transform);
    for (int i = 0; i < _indices.length; i += 3) {
      final i1 = _indices[i];
      final i2 = _indices[i + 1];
      final i3 = _indices[i + 2];
      context.drawTriangle(
        _vertices[i1].transform(mvp, transform),
        _vertices[i2].transform(mvp, transform),
        _vertices[i3].transform(mvp, transform),
        texture,
      );
    }
  }
}
