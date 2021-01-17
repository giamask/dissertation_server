
import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
      try{
      Results users = await conn.query('SELECT distinct `user`.id FROM `user` join team_user as tu on tu.user_id=`user`.id join team as t on tu.team_id=t.id join `session` on session_id=`session`.id  where `session`.id=?',[sessionId]);
      Results gameVersion = await conn.query('select game_version from session where id=?',[sessionId]);
      Results keys = await conn.query('SELECT id FROM `key` join key_object on key_id=id where game_version_id=?',[gameVersion.elementAt(0)['game_version']]);
      var rng = Random();
      await Future.forEach( users,(element) async{
        List availableKeys = keys.map((e) => e['id']).toList();
        for (int i=0;i<5;i++){
          final r = rng.nextInt(availableKeys.length);
          await conn.query("INSERT INTO key_user VALUES(?,?,?,default)",[availableKeys[r],element['id'],sessionId]);
          availableKeys.removeAt(r);
      }});
      await conn.query('UPDATE `session` set state = "live" where id=?',[sessionId]);
      }catch(e){
        print(e);
        return Response.badRequest();
      }
      final Map json = {"type":"gameStarted"};
      await FirebaseMessage(body: jsonEncode(json),topic: "availableGames").send();
    }
    if (command == "reset"){
      try{
    
        await conn.query("delete from move where id>0 and session_id=?",[sessionId]);
        await conn.query("delete from key_user where key_id>0 and session=?;",[sessionId]);
        await conn.query("update team set score=0 where id>0 and session_id=?;",[sessionId]);
        await conn.query("UPDATE session SET state=1 where id=?",[sessionId]);
      }
      catch(e){
        return Response.badRequest();
      }
      final Map json = {"type":"gameStarted"};
      await FirebaseMessage(body: jsonEncode(json),topic: "availableGames").send();
    }
    if (command=="lock"){
      await conn.query("UPDATE session SET state=1 where id=?",[sessionId]);
       final Map json = {"type":"gameStarted"};
      await FirebaseMessage(body: jsonEncode(json),topic: "availableGames").send();
    }
     if (command=="unlock"){
      await conn.query("UPDATE session SET state=2 where id=?",[sessionId]);
       final Map json = {"type":"gameStarted"};
      await FirebaseMessage(body: jsonEncode(json),topic: "availableGames").send();
    }

    return Response.ok([]);
  }
}

// This is temporary and not properly implemented