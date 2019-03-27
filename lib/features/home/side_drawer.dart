import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:todo_bloc/models/filter_model.dart';
import 'package:todo_bloc/features/about/about_screen.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';
import 'package:todo_bloc/bloc/project_bloc.dart';
import 'package:todo_bloc/features/project/project_screen.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';

import 'dart:async';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.on(context).homeBloc;
    TaskBloc taskBloc = BlocProvider.on(context).taskBloc;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Cobay333"),
            accountEmail: Text("cobay333@gmail.com"),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<bool>(
                          builder: (context) => AboutUsScreen()),
                    );
                  }
                  )
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: AssetImage("assets/twitter_logo.jpg"),
            ),
          ),
          ListTile(
              leading: Icon(Icons.inbox),
              title: Text("Inbox"),
              onTap: () {
                var project = ProjectModel.getInbox();
                homeBloc.applyFilter(
                    project.name, Filter.byProject(project.id));
                taskBloc.updateFilters(Filter.byProject(project.id));

                Navigator.pop(context);
              }),
          ListTile(
              onTap: () {
                homeBloc.applyFilter("Today", Filter.byToday());
                taskBloc.updateFilters(Filter.byToday());
                Navigator.pop(context);
              },
              leading: Icon(Icons.calendar_today),
              title: Text("Today")),
          ListTile(
            onTap: () {
              homeBloc.applyFilter("Next 7 Days", Filter.byNextWeek());
              taskBloc.updateFilters(Filter.byNextWeek());
              Navigator.pop(context);
            },
            leading: Icon(Icons.calendar_today),
            title: Text("Next 7 Days"),
          ),
          BlocProvider(
            bloc: ProjectBloc(),
            child: ProjectScreen(),
          ),
//          BlocProvider(
//            bloc: LabelBloc(LabelDB.get()),
//            child: LabelPage(),
//          )
        ],
      ),
    );
  }
}