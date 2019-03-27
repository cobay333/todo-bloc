import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/add_task_bloc.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:todo_bloc/models/priority.dart';
import 'package:todo_bloc/utils/date_util.dart';
import 'package:todo_bloc/utils/app_utils.dart';
import 'package:todo_bloc/utils/color_utils.dart';
import 'package:todo_bloc/bloc/task_bloc.dart';

class AddTaskScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldState =
  GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  AddTaskBloc _createTaskBloc;

  @override
  Widget build(BuildContext context) {
    _createTaskBloc = BlocProvider.on(context).addTasklBloc;
    TaskBloc taskBloc = BlocProvider.on(context).taskBloc;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Task"),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  validator: (value) {
                    var msg = value.isEmpty ? "Title Cannot be Empty" : null;
                    return msg;
                  },
                  onSaved: (value) {
                    _createTaskBloc.updateTitle = value;
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(hintText: "Title")),
            ),
            key: _formState,
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text("Project"),
            subtitle: StreamBuilder<ProjectModel>(
              stream: _createTaskBloc.selectedProject,
              initialData: ProjectModel.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data.name),
            ),
            onTap: () {
              _showProjectsDialog(_createTaskBloc, context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Due Date"),
            subtitle: StreamBuilder(
              stream: _createTaskBloc.dueDateSelected,
              initialData: DateTime.now().millisecondsSinceEpoch,
              builder: (context, snapshot) =>
                  Text(getFormattedDate(snapshot.data)),
            ),
            onTap: () {
              _selectDate(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text("Priority"),
            subtitle: StreamBuilder(
              stream: _createTaskBloc.prioritySelected,
              initialData: Status.PRIORITY_4,
              builder: (context, snapshot) =>
                  Text(priorityText[snapshot.data.index]),
            ),
            onTap: () {
              _showPriorityDialog(_createTaskBloc, context);
            },
          ),
          ListTile(
              leading: Icon(Icons.label),
              title: Text("Lables"),
              subtitle: StreamBuilder(
                stream: _createTaskBloc.labelSelection,
                initialData: "No Labels",
                builder: (context, snapshot) => Text(snapshot.data),
              ),
              onTap: () {
                _showLabelsDialog(context);
              }),
          ListTile(
            leading: Icon(Icons.mode_comment),
            title: Text("Comments"),
            subtitle: Text("No Comments"),
            onTap: () {
              showSnackbar(_scaffoldState, "Comming Soon");
            },
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text("Reminder"),
            subtitle: Text("No Reminder"),
            onTap: () {
              showSnackbar(_scaffoldState, "Comming Soon");
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState.validate()) {
              _formState.currentState.save();
              _createTaskBloc.createTask().listen((value) {
                taskBloc.refresh();
                Navigator.pop(context, true);
              });
            }
          }),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null) {
      _createTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }

  Future<Status> _showPriorityDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return await showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: const Text('Select Priority'),
            children: <Widget>[
              buildContainer(context, Status.PRIORITY_1),
              buildContainer(context, Status.PRIORITY_2),
              buildContainer(context, Status.PRIORITY_3),
              buildContainer(context, Status.PRIORITY_4),
            ],
          );
        });
  }

  Future<Status> _showProjectsDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder(
              stream: createTaskBloc.projects,
              initialData: List<ProjectModel>(),
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Project'),
                  children:
                  buildProjects(createTaskBloc, context, snapshot.data),
                );
              });
        });
  }

  Future<Status> _showLabelsDialog(BuildContext context) async {
    return showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
              stream: _createTaskBloc.labels,
              initialData: List<LabelModel>(),
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Labels'),
                  children: buildLabels(_createTaskBloc, context, snapshot.data),
                );
              });
        });
  }

  List<Widget> buildProjects(
      AddTaskBloc createTaskBloc,
      BuildContext context,
      List<ProjectModel> projectList,
      ) {
    List<Widget> projects = List();
    projectList.forEach((project) {
      projects.add(ListTile(
        leading: Container(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(project.colorValue),
          ),
        ),
        title: Text(project.name),
        onTap: () {
          createTaskBloc.projectSelected(project);
          Navigator.pop(context);
        },
      ));
    });
    return projects;
  }

  List<Widget> buildLabels(
      AddTaskBloc createTaskBloc,
      BuildContext context,
      List<LabelModel> labelList,
      ) {
    List<Widget> labels = List();
    labelList.forEach((label) {
      labels.add(ListTile(
        leading: Icon(Icons.label,
            color: Color(label.colorValue), size: 18.0),
        title: Text(label.name),
        trailing: createTaskBloc.selectedLabels.contains(label)
            ? Icon(Icons.close)
            : Container(width: 18.0, height: 18.0),
        onTap: () {
          createTaskBloc.labelAddOrRemove(label);
          Navigator.pop(context);
        },
      ));
    });
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, Status status) {
    return GestureDetector(
        onTap: () {
          _createTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == _createTaskBloc.lastPrioritySelection
                ? Colors.grey
                : Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 6.0,
                    color: priorityColor[status.index],
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(priorityText[status.index],
                    style: TextStyle(fontSize: 18.0)),
              ),
            )));
  }
}