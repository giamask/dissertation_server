

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


class SessionController extends ResourceController {
  
  SessionController(this.conn);

  final MySqlConnection conn;



  @Operation.get('user')
  Future<Response> registerMove({@Bind.path('user') String user, @Bind.query("token") String token}) async {
    if ( user ==null || token==null ) 
      return Response.badRequest();
    try{
      await conn.query("UPDATE `user` SET device_token=? WHERE id = ?",[token,user]);
      Results results = await conn.query("SELECT DISTINCT session.* FROM session join team on session.id = team.session_id where state = 'live' and team.id in (select team_id from `team_user` where user_id=?)",[user]);
      List<Map> response = [];
      results.forEach((row){
        response.add({"sessionName":row.elementAt(3),"sessionId":row.elementAt(0)});
      });
      return Response.ok(response);
    }
    on MySqlException catch (e){
      print(e.message);
      return Response.serverError();
    }
  }
}