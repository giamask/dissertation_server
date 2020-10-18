

import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';

import 'FirebaseMessage.dart';

class AdminMessageController extends ResourceController {
  
  AdminMessageController();




  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('text') String text,@Bind.path('session') int sessionId}) async {
    if (text ==null || sessionId==null) 
      return Response.badRequest();
    final Map json = {"type":"notification","text":text,"timestamp":DateTime.now().toLocal().hour.toString() + ":" + DateTime.now().toLocal().minute.toString()};
    await FirebaseMessage(body: jsonEncode(json),session: sessionId.toString()).send();
    return Response.ok([]);
  }
}