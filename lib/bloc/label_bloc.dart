import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/utils/color_utils.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/db/dao/label_dao.dart';

class LabelBloc implements BlocBase {
  BehaviorSubject<List<LabelModel>> _labelController = BehaviorSubject<List<LabelModel>>();

  Stream<List<LabelModel>> get labels => _labelController.stream;

  StreamController<bool> _labelExistController = StreamController<bool>.broadcast();

  Stream<bool> get labelsExist => _labelExistController.stream;

  StreamController<ColorPalette> _colorController = StreamController<ColorPalette>.broadcast();

  Stream<ColorPalette> get colorSelection => _colorController.stream;

  LabelDB _labelDB = LabelDB.get();

  LabelBloc() {
    _loadLabels();
  }

  @override
  void dispose() {
    _labelController.close();
    _labelExistController.close();
    _colorController.close();
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelController.sink.add(List.unmodifiable(labels));
    });
  }

  void refresh() {
    _loadLabels();
  }

  void checkIfLabelExist(LabelModel label) async {
    _labelDB.isLabelExits(label).then((isExist) {
      _labelExistController.sink.add(isExist);
    });
  }

  void updateColorSelection(ColorPalette colorPalette) {
    _colorController.sink.add(colorPalette);
  }
}