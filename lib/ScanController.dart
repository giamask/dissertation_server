

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


class ScanController extends ResourceController {
  
  ScanController(this.conn);

  final MySqlConnection conn;



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('objectId') int objectId, @Bind.query('userId') String userId,@Bind.path('session') int sessionId,@Bind.query('timestamp') DateTime timestamp}) async {
    if (objectId==null  || userId ==null || sessionId==null) 
      return Response.badRequest();
    timestamp ??= DateTime.now().toUtc();

    try{
      await conn.query("INSERT INTO scan VALUES(null,?,?,?,?);",[userId,objectId,sessionId,timestamp.isUtc?timestamp:timestamp.toUtc()]);
      return Response.ok("confirm");
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}