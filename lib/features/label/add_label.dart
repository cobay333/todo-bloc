import 'package:flutter/material.dart';
import 'package:todo_bloc/utils/collapsable_expand_tile.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/utils/color_utils.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/bloc/add_task_bloc.dart';
import 'package:todo_bloc/bloc/label_bloc.dart';
import 'package:todo_bloc/utils/app_utils.dart';

class AddLabel extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  @override
  Widget build(BuildContext context) {
    ColorPalette currentSelectedPalette;
    LabelBloc labelBloc = BlocProvider.on(context).labelBloc;
    AddTaskBloc addTaskBloc = BlocProvider.on(context).addTaskBloc;
    String labelName = "";
    labelBloc.labelsExist.listen((isExist) {
      if (isExist) {
        showSnackbar(_scaffoldState, "Label already exists");
      } else {
        addTaskBloc.loadLabels();
        labelBloc.refresh();
        Navigator.pop(context);
      }
    });
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Label"),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () async {
            if (_formState.currentState.validate()) {
              _formState.currentState.save();
              var label = LabelModel.create(
                  labelName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName);
              labelBloc.checkIfLabelExist(label);
            }
          }),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(hintText: "Label Name"),
                maxLength: 20,
                validator: (value) {
                  return value.isEmpty ? "Label Cannot be empty" : null;
                },
                onSaved: (value) {
                  labelName = value;
                },
              ),
            ),
            key: _formState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: StreamBuilder<ColorPalette>(
              stream: labelBloc.colorSelection,
              initialData: ColorPalette("Grey", Colors.grey.value),
              builder: (context, snapshot) {
                currentSelectedPalette = snapshot.data;
                return CollapsibleExpansionTile(
                  key: expansionTile,
                  leading: Icon(
                    Icons.label,
                    size: 16.0,
                    color: Color(currentSelectedPalette.colorValue),
                  ),
                  title: Text(currentSelectedPalette.colorName),
                  children: buildMaterialColors(labelBloc),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildMaterialColors(LabelBloc labelBloc) {
    List<Widget> projectWidgetList = List();
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState.collapse();
          labelBloc.updateColorSelection(
            ColorPalette(colors.colorName, colors.colorValue),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}