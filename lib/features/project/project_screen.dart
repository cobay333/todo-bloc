import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/project_bloc.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/models/filter_model.dart';
import 'package:todo_bloc/features/project/add_project.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';

class ProjectScreen extends StatelessWidget {
  ProjectBloc projectBloc;

  @override
  Widget build(BuildContext context) {
    projectBloc = BlocProvider.on(context).projectBloc;
    return StreamBuilder<List<ProjectModel>>(
      stream: projectBloc.projects,
      builder: (context, snapshot) {
        if (snapshot.hasData || snapshot.data!=null) {
          return ProjectExpansionTileWidget(snapshot.data);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class ProjectExpansionTileWidget extends StatelessWidget {
  final List<ProjectModel> _projects;

  ProjectExpansionTileWidget(this._projects);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.book),
      title: Text("Projects",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildProjects(context),
    );
  }

  List<Widget> buildProjects(BuildContext context) {
    List<Widget> projectWidgetList = List();
    _projects.forEach((project) => projectWidgetList.add(ProjectRow(project)));
    projectWidgetList.add(ListTile(
      leading: Icon(Icons.add),
      title: Text("Add Project"),
      onTap: () async {
        Navigator.pop(context);
        Widget addProject = BlocProvider(
          bloc: ProjectBloc(),
          child: AddProject(),
        );
        await Navigator.push(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => addProject,
            ));
      },
    ));
    return projectWidgetList;
  }
}

class ProjectRow extends StatelessWidget {
  final ProjectModel project;

  ProjectRow(this.project);

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.on(context).homeBloc;
    TaskBloc taskBloc = BlocProvider.on(context).taskBloc;
    return ListTile(
      onTap: () {
        homeBloc.applyFilter(project.name, Filter.byProject(project.id));
        taskBloc.updateFilters(Filter.byProject(project.id));
        Navigator.pop(context);
      },
      leading: Container(
        width: 24.0,
        height: 24.0,
      ),
      title: Text(project.name),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: CircleAvatar(
          backgroundColor: Color(project.colorValue),
        ),
      ),
    );
  }
}
