
import 'package:mysql1/mysql1.dart';

import 'FirebaseMessage.dart';
import 'dart:convert';

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
    if (props[1]!="scan"){
      final Results results = await conn.query("SELECT * FROM `key` WHERE object_id=? and id=?;",[props[2],props[3]]);
      if (results.isEmpty){
        props[1]="unmatch";
        await conn.query("INSERT INTO move VALUES(null,?,?,?,?,?,default)",props);
      }
      
      final Results idResults = await conn.query("SELECT id FROM move ORDER BY id DESC limit 2");
      int lastMove = 0;
      int currentMove = 0;
      print("thispoint");
      if (idResults.isNotEmpty){
        currentMove=idResults.elementAt(0)[0] as int;
        if (idResults.length ==2) 
          lastMove=idResults.elementAt(1)[0] as int;
      }

      print(currentMove.toString() + " " + lastMove.toString());

      final Map body={"session":props[0],"type":props[1],"objectId":props[2],"keyId":props[3],"userId":props[4],"currentMoveId":currentMove,"lastMoveId":lastMove};
    
      await FirebaseMessage(body:json.encode(body),session:"session1").send();
    }
  }
}