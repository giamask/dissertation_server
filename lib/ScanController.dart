

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


class ScanController extends ResourceController {
  
  ScanController(this.conn);

  final MySqlConnection conn;



  @Operation.get("session")
  Future<Response> registerMove({@Bind.query('objectId') int objectId, @Bind.query('userId') String userId,@Bind.path('session') int sessionId}) async {
    if (objectId==null  || userId ==null || sessionId==null) 
      return Response.badRequest();
    
    try{
      await conn.query("INSERT INTO move VALUES(null,?,?,?,null,?,default);",[sessionId,"scan",objectId,userId,]);
      return Response.ok("confirm");
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}