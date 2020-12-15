
import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


class ScoreController extends ResourceController {
  
  ScoreController(this.conn);

  final MySqlConnection conn;



  @Operation.get("session")
  Future<Response> getScore({@Bind.path('session') int sessionId}) async {
    if (sessionId==null) 
      return Response.badRequest();
    
    try{
      Results results = await conn.query("select id,score from team where session_id=?;",[sessionId]);
      final List<List> scoreboard = [];
      results.forEach((row) { 
        scoreboard.add([row[0],row[1]]);
      });
      return Response.ok(scoreboard);
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}


