part of swr;

class OBJModel {
  final List<Vector4f> _positions = [];
  final List<Vector4f> _texCoords = [];
  final List<Vector4f> _normals = [];
  final List<OBJIndex> _indices = [];
  final List<String> _materials = [];
  bool _hasTexCoords = false;
  bool _hasNormals = false;

  static List<String> removeEmptyStrings(List<String> data) {
    final result = <String>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i].isNotEmpty) {
        result.add(data[i]);
      }
    }
    return result;
  }

  /// Take a OBJ model String.
  OBJModel(String data) {
    _parseData(data);
  }

  String? _currentMaterialId;

  void _parseData(String data) {
    const ls = LineSplitter();
    final lines = ls.convert(data);
    const dp = double.parse;
    for (final line in lines) {
      var tokens = line.split(' ');
      tokens = removeEmptyStrings(tokens);
      if (tokens.isEmpty || tokens.first == '#') {
        continue;
      } else if (tokens.first == 'usemtl') {
        _currentMaterialId = tokens.skip(1).join(' ');
        _materials.add(_currentMaterialId!);
      } else if (tokens.first == 'v') {
        _positions.add(
          Vector4f(dp(tokens[1]), dp(tokens[2]), dp(tokens[3]), 1),
        );
      } else if (tokens.first == 'vt') {
        _texCoords.add(
          Vector4f(dp(tokens[1]), 1.0 - dp(tokens[2]), 0, 0),
        );
      } else if (tokens.first == 'vn') {
        _normals.add(
          Vector4f(dp(tokens[1]), dp(tokens[2]), dp(tokens[3]), 0),
        );
      } else if (tokens.first == 'f') {
        for (int i = 0; i < tokens.length - 3; i++) {
          _indices.add(parseOBJIndex(tokens[1]));
          _indices.add(parseOBJIndex(tokens[2 + i]));
          _indices.add(parseOBJIndex(tokens[3 + i]));
        }
      }
    }
  }

  IndexedModel toIndexedModel() {
    IndexedModel result = IndexedModel();
    IndexedModel normalModel = IndexedModel();
    var resultIndexMap = <OBJIndex, int>{};
    var normalIndexMap = <int, int>{};
    var indexMap = <int, int>{};

    for (int i = 0; i < _indices.length; i++) {
      OBJIndex currentIndex = _indices[i];

      Vector4f currentPosition = _positions[currentIndex.getVertexIndex()];
      Vector4f currentTexCoord;
      Vector4f currentNormal;

      if (_hasTexCoords) {
        currentTexCoord = _texCoords[currentIndex.getTexCoordIndex()];
      } else {
        currentTexCoord = Vector4f.empty;
      }
      if (_hasNormals) {
        currentNormal = _normals[currentIndex.getNormalIndex()];
      } else {
        currentNormal = Vector4f.empty;
      }
      int? modelVertexIndex = resultIndexMap[currentIndex];
      if (modelVertexIndex == null) {
        modelVertexIndex = result.getPositions().length;
        // resultIndexMap.put(currentIndex, modelVertexIndex);
        resultIndexMap[currentIndex] = modelVertexIndex;

        result.getPositions().add(currentPosition);
        result.getTexCoords().add(currentTexCoord);
        if (_hasNormals) {
          result.getNormals().add(currentNormal);
        }
      }

      int? normalModelIndex = normalIndexMap[currentIndex.getVertexIndex()];

      if (normalModelIndex == null) {
        normalModelIndex = normalModel.getPositions().length;
        normalIndexMap[currentIndex.getVertexIndex()] = normalModelIndex;

        normalModel.getPositions().add(currentPosition);
        normalModel.getTexCoords().add(currentTexCoord);
        normalModel.getNormals().add(currentNormal);
        normalModel.getTangents().add(Vector4f.empty);
      }

      result.getIndices().add(modelVertexIndex);
      normalModel.getIndices().add(normalModelIndex);
      indexMap[modelVertexIndex] = normalModelIndex;
    }

    if (!_hasNormals) {
      normalModel.calcNormals();
      for (int i = 0; i < result.getPositions().length; i++) {
        result.getNormals().add(normalModel.getNormals()[indexMap[i]!]);
      }
    }

    normalModel.calcTangents();

    for (int i = 0; i < result.getPositions().length; i++) {
      result.getTangents().add(normalModel.getTangents()[indexMap[i]!]);
    }

    return result;
  }

  OBJIndex parseOBJIndex(String token) {
    final values = token.split("/");
    final result = OBJIndex();
    result.materialId = _currentMaterialId;
    result.setVertexIndex(int.parse(values[0]) - 1);
    if (values.length > 1) {
      if (values[1].isNotEmpty) {
        _hasTexCoords = true;
        result.setTexCoordIndex(int.parse(values[1]) - 1);
      }
      if (values.length > 2) {
        _hasNormals = true;
        result.setNormalIndex(int.parse(values[2]) - 1);
      }
    }
    return result;
  }
}

class OBJIndex {
  late int _vertexIndex;
  late int _texCoordIndex;
  late int _normalIndex;
  String? materialId;

  int getVertexIndex() {
    return _vertexIndex;
  }

  int getTexCoordIndex() {
    return _texCoordIndex;
  }

  int getNormalIndex() {
    return _normalIndex;
  }

  void setVertexIndex(int val) {
    _vertexIndex = val;
  }

  void setTexCoordIndex(int val) {
    _texCoordIndex = val;
  }

  void setNormalIndex(int val) {
    _normalIndex = val;
  }

  @override
  int get hashCode {
    const int kBase = 17;
    const int kMultiplier = 31;
    int result = kBase;
    result = kMultiplier * result + _vertexIndex;
    result = kMultiplier * result + _texCoordIndex;
    result = kMultiplier * result + _normalIndex;
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (other is! OBJIndex) {
      return false;
    }
    return _vertexIndex == other._vertexIndex &&
        _texCoordIndex == other._texCoordIndex &&
        _normalIndex == other._normalIndex;
  }
}
