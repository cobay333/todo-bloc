import 'package:todo_bloc/db/app_db.dart';
import 'package:todo_bloc/models/task_model.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/models/task_label_model.dart';
import 'package:sqflite/sqflite.dart';

class TaskDao {
  static final TaskDao _taskDao = TaskDao._internal(AppDatabase.get());
  AppDatabase _appDatabase;
  TaskDao._internal(this._appDatabase);

  static TaskDao get() {
    return _taskDao;
  }

  // get all task
  Future<List<TaskModel>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus taskStatus}) async {
    var db = await _appDatabase.getDb();
    var whereClause = startDate > 0 && endDate > 0
        ? "WHERE ${TaskModel.tblTask}.${TaskModel.dbDueDate} BETWEEN $startDate AND $endDate"
        : "";

    if (taskStatus != null) {
      var taskWhereClause =
          "${TaskModel.tblTask}.${TaskModel.dbStatus} = ${taskStatus.index}";
      whereClause = whereClause.isEmpty
          ? "WHERE $taskWhereClause"
          : "$whereClause AND $taskWhereClause";
    }

    var result = await db.rawQuery(
        'SELECT ${TaskModel.tblTask}.*,${ProjectModel.tblProject}.${ProjectModel.dbName},${ProjectModel.tblProject}.${ProjectModel.dbColorCode},group_concat(${LabelModel.tblLabel}.${LabelModel.dbName}) as labelNames '
            'FROM ${TaskModel.tblTask} LEFT JOIN ${TaskLabelModel.tblTaskLabel} ON ${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbTaskId}=${TaskModel.tblTask}.${TaskModel.dbId} '
            'LEFT JOIN ${LabelModel.tblLabel} ON ${LabelModel.tblLabel}.${LabelModel.dbId}=${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbLabelId} '
            'INNER JOIN ${ProjectModel.tblProject} ON ${TaskModel.tblTask}.${TaskModel.dbProjectID} = ${ProjectModel.tblProject}.${ProjectModel.dbId} $whereClause GROUP BY ${TaskModel.tblTask}.${TaskModel.dbId} ORDER BY ${TaskModel.tblTask}.${TaskModel.dbDueDate} ASC;');

    return _bindData(result);
  }

  /**
   * tranfer data form data query to model
   */
  List<TaskModel> _bindData(List<Map<String, dynamic>> result) {
    List<TaskModel> tasks = List();
    for (Map<String, dynamic> item in result) {
      var myTask = TaskModel.fromMap(item);
      myTask.projectName = item[ProjectModel.dbName];
      myTask.projectColor = item[ProjectModel.dbColorCode];
      var labelComma = item["labelNames"];
      if (labelComma != null) {
        myTask.labelList = labelComma.toString().split(",");
      }
      tasks.add(myTask);
    }
    return tasks;
  }

  //get task by project
  Future<List<TaskModel>> getTasksByProject(int projectId,
      {TaskStatus status}) async {
    var db = await _appDatabase.getDb();
    String whereStatus = status != null
        ? "AND ${TaskModel.tblTask}.${TaskModel.dbStatus}=${status.index}"
        : "";
    var result = await db.rawQuery(
        'SELECT ${TaskModel.tblTask}.*,${ProjectModel.tblProject}.${ProjectModel.dbName},${ProjectModel.tblProject}.${ProjectModel.dbColorCode},group_concat(${LabelModel.tblLabel}.${LabelModel.dbName}) as labelNames '
            'FROM ${TaskModel.tblTask} LEFT JOIN ${TaskLabelModel.tblTaskLabel} ON ${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbTaskId}=${TaskModel.tblTask}.${TaskModel.dbId} '
            'LEFT JOIN ${LabelModel.tblLabel} ON ${LabelModel.tblLabel}.${LabelModel.dbId}=${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbLabelId} '
            'INNER JOIN ${ProjectModel.tblProject} ON ${TaskModel.tblTask}.${TaskModel.dbProjectID} = ${ProjectModel.tblProject}.${ProjectModel.dbId} '
            'WHERE ${TaskModel.tblTask}.${TaskModel.dbProjectID}=$projectId $whereStatus GROUP BY ${TaskModel.tblTask}.${TaskModel.dbId} ORDER BY ${TaskModel.tblTask}.${TaskModel.dbDueDate} ASC;');

    return _bindData(result);
  }

  //get task with label
  Future<List<TaskModel>> getTasksByLabel(String labelName,
      {TaskStatus status}) async {
    var db = await _appDatabase.getDb();
    String whereStatus = status != null
        ? "AND ${TaskModel.tblTask}.${TaskModel.dbStatus}=${TaskStatus.PENDING.index}"
        : "";
    var result = await db.rawQuery(
        'SELECT ${TaskModel.tblTask}.*,${ProjectModel.tblProject}.${ProjectModel.dbName},${ProjectModel.tblProject}.${ProjectModel.dbColorCode},group_concat(${LabelModel.tblLabel}.${LabelModel.dbName}) as labelNames FROM ${TaskModel.tblTask} '
            'LEFT JOIN ${TaskLabelModel.tblTaskLabel} ON ${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbTaskId}=${TaskModel.tblTask}.${TaskModel.dbId} '
            'LEFT JOIN ${LabelModel.tblLabel} ON ${LabelModel.tblLabel}.${LabelModel.dbId}=${TaskLabelModel.tblTaskLabel}.${TaskLabelModel.dbLabelId} '
            'INNER JOIN ${ProjectModel.tblProject} ON ${TaskModel.tblTask}.${TaskModel.dbProjectID} = ${ProjectModel.tblProject}.${ProjectModel.dbId} '
            'WHERE ${TaskModel.tblTask}.${TaskModel.dbProjectID}=${ProjectModel.tblProject}.${ProjectModel.dbId} $whereStatus '
            'GROUP BY ${TaskModel.tblTask}.${TaskModel.dbId} having labelNames LIKE "%$labelName%" ORDER BY ${TaskModel.tblTask}.${TaskModel.dbDueDate} ASC;');

    return _bindData(result);
  }

  // delete task
  Future deleteTask(int taskID) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM ${TaskModel.tblTask} WHERE ${TaskModel.dbId}=$taskID;');
    });
  }

  //update status
  Future updateTaskStatus(int taskID, TaskStatus status) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawQuery(
          "UPDATE ${TaskModel.tblTask} SET ${TaskModel.dbStatus} = '${status.index}' WHERE ${TaskModel.dbId} = '$taskID'");
    });
  }

  /// Inserts or replaces the task.
  Future updateTask(TaskModel task, {List<int> labelIDs}) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      int id = await txn.rawInsert('INSERT OR REPLACE INTO '
          '${TaskModel.tblTask}(${TaskModel.dbId},${TaskModel.dbTitle},${TaskModel.dbProjectID},${TaskModel.dbComment},${TaskModel.dbDueDate},${TaskModel.dbPriority},${TaskModel.dbStatus})'
          ' VALUES(${task.id}, "${task.title}", ${task.projectId},"${task.comment}", ${task.dueDate},${task.priority.index},${task.tasksStatus.index})');
      if (id > 0 && labelIDs != null && labelIDs.length > 0) {
        labelIDs.forEach((labelId) {
          txn.rawInsert('INSERT OR REPLACE INTO '
              '${TaskLabelModel.tblTaskLabel}(${TaskLabelModel.dbId},${TaskLabelModel.dbTaskId},${TaskLabelModel.dbLabelId})'
              ' VALUES(null, $id, $labelId)');
        });
      }
    });
  }
}