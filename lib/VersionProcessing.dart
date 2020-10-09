
import 'package:mysql1/mysql1.dart';

import 'FirebaseMessage.dart';
import 'dart:convert';
import 'dart:math';

class VersionProcessing {
  VersionProcessing(this.props, this.conn);
  final List props;
  final MySqlConnection conn;

  
  dynamic execute() async{}
  
}

class VersionRouter{
  VersionRouter(this.version);
  final VersionProcessing version; 
}

class BaseVersion extends VersionProcessing{
  BaseVersion(List props,MySqlConnection conn):super(props,conn);

  @override
  dynamic execute() async{
    if (props[1]=="match"){
      final Results results = await conn.query("SELECT * FROM `key` WHERE object_id=? and id=?;",[props[2],props[3]]);
      if (results.isEmpty){
        props[1]="unmatch";
        try{
        await conn.query("INSERT INTO move VALUES(null,?,?,?,?,?,default,?)",props);
        }
        catch (e){
          print(e);
        }
      }else{

        try {
          updateAvailableKeys(conn,props[3] as int,props[0] as int,props[4] as String);
        } on Exception catch (e) { print(e);}
      }
      
      final Results idResults = await conn.query("SELECT id FROM move ORDER BY id DESC limit 2");
      int lastMove = 0;
      int currentMove = 0;
  
      if (idResults.isNotEmpty){
        currentMove=idResults.elementAt(0)[0] as int;
        if (idResults.length ==2) 
          lastMove=idResults.elementAt(1)[0] as int;
      }

      print(currentMove.toString() + " " + lastMove.toString());

      final Map body={"session":props[0],"type":props[1],"objectId":props[2],"keyId":props[3],"userId":props[4],"currentMoveId":currentMove,"lastMoveId":lastMove,"position":props[5]};
    
      await FirebaseMessage(body:json.encode(body),session:"session1").send();
    }
  }
  
  void updateAvailableKeys(MySqlConnection conn, int keyId,  int sessionId, String  userId) async{
    try {
      final Results usersAffected = await conn.query("select user_id from key_user where key_id = ?;",[keyId]);
      final rng = Random();
      usersAffected.forEach((usersAffectedRow) async{
        final Results assignableKeys = await conn.query(''' SELECT id from `key` where game_version_id = (select game_version from session where id = ?) and id not in (SELECT key_id from key_user where user_id=? and session=?) and 
        id not in (SELECT m1.key_id from move m1 LEFT JOIN move m2 on (m1.key_id=m2.key_id and m1.id < m2.id and m1.session_id=m2.session_id) where m2.id is null and m1.type ='match' and m1.session_id=?) ''',[sessionId,usersAffectedRow[0],sessionId,sessionId]);
        await conn.query("INSERT INTO key_user VALUES(?,?,?,default)", [assignableKeys.elementAt(rng.nextInt(assignableKeys.length))[0],usersAffectedRow[0],sessionId]);
      });
    } on Exception catch (e) {
          print(e);
    }
  }
}