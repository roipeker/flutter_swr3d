part of swr;

class Gradients {
  final _oneOverZ = List<double>.filled(3, 0);
  final _texCoordX = List<double>.filled(3, 0);
  final _texCoordY = List<double>.filled(3, 0);
  final _depth = List<double>.filled(3, 0);
  final _lightAmt = List<double>.filled(3, 0);

  late final double texCoordXXStep;
  late final double texCoordXYStep;
  late final double texCoordYXStep;
  late final double texCoordYYStep;
  late final double oneOverZXStep;
  late final double oneOverZYStep;
  late final double depthXStep;
  late final double depthYStep;
  late final double lightAmtXStep;
  late final double lightAmtYStep;

  double getTexCoordX(int loc) => _texCoordX[loc];

  double getTexCoordY(int loc) => _texCoordY[loc];

  double getOneOverZ(int loc) => _oneOverZ[loc];

  double getDepth(int loc) => _depth[loc];

  double getLightAmt(int loc) => _lightAmt[loc];

  double _calcXStep(
    List<double> values,
    Vertex minYVert,
    Vertex midYVert,
    Vertex maxYVert,
    double oneOverdX,
  ) {
    return (((values[1] - values[2]) * (minYVert.y - maxYVert.y)) -
            ((values[0] - values[2]) * (midYVert.y - maxYVert.y))) *
        oneOverdX;
  }

  double _calcYStep(
    List<double> values,
    Vertex minYVert,
    Vertex midYVert,
    Vertex maxYVert,
    double oneOverdY,
  ) {
    return (((values[1] - values[2]) * (minYVert.x - maxYVert.x)) -
            ((values[0] - values[2]) * (midYVert.x - maxYVert.x))) *
        oneOverdY;
  }

  double _saturate(double val) {
    return val.clamp(0.0, 1.0);
  }

  Gradients(Vertex minYVert, Vertex midYVert, Vertex maxYVert) {
    double oneOverdX = 1.0 /
        (((midYVert.x - maxYVert.x) * (minYVert.y - maxYVert.y)) -
            ((minYVert.x - maxYVert.x) * (midYVert.y - maxYVert.y)));

    double oneOverdY = -oneOverdX;

    _depth[0] = minYVert.position.z;
    _depth[1] = midYVert.position.z;
    _depth[2] = maxYVert.position.z;

    Vector4f lightDir = const Vector4f(0, 0, 1);
    _lightAmt[0] = _saturate(minYVert.normal.dot(lightDir)) * 0.9 + 0.1;
    _lightAmt[1] = _saturate(midYVert.normal.dot(lightDir)) * 0.9 + 0.1;
    _lightAmt[2] = _saturate(maxYVert.normal.dot(lightDir)) * 0.9 + 0.1;

    // Note that the W component is the perspective Z value;
    // The Z component is the occlusion Z value
    _oneOverZ[0] = 1.0 / minYVert.position.w;
    _oneOverZ[1] = 1.0 / midYVert.position.w;
    _oneOverZ[2] = 1.0 / maxYVert.position.w;

    _texCoordX[0] = minYVert.texCoords.x * _oneOverZ[0];
    _texCoordX[1] = midYVert.texCoords.x * _oneOverZ[1];
    _texCoordX[2] = maxYVert.texCoords.x * _oneOverZ[2];

    _texCoordY[0] = minYVert.texCoords.y * _oneOverZ[0];
    _texCoordY[1] = midYVert.texCoords.y * _oneOverZ[1];
    _texCoordY[2] = maxYVert.texCoords.y * _oneOverZ[2];

    texCoordXXStep =
        _calcXStep(_texCoordX, minYVert, midYVert, maxYVert, oneOverdX);
    texCoordXYStep =
        _calcYStep(_texCoordX, minYVert, midYVert, maxYVert, oneOverdY);
    texCoordYXStep =
        _calcXStep(_texCoordY, minYVert, midYVert, maxYVert, oneOverdX);
    texCoordYYStep =
        _calcYStep(_texCoordY, minYVert, midYVert, maxYVert, oneOverdY);
    oneOverZXStep =
        _calcXStep(_oneOverZ, minYVert, midYVert, maxYVert, oneOverdX);
    oneOverZYStep =
        _calcYStep(_oneOverZ, minYVert, midYVert, maxYVert, oneOverdY);
    depthXStep = _calcXStep(_depth, minYVert, midYVert, maxYVert, oneOverdX);
    depthYStep = _calcYStep(_depth, minYVert, midYVert, maxYVert, oneOverdY);
    lightAmtXStep =
        _calcXStep(_lightAmt, minYVert, midYVert, maxYVert, oneOverdX);
    lightAmtYStep =
        _calcYStep(_lightAmt, minYVert, midYVert, maxYVert, oneOverdY);
  }
}
