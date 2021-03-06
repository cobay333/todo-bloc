import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';
import 'package:todo_bloc/bloc/add_task_bloc.dart';

import 'package:todo_bloc/features/home/home.dart';
import 'package:todo_bloc/bloc/app_provider.dart';
import 'package:todo_bloc/bloc/project_bloc.dart';
import 'package:todo_bloc/bloc/label_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppProvider(
        homeBloc: HomeBloc(),
        taskBloc: TaskBloc(),
        addTaskBloc: AddTaskBloc(),
        projectBloc: ProjectBloc(),
        labelBloc: LabelBloc(),
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            home: BlocProvider(bloc: HomeBloc(), child: Home())));
  }
}
