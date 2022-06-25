part of swr;

class RenderContext extends Bitmap {
  late List<double> _zBuffer;

  RenderContext(super.width, super.height) {
    _zBuffer = List.filled(_width * _height, double.maxFinite);
  }

  void clearDepthBuffer() {
    for (int i = 0; i < _zBuffer.length; i++) {
      // m_zBuffer[i] = Float.MAX_VALUE;
      _zBuffer[i] = double.maxFinite;
    }
  }

  void drawTriangle(Vertex v1, Vertex v2, Vertex v3, Bitmap texture) {
    if (v1.isInsideViewFrustum() &&
        v2.isInsideViewFrustum() &&
        v3.isInsideViewFrustum()) {
      fillTriangle(v1, v2, v3, texture);
      return;
    }

    List<Vertex> vertices = [];
    List<Vertex> auxiliaryList = [];

    vertices.add(v1);
    vertices.add(v2);
    vertices.add(v3);

    if (clipPolygonAxis(vertices, auxiliaryList, 0) &&
        clipPolygonAxis(vertices, auxiliaryList, 1) &&
        clipPolygonAxis(vertices, auxiliaryList, 2)) {
      Vertex initialVertex = vertices[0];

      for (int i = 1; i < vertices.length - 1; i++) {
        fillTriangle(
          initialVertex,
          vertices[i],
          vertices[i + 1],
          texture,
        );
      }
    }
  }

  bool clipPolygonAxis(
    List<Vertex> vertices,
    List<Vertex> auxillaryList,
    int componentIndex,
  ) {
    clipPolygonComponent(vertices, componentIndex, 1.0, auxillaryList);
    vertices.clear();

    if (auxillaryList.isEmpty) {
      return false;
    }

    clipPolygonComponent(auxillaryList, componentIndex, -1.0, vertices);
    auxillaryList.clear();

    return vertices.isNotEmpty;
  }

  void clipPolygonComponent(
    List<Vertex> vertices,
    int componentIndex,
    double componentFactor,
    List<Vertex> result,
  ) {
    Vertex previousVertex = vertices.last;
    double previousComponent =
        previousVertex.get(componentIndex) * componentFactor;
    bool previousInside =
        previousComponent <= previousVertex.getPosition().getW();

    Iterator<Vertex> it = vertices.iterator;
    while (it.moveNext()) {
      Vertex currentVertex = it.current;
      double currentComponent =
          currentVertex.get(componentIndex) * componentFactor;
      bool currentInside =
          currentComponent <= currentVertex.getPosition().getW();

      if (currentInside ^ previousInside) {
        double lerpAmt =
            (previousVertex.getPosition().getW() - previousComponent) /
                ((previousVertex.getPosition().getW() - previousComponent) -
                    (currentVertex.getPosition().getW() - currentComponent));

        result.add(previousVertex.lerp(currentVertex, lerpAmt));
      }

      if (currentInside) {
        result.add(currentVertex);
      }

      previousVertex = currentVertex;
      previousComponent = currentComponent;
      previousInside = currentInside;
    }
  }

  void fillTriangle(
    Vertex v1,
    Vertex v2,
    Vertex v3,
    Bitmap texture,
  ) {
    Matrix4f screenSpaceTransform =
        Matrix4f().initScreenSpaceTransform(getWidth() / 2, getHeight() / 2);
    Matrix4f identity = Matrix4f().initIdentity();
    Vertex minYVert =
        v1.transform(screenSpaceTransform, identity).perspectiveDivide();
    Vertex midYVert =
        v2.transform(screenSpaceTransform, identity).perspectiveDivide();
    Vertex maxYVert =
        v3.transform(screenSpaceTransform, identity).perspectiveDivide();

    if (minYVert.triangleAreaTimesTwo(maxYVert, midYVert) >= 0) {
      return;
    }

    if (maxYVert.getY() < midYVert.getY()) {
      Vertex temp = maxYVert;
      maxYVert = midYVert;
      midYVert = temp;
    }

    if (midYVert.getY() < minYVert.getY()) {
      Vertex temp = midYVert;
      midYVert = minYVert;
      minYVert = temp;
    }

    if (maxYVert.getY() < midYVert.getY()) {
      Vertex temp = maxYVert;
      maxYVert = midYVert;
      midYVert = temp;
    }

    scanTriangle(minYVert, midYVert, maxYVert,
        minYVert.triangleAreaTimesTwo(maxYVert, midYVert) >= 0, texture);
  }

