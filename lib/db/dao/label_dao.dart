import 'package:sqflite/sqflite.dart';
import 'package:todo_bloc/db/app_db.dart';
import 'package:todo_bloc/models/label_model.dart';

class LabelDB {
  static final LabelDB _labelDb = LabelDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  LabelDB._internal(this._appDatabase);

  static LabelDB get() {
    return _labelDb;
  }

  Future<bool> isLabelExits(LabelModel label) async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery(
        "SELECT * FROM ${LabelModel.tblLabel} WHERE ${LabelModel.dbName} LIKE '${label.name}'");
    if (result.length == 0) {
      return await updateLabels(label).then((value) {
        return false;
      });
    } else {
      return true;
    }
  }

  Future updateLabels(LabelModel label) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT OR REPLACE INTO '
          '${LabelModel.tblLabel}(${LabelModel.dbName},${LabelModel.dbColorCode},${LabelModel.dbColorName})'
          ' VALUES("${label.name}", ${label.colorValue}, "${label.colorName}")');
    });
  }

  Future<List<LabelModel>> getLabels() async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery('SELECT * FROM ${LabelModel.tblLabel}');
    List<LabelModel> projects = List();
    for (Map<String, dynamic> item in result) {
      var myProject = LabelModel.fromMap(item);
      projects.add(myProject);
    }
    return projects;
  }
}
