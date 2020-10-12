
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
      final Results correctResults = await conn.query("select t.color,t.team_name,team_successes.`COUNT(*)` from team_successes right join team as t on t.team_name=team_successes.team_name where t.session_id=? order by team_name asc",[sessionId]);
      final Results wrongResults = await conn.query("select t.color,t.team_name,team_failures.`COUNT(*)` from team_failures right join team as t on t.team_name=team_failures.team_name where t.session_id=? order by team_name asc",[sessionId]);
      // int i =0 ;
      // while (correctResults.elementAt(0)!=null){
      //  correctResults.elementAt(i).add(wrongResults.elementAt(i)[2]==null?0:wrongResults.elementAt(i)[2]);
      //  i++;
      // }
      // final Map scoreboard = {"score":[]}; 
      // correctResults.forEach((row) {scoreboard["score"].add({row[1]:[row[0],(row[2]==null?0:row[2]),row[3]]});});
      // return Response.ok(jsonEncode(scoreboard));
      List<List> scoreboard = [];
      for(int i=0;i<correctResults.length;i++){
        scoreboard.add([correctResults.elementAt(i)[0],correctResults.elementAt(i)[1],correctResults.elementAt(i)[2]??0,wrongResults.elementAt(i)[2]??0]);
      }
      return Response.ok(scoreboard);
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}