  void scanTriangle(
    Vertex minYVert,
    Vertex midYVert,
    Vertex maxYVert,
    bool handedness,
    Bitmap texture,
  ) {
    Gradients gradients = Gradients(minYVert, midYVert, maxYVert);
    Edge topToBottom = Edge(gradients, minYVert, maxYVert, 0);
    Edge topToMiddle = Edge(gradients, minYVert, midYVert, 0);
    Edge middleToBottom = Edge(gradients, midYVert, maxYVert, 1);
    scanEdges(gradients, topToBottom, topToMiddle, handedness, texture);
    scanEdges(gradients, topToBottom, middleToBottom, handedness, texture);
  }

  void scanEdges(
    Gradients gradients,
    Edge a,
    Edge b,
    bool handedness,
    Bitmap texture,
  ) {
    Edge left = a;
    Edge right = b;
    if (handedness) {
      Edge temp = left;
      left = right;
      right = temp;
    }

    int yStart = b.getYStart();
    int yEnd = b.getYEnd();
    for (int j = yStart; j < yEnd; j++) {
      drawScanLine(gradients, left, right, j, texture);
      left.step();
      right.step();
    }
  }

  void drawScanLine(
    Gradients gradients,
    Edge left,
    Edge right,
    int j,
    Bitmap texture,
  ) {
    int xMin = left.getX().ceil();
    int xMax = right.getX().ceil();
    double xPrestep = xMin - left.getX();

//		double xDist = right.GetX() - left.GetX();
//		double texCoordXXStep = (right.GetTexCoordX() - left.GetTexCoordX())/xDist;
//		double texCoordYXStep = (right.GetTexCoordY() - left.GetTexCoordY())/xDist;
//		double oneOverZXStep = (right.GetOneOverZ() - left.GetOneOverZ())/xDist;
//		double depthXStep = (right.GetDepth() - left.GetDepth())/xDist;

    // Apparently, now that stepping is actually on pixel centers, gradients are
    // precise enough again.
    double texCoordXXStep = gradients.getTexCoordXXStep();
    double texCoordYXStep = gradients.getTexCoordYXStep();
    double oneOverZXStep = gradients.getOneOverZXStep();
    double depthXStep = gradients.getDepthXStep();
    double lightAmtXStep = gradients.getLightAmtXStep();

    double texCoordX = left.getTexCoordX() + texCoordXXStep * xPrestep;
    double texCoordY = left.getTexCoordY() + texCoordYXStep * xPrestep;
    double oneOverZ = left.getOneOverZ() + oneOverZXStep * xPrestep;
    double depth = left.getDepth() + depthXStep * xPrestep;
    double lightAmt = left.getLightAmt() + lightAmtXStep * xPrestep;
    for (int i = xMin; i < xMax; i++) {
      int index = i + j * getWidth();
      if (depth < _zBuffer[index]) {
        _zBuffer[index] = depth;
        double z = 1.0 / oneOverZ;
        int srcX = ((texCoordX * z) * (texture.getWidth() - 1) + 0.5).toInt();
        int srcY = ((texCoordY * z) * (texture.getHeight() - 1) + 0.5).toInt();
        copyPixel(i, j, srcX, srcY, texture, lightAmt);
      }

      oneOverZ += oneOverZXStep;
      texCoordX += texCoordXXStep;
      texCoordY += texCoordYXStep;
      depth += depthXStep;
      lightAmt += lightAmtXStep;
    }
  }
}
