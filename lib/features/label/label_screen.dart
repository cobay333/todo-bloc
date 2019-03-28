import 'package:flutter/material.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/bloc/home_bloc.dart';
import 'package:todo_bloc/models/filter_model.dart';
import 'package:todo_bloc/bloc/label_bloc.dart';
import 'package:todo_bloc/features/label/add_label.dart';

class LabelPage extends StatelessWidget {
  LabelBloc labelBloc;
  @override
  Widget build(BuildContext context) {
    labelBloc = BlocProvider.on(context).labelBloc;
    return StreamBuilder<List<LabelModel>>(
      stream: labelBloc.labels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LabelExpansionTileWidget(snapshot.data);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class LabelExpansionTileWidget extends StatelessWidget {
  final List<LabelModel> _labels;

  LabelExpansionTileWidget(this._labels);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.label),
      title: Text("Labels",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildLabels(context),
    );
  }

  List<Widget> buildLabels(BuildContext context) {
    List<Widget> projectWidgetList = List();
    _labels.forEach((label) => projectWidgetList.add(LabelRow(label)));
    projectWidgetList.add(ListTile(
        leading: Icon(Icons.add),
        title: Text("Add Label"),
        onTap: () async {
//          Navigator.pop(context);

          var blocLabelProvider = BlocProvider(
            bloc: LabelBloc(),
            child: AddLabel(),
          );

          await Navigator.push(context,
              MaterialPageRoute<bool>(builder: (context) => blocLabelProvider));
        }));
    return projectWidgetList;
  }
}

class LabelRow extends StatelessWidget {
  final LabelModel label;

  LabelRow(this.label);

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.on(context).homeBloc;
    return ListTile(
      onTap: () {
        homeBloc.applyFilter("@ ${label.name}", Filter.byLabel(label.name));
        Navigator.pop(context);
      },
      leading: Container(
        width: 24.0,
        height: 24.0,
      ),
      title: Text("@ ${label.name}"),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: Icon(
          Icons.label,
          size: 16.0,
          color: Color(label.colorValue),
        ),
      ),
    );
  }
}