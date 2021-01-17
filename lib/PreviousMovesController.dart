import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';

class PreviousMovesController extends ResourceController {
  
  PreviousMovesController(this.conn);

  final MySqlConnection conn;

  @Operation.get('session')
  Future<Response> movesFetch(@Bind.path('session') int sessionId,{@Bind.query('move') int lastKnownMove=0}) async {

    Results results = await conn.query("SELECT id,type,object_id,key_id,user_id,position,timestamp FROM move WHERE id>? AND session_id=? order by id asc",[lastKnownMove,sessionId]);
    List response = [];
    for (var row in results) {
      final int hour = (row[6] as DateTime).hour;
      final int minute = (row[6] as DateTime).minute;
      print(hour.toString());
      final String timestamp = (hour<10?"0${hour.toString()}":hour.toString()) +":" + (minute<10?"0${minute.toString()}":minute.toString());
     response.add([row[0],row[1],row[2],row[3],row[4],row[5],timestamp]);
    }
    print(response);
    return Response.ok(response);

  }
}