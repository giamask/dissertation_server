

import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';

class InitializationController extends ResourceController {
  InitializationController(this.conn);
  
    final MySqlConnection conn;

  @Operation.get('session')
  Future<Response> getAssetRegistry(@Bind.path('session') int sessionId, {@Bind.query('version') int version=0}) async { 

    final Results results = await conn.query("SELECT rules_version from gameVersion join `session` on `session`.game_version=gameVersion.id where session.id=?",[sessionId]);
    if (results.isEmpty) 
    return Response.notFound();
    final int currentVersion = results.elementAt(0)[0] as int;

    if ( version< currentVersion){
      final File file = File("assets/session${sessionId}version${currentVersion}.json");
      final String response = await file.readAsString();
      return Response.ok(jsonDecode(response))..contentType = ContentType.json;
    }
    
    return Response.ok("confirm");
  }
}


