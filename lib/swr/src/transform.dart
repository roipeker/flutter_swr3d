part of swr;

class Transform {
  late Vector4f _pos;
  late Quaternion _rot;
  late Vector4f _scale;

  factory Transform.empty() => Transform(Vector4f.empty);

  Transform(Vector4f pos, [Quaternion? rot, Vector4f? scale]) {
    _pos = pos;
    _rot = rot ?? Quaternion(0, 0, 0, 1);
    _scale = scale ?? const Vector4f(1, 1, 1, 1);
  }

  @override
  String toString() {
    return 'Transform{pos: $_pos, rot: $_rot, scale: $_scale}';
  }

  Transform setPos(Vector4f pos) {
    return Transform(pos, _rot, _scale);
  }

  Transform rotate(Quaternion rotation) {
    return Transform(_pos, rotation.mul(_rot).normalized(), _scale);
  }

  Transform lookAt(Vector4f point, Vector4f up) {
    return rotate(getLookAtRotation(point, up));
  }

  Quaternion getLookAtRotation(Vector4f point, Vector4f up) {
    return Quaternion.fromMatrix4f(Matrix4f().initRotation(
      point.sub(_pos).normalized(),
      up,
    ));
  }

  Matrix4f get transformMatrix {
    final translationMatrix = Matrix4f().initTranslation(
      _pos.x,
      _pos.y,
      _pos.z,
    );
    final rotationMatrix = _rot.toRotationMatrix();
    final scaleMatrix = Matrix4f().initScale(
      _scale.x,
      _scale.y,
      _scale.z,
    );
    return translationMatrix.mul(rotationMatrix.mul(scaleMatrix));
  }

  Vector4f get transformedPos => _pos;

  Quaternion get transformedRot => _rot;

  Vector4f get pos => _pos;

  Quaternion get rot => _rot;

  Vector4f get scale => _scale;
}
