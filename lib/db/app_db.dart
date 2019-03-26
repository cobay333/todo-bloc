import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/models/task_label_model.dart';
import 'package:todo_bloc/models/task_model.dart';
import 'package:todo_bloc/models/project_model.dart';

/// This is the singleton database class which handlers all database transactions
/// All the task raw queries is handle here and return a Future<T> with result
class AppDatabase {
  static final AppDatabase _appDatabase = AppDatabase._internal();

  //private internal constructor to make it singleton
  AppDatabase._internal();
  Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  bool didInit = false;

  /// Use this method to access the database which will provide you future of [Database],
  /// because initialization of the database (it has to go through the method channel)
  Future<Database> getDb() async {
    if (!didInit) await _init();
    return _database;
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tasks.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await _createProjectTable(db);
          await _createTaskTable(db);
          await _createLabelTable(db);
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await db.execute("DROP TABLE ${TaskModel.tblTask}");
          await db.execute("DROP TABLE ${ProjectModel.tblProject}");
          await db.execute("DROP TABLE ${TaskLabelModel.tblTaskLabel}");
          await db.execute("DROP TABLE ${LabelModel.tblLabel}");
          await _createProjectTable(db);
          await _createTaskTable(db);
          await _createLabelTable(db);
        });
    didInit = true;
  }
  Future _createProjectTable(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE ${ProjectModel.tblProject} ("
          "${ProjectModel.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${ProjectModel.dbName} TEXT,"
          "${ProjectModel.dbColorName} TEXT,"
          "${ProjectModel.dbColorCode} INTEGER);");
      txn.rawInsert('INSERT INTO '
          '${ProjectModel.tblProject}(${ProjectModel.dbId},${ProjectModel.dbName},${ProjectModel.dbColorName},${ProjectModel.dbColorCode})'
          ' VALUES(1, "Inbox", "Grey", ${Colors.grey.value});');
    });
  }

  Future _createLabelTable(Database db) {
    return db.transaction((Transaction txn) {
      txn.execute("CREATE TABLE ${LabelModel.tblLabel} ("
          "${LabelModel.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${LabelModel.dbName} TEXT,"
          "${LabelModel.dbColorName} TEXT,"
          "${LabelModel.dbColorCode} INTEGER);");
      txn.execute("CREATE TABLE ${TaskLabelModel.tblTaskLabel} ("
          "${TaskLabelModel.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${TaskLabelModel.dbTaskId} INTEGER,"
          "${TaskLabelModel.dbLabelId} INTEGER,"
          "FOREIGN KEY(${TaskLabelModel.dbTaskId}) REFERENCES ${TaskModel.tblTask}(${TaskLabelModel.dbId}) ON DELETE CASCADE,"
          "FOREIGN KEY(${TaskLabelModel.dbLabelId}) REFERENCES ${LabelModel.tblLabel}(${TaskLabelModel.dbId}) ON DELETE CASCADE);");
    });
  }

  Future _createTaskTable(Database db) {
    return db.execute("CREATE TABLE ${TaskModel.tblTask} ("
        "${TaskModel.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${TaskModel.dbTitle} TEXT,"
        "${TaskModel.dbComment} TEXT,"
        "${TaskModel.dbDueDate} LONG,"
        "${TaskModel.dbPriority} LONG,"
        "${TaskModel.dbProjectID} LONG,"
        "${TaskModel.dbStatus} LONG,"
        "FOREIGN KEY(${TaskModel.dbProjectID}) REFERENCES ${ProjectModel.tblProject}(${ProjectModel.dbId}) ON DELETE CASCADE);");
  }


}