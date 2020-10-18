
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
      final Results versionResults = await conn.query("SELECT game_version FROM session WHERE id= ?",[sessionId]);
      if (versionResults.isEmpty) 
        return Response.notFound();
      final int currentVersion = versionResults.elementAt(0)[0] as int;

      final String assetRegistry = await File("assets/session${sessionId}version${currentVersion}.json").readAsStringSync();
      final json = jsonDecode(assetRegistry);
      await conn.query("call scoreboard(?,?,?)",[sessionId,json['joumerka']['Score']['ScoreBonus'],json['joumerka']['Score']['ScorePenalty']]);
      final Results results = await conn.query("select * from scoreboard");
      final Results teams = await conn.query("select id from team where session_id = ? order by id asc;",[sessionId]);
      int i = 0;
      final List<List> scoreboard = [];
      teams.forEach((element){
        scoreboard.add([element[0],(results.elementAt(0)[1].toString()).split(",")[i]]);
        i++;
      });

      return Response.ok(scoreboard);
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}