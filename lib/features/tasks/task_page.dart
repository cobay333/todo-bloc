import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/models/task_model.dart';
import 'package:todo_bloc/utils/app_utils.dart';
import '../tasks/row_task.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TaskBloc _tasksBloc = BlocProvider.on(context).taskBloc;
    return StreamBuilder<List<TaskModel>>(
      stream: _tasksBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  Widget _buildTaskList(List<TaskModel> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget("No Task Added")
          : Container(
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                  key: ObjectKey(list[index]),
                  onDismissed: (DismissDirection direction) {
                    var taskID = list[index].id;
                    final TaskBloc _tasksBloc =
                    BlocProvider.of<TaskBloc>(context);
                    String message = "";
                    if (direction == DismissDirection.endToStart) {
                      _tasksBloc.updateStatus(
                          taskID, TaskStatus.COMPLETE);
                      message = "Task completed";
                    } else {
                      _tasksBloc.delete(taskID);
                      message = "Task deleted";
                    }
                    SnackBar snackbar =
                    SnackBar(content: Text(message));
                    Scaffold.of(context).showSnackBar(snackbar);
                  },
                  background: Container(
                    color: Colors.red,
                    child: ListTile(
                      leading:
                      Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.green,
                    child: ListTile(
                      trailing:
                      Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                  child: TaskRow(list[index]));
            }),
      ),
    );
  }
}