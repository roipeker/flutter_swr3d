/// 3d Software Renderer concept.
/// Most exposed interface uses methods instead of getters (Java style)
/// as a legacy of the original library.

library swr;

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

part 'src/vector4f.dart';

part 'src/vertex.dart';

part 'src/bitmap.dart';

part 'src/camera.dart';

part 'src/edge.dart';

part 'src/gradients.dart';

part 'src/indexed_model.dart';

part 'src/input.dart';

part 'src/main.dart';

part 'src/matrix4f.dart';

part 'src/mesh.dart';

part 'src/obj_model.dart';

part 'src/quaternion.dart';

part 'src/render_context.dart';

part 'src/stars_3d.dart';

part 'src/transform.dart';
