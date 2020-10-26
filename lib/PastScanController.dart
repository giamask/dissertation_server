

import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


class PastScanController extends ResourceController {
  
  PastScanController(this.conn);

  final MySqlConnection conn;



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('userId') String userId,@Bind.path('session') int sessionId}) async {
    if (userId ==null || sessionId==null) 
      return Response.badRequest();
    
    Results results;
    try{
      results = await conn.query("SELECT a.object_id,a.timestamp FROM scan as a INNER JOIN (SELECT object_id, MAX(timestamp) as timestamp FROM scan  GROUP BY object_id ) AS b ON a.object_id = b.object_id AND a.timestamp = b.timestamp WHERE user_id=? AND session_id=?;",[userId,sessionId]);
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }

    Map response = {};
    results.forEach((row){
      response[row[0].toString()]=(row[1] as DateTime).toLocal().toIso8601String();
    });
    return Response.ok(response);
  }
}