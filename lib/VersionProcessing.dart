
import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';

import 'FirebaseMessage.dart';
import 'dart:convert';
import 'dart:math';

import 'server_side.dart';

class VersionProcessing {
  VersionProcessing(this.props, this.conn);
  final List props;
  final MySqlConnection conn;

  
  Future<Response> execute() async{}
  
}

class VersionRouter{
  VersionRouter(this.version);
  final VersionProcessing version; 
}

class BaseVersion extends VersionProcessing{
  BaseVersion(List props,MySqlConnection conn):super(props,conn);

  @override
  Future<Response> execute() async{
    if (props[1]=="match"){
      final Results results = await conn.query("SELECT * FROM `key_object` WHERE  object_id=? and key_id=? and game_version_id in (select game_version_id from session where id = ?);",[props[2],props[3],props[0]]);
      if (results.isEmpty){
        props[1]="unmatch";
        try{
          await conn.query("INSERT INTO move VALUES(null,?,?,?,?,?,default,?)",props);
        
        }
        catch (e){
          print(e);
          return Response.ok({"outcome":e.message})..contentType=ContentType.json;
        }
      }else{
        try{
          await conn.query("INSERT INTO move VALUES(null,?,?,?,?,?,default,?)",props);
          updateAvailableKeys(conn,props[3] as int,props[0] as int,props[4] as String);
        }
        catch (e){
          print(e);
          return Response.ok({"outcome":e.message})..contentType=ContentType.json;
        }
      }
        updateScore(props);
        final Results idResults = await conn.query("SELECT id,timestamp FROM move ORDER BY id DESC limit 2");
        int lastMove = 0;
        int currentMove = 0;
        String timestamp ="-";
        if (idResults.isNotEmpty){
          currentMove=idResults.elementAt(0)[0] as int;
          final int hour = (idResults.elementAt(0)[1] as DateTime).toLocal().hour;
          final int minute = (idResults.elementAt(0)[1] as DateTime).toLocal().minute;
          timestamp = (hour<10?"0${hour.toString()}":hour.toString()) +":" + (minute<10?"0${minute.toString()}":minute.toString());
  
          if (idResults.length ==2) 
            lastMove=idResults.elementAt(1)[0] as int;
        }
  
        final Map body={"session":props[0],"type":props[1],"objectId":props[2],"keyId":props[3],"userId":props[4],"currentMoveId":currentMove,"lastMoveId":lastMove,"position":props[5],"timestamp":timestamp};
      
        await FirebaseMessage(body:json.encode(body),session:"session1").send();
        return Response.ok({"outcome":"valid move"})..contentType=ContentType.json;
          }
        }
      
      
        
        void updateAvailableKeys(MySqlConnection conn, int keyId,  int sessionId, String  userId) async{
          try {
            final Results usersAffected = await conn.query("select user_id from key_user where key_id = ?;",[keyId]);
            final rng = Random();
            usersAffected.forEach((usersAffectedRow) async{
              final Results assignableKeys = await conn.query(''' SELECT key_id from `key_object` where game_version_id = (select game_version from session where id = ?) and key_id not in (SELECT key_id from key_user where user_id=? and session=?) and 
              key_id not in (SELECT m1.key_id from move m1 LEFT JOIN move m2 on (m1.key_id=m2.key_id and m1.id < m2.id and m1.session_id=m2.session_id) where m2.id is null and m1.type ='match' and m1.session_id=?) ''',[sessionId,usersAffectedRow[0],sessionId,sessionId]);
              await conn.query("INSERT INTO key_user VALUES(?,?,?,default)", [assignableKeys.elementAt(rng.nextInt(assignableKeys.length))[0],usersAffectedRow[0],sessionId]);
            });
          } on Exception catch (e) {
        
                print(e);
          }
        }
      
        void updateScore(List props) {
          bool add = props[1]=="match";
          conn.query("UPDATE team SET score = score ${add?'+':'-'} (SELECT ${add?'bonus':'penalty'} from gameVersion where id in (SELECT game_version FROM session where id=?) ) where id in (select team_id from team_user where user_id=?) and session_id=? and score >${add?'=':''} 0",[props[0],props[4],props[0]]);
        }
}