

import 'dart:typed_data';

import 'package:aqueduct/aqueduct.dart';
import 'package:server_side/server_side.dart';

class ImageController extends ResourceController {
  
  @Operation.get('name')
  Future<Response> imageFetch(@Bind.path('name') String imageName) async {
    final String path = "assets/images/$imageName";
    final Uint8List image = await File(path).readAsBytes();
    return Response.ok(image)..contentType=ContentType.binary;
  }
}

