

import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';

import 'FirebaseMessage.dart';

class AdminMessageController extends ResourceController {

  
  
  AdminMessageController();



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('text') String text,@Bind.path('session') int sessionId}) async {
    if (text ==null || sessionId==null) 
      return Response.badRequest();
    final int hour=DateTime.now().toLocal().hour;
    final int minute=DateTime.now().toLocal().minute;
    String timestamp = (hour<10?"0${hour.toString()}":hour.toString()) + ":" + (minute<10?"0${minute.toString()}":minute.toString());
    final Map json = {"type":"notification","text":text,"timestamp":timestamp};
    await FirebaseMessage(body: jsonEncode(json),session: sessionId.toString()).send();
    return Response.ok([]);
  }
}