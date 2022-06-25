part of swr;

class Gradients {
  final _oneOverZ = List<double>.filled(3, 0);
  final _texCoordX = List<double>.filled(3, 0);
  final _texCoordY = List<double>.filled(3, 0);
  final _depth = List<double>.filled(3, 0);
  final _lightAmt = List<double>.filled(3, 0);

  late double _texCoordXXStep;
  late double _texCoordXYStep;
  late double _texCoordYXStep;
  late double _texCoordYYStep;
  late double _oneOverZXStep;
  late double _oneOverZYStep;
  late double _depthXStep;
  late double _depthYStep;
  late double _lightAmtXStep;
  late double _lightAmtYStep;

  double getTexCoordX(int loc) => _texCoordX[loc];

  double getTexCoordY(int loc) => _texCoordY[loc];

  double getOneOverZ(int loc) => _oneOverZ[loc];

  double getDepth(int loc) => _depth[loc];

  double getLightAmt(int loc) => _lightAmt[loc];

  double getTexCoordXXStep() => _texCoordXXStep;

  double getTexCoordXYStep() => _texCoordXYStep;

  double getTexCoordYXStep() => _texCoordYXStep;

  double getTexCoordYYStep() => _texCoordYYStep;

  double getOneOverZXStep() => _oneOverZXStep;

  double getOneOverZYStep() => _oneOverZYStep;

  double getDepthXStep() => _depthXStep;

  double getDepthYStep() => _depthYStep;

  double getLightAmtXStep() => _lightAmtXStep;

  double getLightAmtYStep() => _lightAmtYStep;

  double calcXStep(
    List<double> values,
    Vertex minYVert,
    Vertex midYVert,
    Vertex maxYVert,
    double oneOverdX,
  ) {
    return (((values[1] - values[2]) * (minYVert.getY() - maxYVert.getY())) -
            ((values[0] - values[2]) * (midYVert.getY() - maxYVert.getY()))) *
        oneOverdX;
  }

  double calcYStep(
    List<double> values,
    Vertex minYVert,
    Vertex midYVert,
    Vertex maxYVert,
    double oneOverdY,
  ) {
    return (((values[1] - values[2]) * (minYVert.getX() - maxYVert.getX())) -
            ((values[0] - values[2]) * (midYVert.getX() - maxYVert.getX()))) *
        oneOverdY;
  }

  double saturate(double val) {
    if (val > 1.0) {
      return 1.0;
    }
    if (val < 0.0) {
      return 0.0;
    }
    return val;
  }

  Gradients(Vertex minYVert, Vertex midYVert, Vertex maxYVert) {
    double oneOverdX = 1.0 /
        (((midYVert.getX() - maxYVert.getX()) *
                (minYVert.getY() - maxYVert.getY())) -
            ((minYVert.getX() - maxYVert.getX()) *
                (midYVert.getY() - maxYVert.getY())));

    double oneOverdY = -oneOverdX;

    _depth[0] = minYVert.getPosition().getZ();
    _depth[1] = midYVert.getPosition().getZ();
    _depth[2] = maxYVert.getPosition().getZ();

    Vector4f lightDir = const Vector4f(0, 0, 1);
    _lightAmt[0] = saturate(minYVert.getNormal().dot(lightDir)) * 0.9 + 0.1;
    _lightAmt[1] = saturate(midYVert.getNormal().dot(lightDir)) * 0.9 + 0.1;
    _lightAmt[2] = saturate(maxYVert.getNormal().dot(lightDir)) * 0.9 + 0.1;

    // Note that the W component is the perspective Z value;
    // The Z component is the occlusion Z value
    _oneOverZ[0] = 1.0 / minYVert.getPosition().getW();
    _oneOverZ[1] = 1.0 / midYVert.getPosition().getW();
    _oneOverZ[2] = 1.0 / maxYVert.getPosition().getW();

    _texCoordX[0] = minYVert.getTexCoords().getX() * _oneOverZ[0];
    _texCoordX[1] = midYVert.getTexCoords().getX() * _oneOverZ[1];
    _texCoordX[2] = maxYVert.getTexCoords().getX() * _oneOverZ[2];

    _texCoordY[0] = minYVert.getTexCoords().getY() * _oneOverZ[0];
    _texCoordY[1] = midYVert.getTexCoords().getY() * _oneOverZ[1];
    _texCoordY[2] = maxYVert.getTexCoords().getY() * _oneOverZ[2];

    _texCoordXXStep =
        calcXStep(_texCoordX, minYVert, midYVert, maxYVert, oneOverdX);
    _texCoordXYStep =
        calcYStep(_texCoordX, minYVert, midYVert, maxYVert, oneOverdY);
    _texCoordYXStep =
        calcXStep(_texCoordY, minYVert, midYVert, maxYVert, oneOverdX);
    _texCoordYYStep =
        calcYStep(_texCoordY, minYVert, midYVert, maxYVert, oneOverdY);
    _oneOverZXStep =
        calcXStep(_oneOverZ, minYVert, midYVert, maxYVert, oneOverdX);
    _oneOverZYStep =
        calcYStep(_oneOverZ, minYVert, midYVert, maxYVert, oneOverdY);
    _depthXStep = calcXStep(_depth, minYVert, midYVert, maxYVert, oneOverdX);
    _depthYStep = calcYStep(_depth, minYVert, midYVert, maxYVert, oneOverdY);
    _lightAmtXStep =
        calcXStep(_lightAmt, minYVert, midYVert, maxYVert, oneOverdX);
    _lightAmtYStep =
        calcYStep(_lightAmt, minYVert, midYVert, maxYVert, oneOverdY);
  }
}
