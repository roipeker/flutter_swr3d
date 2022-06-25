part of swr;

// import java.awt.event.KeyEvent;
class Camera {
  static const Vector4f yAxis = Vector4f(0, 1, 0);

  Transform get transform => _transform;
  Transform _transform = Transform.empty();

  final Matrix4f _projection;

  Camera(this._projection);

  Matrix4f get viewProjection {
    Matrix4f cameraRotation =
        transform.transformedRot.conjugate().toRotationMatrix();
    Vector4f cameraPos = transform.transformedPos.mul(-1.0);

    Matrix4f cameraTranslation = Matrix4f().initTranslation(
      cameraPos.x,
      cameraPos.y,
      cameraPos.z,
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
      move(transform.rot.forward, movAmt);
    }
    if (input.getKey(KeyData.keyS)) {
      move(transform.rot.forward, -movAmt);
    }
    if (input.getKey(KeyData.keyA)) {
      move(transform.rot.left, movAmt);
    }
    if (input.getKey(KeyData.keyD)) {
      move(transform.rot.right, movAmt);
    }

    if (input.getKey(KeyData.arrowRight)) {
      rotate(yAxis, sensitivityX);
    }
    if (input.getKey(KeyData.arrowLeft)) {
      rotate(yAxis, -sensitivityX);
    }
    if (input.getKey(KeyData.arrowDown)) {
      rotate(transform.rot.right, sensitivityY);
    }
    if (input.getKey(KeyData.arrowUp)) {
      rotate(transform.rot.right, -sensitivityY);
    }
  }

  void move(Vector4f dir, double amt) {
    _transform = _transform.setPos(
      transform.pos.add(dir.mul(amt)),
    );
  }

  void rotate(Vector4f axis, double angle) {
    _transform = _transform.rotate(
      Quaternion.fromAxisAngle(axis, angle),
    );
  }
}
