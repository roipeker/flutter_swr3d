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

  double getX() => _x;

  int getYStart() => _yStart;

  int getYEnd() => _yEnd;

  double getTexCoordX() => _texCoordX;

  double getTexCoordY() => _texCoordY;

  double getOneOverZ() => _oneOverZ;

  double getDepth() => _depth;

  double getLightAmt() => _lightAmt;

  Edge(
    Gradients gradients,
    Vertex minYVert,
    Vertex maxYVert,
    int minYVertIndex,
  ) {
    _yStart = minYVert.getY().ceil();
    _yEnd = maxYVert.getY().ceil();

    final yDist = maxYVert.getY() - minYVert.getY();
    final xDist = maxYVert.getX() - minYVert.getX();

    final yPrestep = _yStart - minYVert.getY();
    _xStep = xDist / yDist;
    _x = minYVert.getX() + yPrestep * _xStep;

    final xPrestep = _x - minYVert.getX();

    _texCoordX = gradients.getTexCoordX(minYVertIndex) +
        gradients.getTexCoordXXStep() * xPrestep +
        gradients.getTexCoordXYStep() * yPrestep;

    _texCoordXStep =
        gradients.getTexCoordXYStep() + gradients.getTexCoordXXStep() * _xStep;

    _texCoordY = gradients.getTexCoordY(minYVertIndex) +
        gradients.getTexCoordYXStep() * xPrestep +
        gradients.getTexCoordYYStep() * yPrestep;

    _texCoordYStep =
        gradients.getTexCoordYYStep() + gradients.getTexCoordYXStep() * _xStep;

    _oneOverZ = gradients.getOneOverZ(minYVertIndex) +
        gradients.getOneOverZXStep() * xPrestep +
        gradients.getOneOverZYStep() * yPrestep;

    _oneOverZStep =
        gradients.getOneOverZYStep() + gradients.getOneOverZXStep() * _xStep;

    _depth = gradients.getDepth(minYVertIndex) +
        gradients.getDepthXStep() * xPrestep +
        gradients.getDepthYStep() * yPrestep;

    _depthStep = gradients.getDepthYStep() + gradients.getDepthXStep() * _xStep;

    _lightAmt = gradients.getLightAmt(minYVertIndex) +
        gradients.getLightAmtXStep() * xPrestep +
        gradients.getLightAmtYStep() * yPrestep;

    _lightAmtStep =
        gradients.getLightAmtYStep() + gradients.getLightAmtXStep() * _xStep;
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
