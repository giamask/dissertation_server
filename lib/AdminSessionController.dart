

import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:aqueduct/aqueduct.dart';

import 'FirebaseMessage.dart';

class AdminSessionController extends ResourceController {


  final MySqlConnection conn;
  
  AdminSessionController(this.conn);



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('command') String command,@Bind.path('session') int sessionId}) async {
    if (command ==null || sessionId==null) 
      return Response.badRequest();
    if (command=="start"){
      final Map json = {"type":"gameStarted"};
      await FirebaseMessage(body: jsonEncode(json),session: sessionId.toString()).send();
    }
    return Response.ok([]);
  }
}