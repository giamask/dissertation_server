

import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';

import 'FirebaseMessage.dart';

class AdminMessageController extends ResourceController {

  
  final MySqlConnection conn;
  
  AdminMessageController(this.conn);



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('text') String text,@Bind.path('session') int sessionId}) async {
    if (text ==null || sessionId==null) 
      return Response.badRequest();
    final int hour=DateTime.now().toLocal().hour;
    final int minute=DateTime.now().toLocal().minute;
    String timestamp = (hour<10?"0${hour.toString()}":hour.toString()) + ":" + (minute<10?"0${minute.toString()}":minute.toString());
    
    final Map json = {"type":"notification","text":text,"timestamp":timestamp};
    Results targetUsers = await conn.query("select DISTINCT device_token from user WHERE device_token is not null and id in (select user_id from team_user join team on team_id=id where session_id=?)",[sessionId]);
        await targetUsers.forEach((element) async{ 
          await FirebaseMessage(body: jsonEncode(json),token: element.elementAt(0) as String).send();
        });
    
    return Response.ok([]);
  }
}