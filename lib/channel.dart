import 'package:mysql1/mysql1.dart';

import 'ImageController.dart';
import 'InitializationController.dart';
import 'MoveController.dart';
import 'PreviousMovesController.dart';
import 'ScanController.dart';
import 'TestController.dart';
import 'SessionController.dart';
import 'server_side.dart';
import 'KeyController.dart';
import 'PastScanController.dart';
import 'ScoreController.dart';
import 'AdminMessageController.dart';
import 'AdminSessionController.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class ServerSideChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  /// 
  MySqlConnection conn;

  @override
  Future prepare() async {

    final config = DatabaseConfig("config.yaml");
    final settings = ConnectionSettings(
        host: config.database.host,
        port: config.database.port,
        user: config.database.username,
        password: config.database.password,
        db: config.database.databaseName);
    conn = await MySqlConnection.connect(settings);
    logger.onRecord.listen(
    (rec) { 
      print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? "" }");
      try{
        File('log.txt').writeAsString("${DateTime.now()}$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""} \n",mode:FileMode.append);
      }
      catch(e){
        print(e);
      }
    });
    
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/init/[:session]").link(() => InitializationController(conn));

    router.route("/image/[:name]").link(() => ImageController());

    router.route("/past_moves/[:session]").link(()=> PreviousMovesController(conn));

    router.route("/move").link(()=> MoveController(conn));

    router.route("/test").link(()=> TestController());

    router.route("/scan/[:session]").link(()=> ScanController(conn));

     router.route("/past_scans/[:session]").link(()=> PastScanController(conn));
    
    router.route("/keys").link(()=> KeyController(conn));

    router.route("/score/[:session]").link(()=>ScoreController(conn));

    router.route("/adminMessage/[:session]").link(()=>AdminMessageController(conn));

    router.route("/sessions/[:user]").link(()=>SessionController(conn));

    router.route("/admin/[:session]").link(()=>AdminSessionController(conn));
  
    
    return router;
  }
}



class DatabaseConfig extends Configuration{
  DatabaseConfig(String path):super.fromFile(File(path));

  DatabaseConfiguration database;
}

//TODO object_key table
//TODO SQL server-side NVC

