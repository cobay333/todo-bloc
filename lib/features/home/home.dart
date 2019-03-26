import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';
import 'package:todo_bloc/db/dao/task_dao.dart';
import 'package:todo_bloc/db/dao/project_dao.dart';
import 'package:todo_bloc/db/dao/label_dao.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/features/tasks/task_page.dart';
import 'package:todo_bloc/features/tasks/add_task_page.dart';
import 'package:todo_bloc/bloc/add_task_bloc.dart';

class Home extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDao.get());

  @override
  Widget build(BuildContext context) {
    final HomeBloc homeBloc = BlocProvider.of(context);
    homeBloc.filter.listen((filter) {
      _taskBloc.updateFilters(filter);
    });
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
            initialData: 'Today',
            stream: homeBloc.title,
            builder: (context, snapshot) {
              return Text(snapshot.data);
            }),
//        actions: <Widget>[buildPopupMenu(context)],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        onPressed: () async {
          var blocProviderAddTask = BlocProvider(
            bloc: AddTaskBloc(TaskDao.get(), ProjectDB.get(), LabelDB.get()),
            child: AddTaskScreen(),
          );
          await Navigator.push(
            context,
            MaterialPageRoute<bool>(builder: (context) => blocProviderAddTask),
          );
          _taskBloc.refresh();
        },
      ),
//      drawer: SideDrawer(),
      body: BlocProvider(
        bloc: _taskBloc,
        child: TasksPage(),
      ),
    );
  }

// This menu button widget updates a _selection field (of type WhyFarther,
// not shown here).
//  Widget buildPopupMenu(BuildContext context) {
//    return PopupMenuButton<MenuItem>(
//      onSelected: (MenuItem result) async {
//        switch (result) {
//          case MenuItem.taskCompleted:
//            await Navigator.push(
//              context,
//              MaterialPageRoute<bool>(
//                  builder: (context) => TaskCompletedPage()),
//            );
//            _taskBloc.refresh();
//            break;
//        }
//      },
//      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
//        const PopupMenuItem<MenuItem>(
//          value: MenuItem.taskCompleted,
//          child: const Text('Completed Tasks'),
//        )
//      ],
//    );
//  }

}
// This is the type used by the popup menu below.
enum MenuItem { taskCompleted }
