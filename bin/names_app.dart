import 'dart:io';
import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:names_app/names_app.dart' as names_app;
void main(List<String> arguments) async {
  print("Enter name:");
  var name = stdin.readLineSync();
  print("Name: ${name}");
  final db = sqlite3.open('db/database.db');
  createTables(db);
  final url = Uri.https(
    'api.genderize.io',
    '',
    {'name': name}
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final jsonResponse = convert.jsonDecode(response.body);
    final name = jsonResponse;
    print(' $name');
    insertName(db, name);
    readFromDB(db);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  
}

createTables(db){
  print('Using sqlite3 ${sqlite3.version}');
  db.execute('''
    CREATE TABLE IF NOT EXISTS names (
      count INT, 
      gender VARCHAR(20), 
      name VARCHAR(20) PRIMARY KEY ON CONFLICT REPLACE,
      probability VARCHAR(20)
    );
  ''');
}

insertName(db,name){
final stmt = db.prepare('INSERT INTO names (count, gender, name, probability) VALUES (?,?,?,?)');
  stmt.execute([name['count'],name['gender'],name['name'],name['probability']]);
  stmt.dispose();
}

readFromDB(db){
  final ResultSet resultSet = db.select('SELECT * FROM names');
  for (final Row row in resultSet) {
    print('Name: ${row['name']}, ${row['gender']}, ${row['probability']}');
  }
}

