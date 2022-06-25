part of swr;

// import java.awt.event.KeyEvent;
class Camera {
  static const Vector4f yAxis = Vector4f(0, 1, 0);

  Transform getTransform() => _transform;
  Transform _transform = Transform.empty();

  final Matrix4f _projection;

  Camera(this._projection);

  Matrix4f getViewProjection() {
    Matrix4f cameraRotation =
        getTransform().getTransformedRot().conjugate().toRotationMatrix();
    Vector4f cameraPos = getTransform().getTransformedPos().mul(-1.0);

    Matrix4f cameraTranslation = Matrix4f().initTranslation(
      cameraPos.getX(),
      cameraPos.getY(),
      cameraPos.getZ(),
    );

    return _projection.mul(cameraRotation.mul(cameraTranslation));
  }

  void update(Input input, double delta) {
    double acceleration =
        (input.getKey(KeyData.shiftLeft) || input.getKey(KeyData.shiftRight))
            ? 3.0
            : 1.0;
    // delta *= acceleration;

    // Speed and rotation amounts are hardcoded here.
    // In a more general system, you might want to have them as variables.
    final double sensitivityX = 2.12 * delta;
    final double sensitivityY = 2.0 * delta;
    final double movAmt = 2.0 * delta * acceleration;

    // Similarly, input keys are hardcoded here.
    // As before, in a more general system, you might want to have these as variables.
    if (input.getKey(KeyData.keyW)) {
      move(getTransform().getRot().getForward(), movAmt);
    }
    if (input.getKey(KeyData.keyS)) {
      move(getTransform().getRot().getForward(), -movAmt);
    }
    if (input.getKey(KeyData.keyA)) {
      move(getTransform().getRot().getLeft(), movAmt);
    }
    if (input.getKey(KeyData.keyD)) {
      move(getTransform().getRot().getRight(), movAmt);
    }

    if (input.getKey(KeyData.arrowRight)) {
      rotate(yAxis, sensitivityX);
    }
    if (input.getKey(KeyData.arrowLeft)) {
      rotate(yAxis, -sensitivityX);
    }
    if (input.getKey(KeyData.arrowDown)) {
      rotate(getTransform().getRot().getRight(), sensitivityY);
    }
    if (input.getKey(KeyData.arrowUp)) {
      rotate(getTransform().getRot().getRight(), -sensitivityY);
    }
  }

  void move(Vector4f dir, double amt) {
    _transform = getTransform().setPos(
      getTransform().getPos().add(dir.mul(amt)),
    );
  }

  void rotate(Vector4f axis, double angle) {
    _transform = getTransform().rotate(
      Quaternion.fromAxisAngle(axis, angle),
    );
  }
}
