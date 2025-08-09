import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app.db'),
      version: 3, // bumped to 3 to create comments/favorites if upgrading
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE auth(token TEXT PRIMARY KEY)');
        await db.execute(
            'CREATE TABLE posts(id INTEGER PRIMARY KEY, title TEXT, body TEXT, userId INTEGER, isLocal INTEGER DEFAULT 0)');
        await db.execute(
            'CREATE TABLE comments(id INTEGER PRIMARY KEY, postId INTEGER, name TEXT, email TEXT, body TEXT)');
        await db.execute('CREATE TABLE favorites(postId INTEGER PRIMARY KEY)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // older migrations (if you used version 2 previously)
          await db.execute(
              'CREATE TABLE posts(id INTEGER PRIMARY KEY, title TEXT, body TEXT, userId INTEGER, isLocal INTEGER DEFAULT 0)');
        }
        if (oldVersion < 3) {
          await db.execute(
              'CREATE TABLE comments(id INTEGER PRIMARY KEY, postId INTEGER, name TEXT, email TEXT, body TEXT)');
          await db
              .execute('CREATE TABLE favorites(postId INTEGER PRIMARY KEY)');
        }
      },
    );
  }
}
