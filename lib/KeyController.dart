import 'package:http/http.dart' as http;
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
    
    final Results results = await conn.query('''  SELECT key_id FROM key_user where user_id=? and `session`=? and key_id not in (SELECT m1.key_id
    from move m1 LEFT JOIN move m2 on (m1.key_id=m2.key_id and m1.id < m2.id and m1.session_id=m2.session_id) where m2.id is null and m1.type ="match" and m1.session_id=?)''',[userId,sessionId,sessionId]);
    final List <int> keyList = [];
    results.forEach((row)=>keyList.add(row[0] as int));
    print(keyList);
    if (keyList.isEmpty){
      endGame(sessionId);
    }
    return Response.ok({'keys':keyList});
  

//Router to code that differs from version to version
}

  void endGame(int sessionId) async{
    Results results = await conn.query("SELECT state FROM session WHERE id=?",[sessionId]);
    if (results.elementAt(0)[0]!="live") return;
    await conn.query("UPDATE session SET state=1 where id=?",[sessionId]);
    Results winningTeams = await conn.query("select team_name,score from team as t1 inner join (select max(score) as max_score from team) as t2 on t2.max_score = t1.score");
    if (winningTeams.length==1){
      await http.get('http://hci.ece.upatras.gr:8888/adminMessage/$sessionId?text=Το παιχνίδι έληξε με νίκη της ομάδας <b>${winningTeams.elementAt(0)[0]}</b>. Ελπίζουμε να διασκεδάσατε!');
    } else {
  
      String teams = "";
      winningTeams.forEach((element) => teams+=(element['team_name'] as String) + ", ");
      teams = teams.substring(0,teams.length-2);
      await http.get('http://hci.ece.upatras.gr:8888/adminMessage/$sessionId?text=Το παιχνίδι έληξε με ισοπαλία των ομάδων ${teams}. Ελπίζουμε να διασκεδάσατε!');
    }
  }


}