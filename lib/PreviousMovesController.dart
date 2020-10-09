import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';

class PreviousMovesController extends ResourceController {
  
  PreviousMovesController(this.conn);

  final MySqlConnection conn;

  @Operation.get('session')
  Future<Response> movesFetch(@Bind.path('session') int sessionId,{@Bind.query('move') int lastKnownMove=0}) async {

    Results results = await conn.query("SELECT id,type,object_id,key_id,user_id FROM move WHERE id>? AND session_id=?",[lastKnownMove,sessionId]);
    return Response.ok([results]);
  }
}