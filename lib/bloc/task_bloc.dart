import 'bloc_provider.dart';
import 'dart:async';
import 'dart:collection';
import 'package:todo_bloc/models/task_model.dart';
import 'package:todo_bloc/db/dao/task_dao.dart';
import 'package:todo_bloc/models/filter_model.dart';

class TaskBloc implements BlocBase{
  ///
  /// Synchronous Stream to handle the provision of the movie genres
  ///
  StreamController<List<TaskModel>> _taskController = StreamController<List<TaskModel>>.broadcast();
  Stream<List<TaskModel>> get tasks => _taskController.stream;

  StreamController<int> _cmdController = StreamController<int>.broadcast();
  TaskDao _taskDao;
  List<TaskModel> _tasksList;
  Filter _lastFilterStatus;

  TaskBloc(this._taskDao) {
    filterTodayTasks();
    _cmdController.stream.listen((_) {
      _updateTaskStream(_tasksList);
    });
  }

  void _filterTask(int taskStartTime, int taskEndTime, TaskStatus status) {
    _taskDao
        .getTasks(
        startDate: taskStartTime, endDate: taskEndTime, taskStatus: status)
        .then((tasks) {
      _updateTaskStream(tasks);
    });
  }

  void _updateTaskStream(List<TaskModel> tasks) {
    _tasksList = tasks;
    _taskController.sink.add(UnmodifiableListView<TaskModel>(_tasksList));
  }

  void filterTodayTasks() {
    final dateTime = DateTime.now();
    final int taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day)
            .millisecondsSinceEpoch;
    final int taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59)
            .millisecondsSinceEpoch;

    // Read all today's tasks from database
    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byToday();
  }

  void filterTasksForNextWeek() {
    var dateTime = DateTime.now();
    var taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day)
            .millisecondsSinceEpoch;
    var taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
            .millisecondsSinceEpoch;
    // Read all next week tasks from database
    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byNextWeek();
  }

  void filterByProject(int projectId) {
    _taskDao
        .getTasksByProject(projectId, status: TaskStatus.PENDING)
        .then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byProject(projectId);
      _updateTaskStream(tasks);
    });
  }

  void filterByLabel(String labelName) {
    _taskDao
        .getTasksByLabel(labelName, status: TaskStatus.COMPLETE)
        .then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byLabel(labelName);
      _updateTaskStream(tasks);
    });
  }

  void filterByStatus(TaskStatus status) {
    _taskDao.getTasks(taskStatus: status).then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byStatus(status);
      _updateTaskStream(tasks);
    });
  }

  void updateStatus(int taskID, TaskStatus status) {
    _taskDao.updateTaskStatus(taskID, status).then((value) {
      refresh();
    });
  }

  void delete(int taskID) {
    _taskDao.deleteTask(taskID).then((value) {
      refresh();
    });
  }

  void refresh() {
    if (_lastFilterStatus != null) {
      switch (_lastFilterStatus.filterStatus) {
        case FILTER_STATUS.BY_TODAY:
          filterTodayTasks();
          break;

        case FILTER_STATUS.BY_WEEK:
          filterTasksForNextWeek();
          break;

        case FILTER_STATUS.BY_LABEL:
          filterByLabel(_lastFilterStatus.labelName);
          break;

        case FILTER_STATUS.BY_PROJECT:
          filterByProject(_lastFilterStatus.projectId);
          break;

        case FILTER_STATUS.BY_STATUS:
          filterByStatus(_lastFilterStatus.status);
          break;
      }
    }
  }

  void updateFilters(Filter filter) {
    _lastFilterStatus = filter;
    refresh();
  }

  @override
  void dispose() {
    _taskController.close();
    _cmdController.close();
  }

}