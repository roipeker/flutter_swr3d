part of swr;

class Edge {
  late double _x;
  late double _xStep;
  late int _yStart;
  late int _yEnd;
  late double _texCoordX;
  late double _texCoordXStep;
  late double _texCoordY;
  late double _texCoordYStep;
  late double _oneOverZ;
  late double _oneOverZStep;
  late double _depth;
  late double _depthStep;
  late double _lightAmt;
  late double _lightAmtStep;

  double get x => _x;

  int get yStart => _yStart;

  int get yEnd => _yEnd;

  double get texCoordX => _texCoordX;

  double get texCoordY => _texCoordY;

  double get oneOverZ => _oneOverZ;

  double get depth => _depth;

  double get lightAmt => _lightAmt;

  Edge(
    Gradients gradients,
    Vertex minYVert,
    Vertex maxYVert,
    int minYVertIndex,
  ) {
    _yStart = minYVert.y.ceil();
    _yEnd = maxYVert.y.ceil();

    final yDist = maxYVert.y - minYVert.y;
    final xDist = maxYVert.x - minYVert.x;

    final yPrestep = _yStart - minYVert.y;
    _xStep = xDist / yDist;
    _x = minYVert.x + yPrestep * _xStep;

    final xPrestep = _x - minYVert.x;

    _texCoordX = gradients.getTexCoordX(minYVertIndex) +
        gradients.texCoordXXStep * xPrestep +
        gradients.texCoordXYStep * yPrestep;

    _texCoordXStep =
        gradients.texCoordXYStep + gradients.texCoordXXStep * _xStep;

    _texCoordY = gradients.getTexCoordY(minYVertIndex) +
        gradients.texCoordYXStep * xPrestep +
        gradients.texCoordYYStep * yPrestep;

    _texCoordYStep =
        gradients.texCoordYYStep + gradients.texCoordYXStep * _xStep;

    _oneOverZ = gradients.getOneOverZ(minYVertIndex) +
        gradients.oneOverZXStep * xPrestep +
        gradients.oneOverZYStep * yPrestep;

    _oneOverZStep =
        gradients.oneOverZYStep + gradients.oneOverZXStep * _xStep;

    _depth = gradients.getDepth(minYVertIndex) +
        gradients.depthXStep * xPrestep +
        gradients.depthYStep * yPrestep;

    _depthStep = gradients.depthYStep + gradients.depthXStep * _xStep;

    _lightAmt = gradients.getLightAmt(minYVertIndex) +
        gradients.lightAmtXStep * xPrestep +
        gradients.lightAmtYStep * yPrestep;

    _lightAmtStep =
        gradients.lightAmtYStep + gradients.lightAmtXStep * _xStep;
  }

  void step() {
    _x += _xStep;
    _texCoordX += _texCoordXStep;
    _texCoordY += _texCoordYStep;
    _oneOverZ += _oneOverZStep;
    _depth += _depthStep;
    _lightAmt += _lightAmtStep;
  }
}
