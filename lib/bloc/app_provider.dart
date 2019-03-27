import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';
import 'package:todo_bloc/bloc/add_task_bloc.dart';
import 'package:todo_bloc/bloc/project_bloc.dart';

class AppProvider extends InheritedWidget {
  final HomeBloc homeBloc;
  final TaskBloc taskBloc;
  final AddTaskBloc addTaskBloc;
  final ProjectBloc projectBloc;

//  final TaskDao taskDao = TaskDao.get();
//  final LabelDB lableDao = LabelDB.get();
//  final ProjectDB projectBloc = ProjectDB.get();

  AppProvider({Key key, Widget child, this.homeBloc, this.taskBloc, this.addTaskBloc, this.projectBloc})
      : super(key: key, child : child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static AppProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AppProvider) as AppProvider);
  }
}