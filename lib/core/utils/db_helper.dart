import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app.db'),
      version: 4,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE auth(token TEXT PRIMARY KEY)');
        await db.execute('CREATE TABLE posts('
            'id INTEGER PRIMARY KEY, '
            'title TEXT, '
            'body TEXT, '
            'userId INTEGER, '
            'isLocal INTEGER DEFAULT 0, '
            'isFavorite INTEGER DEFAULT 0)' // add this column
            );
        await db.execute('CREATE TABLE comments('
            'id INTEGER PRIMARY KEY, '
            'postId INTEGER, '
            'name TEXT, '
            'email TEXT, '
            'body TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('CREATE TABLE posts('
              'id INTEGER PRIMARY KEY, '
              'title TEXT, '
              'body TEXT, '
              'userId INTEGER, '
              'isLocal INTEGER DEFAULT 0)');
        }
        if (oldVersion < 3) {
          await db.execute('CREATE TABLE comments('
              'id INTEGER PRIMARY KEY, '
              'postId INTEGER, '
              'name TEXT, '
              'email TEXT, '
              'body TEXT)');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE posts ADD COLUMN isFavorite INTEGER DEFAULT 0');
        }
      },
    );
  }
}
