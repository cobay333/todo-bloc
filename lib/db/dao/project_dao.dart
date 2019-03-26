import 'package:sqflite/sqflite.dart';
import 'package:todo_bloc/db/app_db.dart';
import 'package:todo_bloc/models/project_model.dart';
class ProjectDB {
  static final ProjectDB _projectDb = ProjectDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  ProjectDB._internal(this._appDatabase);

  static ProjectDB get() {
    return _projectDb;
  }

  Future<List<ProjectModel>> getProjects({bool isInboxVisible = true}) async {
    var db = await _appDatabase.getDb();
    var whereClause = isInboxVisible ? ";" : " WHERE ${ProjectModel.dbId}!=1;";
    var result =
    await db.rawQuery('SELECT * FROM ${ProjectModel.tblProject} $whereClause');
    List<ProjectModel> projects = List();
    for (Map<String, dynamic> item in result) {
      var myProject = ProjectModel.fromMap(item);
      projects.add(myProject);
    }
    return projects;
  }

  Future insertOrReplace(ProjectModel project) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT OR REPLACE INTO '
          '${ProjectModel.tblProject}(${ProjectModel.dbId},${ProjectModel.dbName},${ProjectModel.dbColorCode},${ProjectModel.dbColorName})'
          ' VALUES(${project.id},"${project.name}", ${project.colorValue}, "${project.colorName}")');
    });
  }

  Future deleteProject(int projectID) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM ${ProjectModel.tblProject} WHERE ${ProjectModel.dbId}==$projectID;');
    });
  }
}