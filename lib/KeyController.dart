
import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


import 'VersionProcessing.dart';

class KeyController extends ResourceController {
  
  KeyController(this.conn);

  final MySqlConnection conn;


//Request handling
  @Operation.get()
  Future<Response> requestKeys({ @Bind.query('userId') String userId, @Bind.query('sessionId') int sessionId}) async {
    if ( userId ==null || sessionId==null ) 
      return Response.badRequest();
    
    final Results results = await conn.query('''  SELECT key_id FROM key_user where user_id=? and key_id not in (SELECT m1.key_id
    from move m1 LEFT JOIN move m2 on (m1.key_id=m2.key_id and m1.id < m2.id and m1.session_id=m2.session_id) where m2.id is null and m1.type ="match" and m1.session_id=?)''',[userId,sessionId]);
    final List <int> keyList = [];
    results.forEach((row)=>keyList.add(row[0] as int));
    return Response.ok({'keys':keyList});
  

//Router to code that differs from version to version
}

}