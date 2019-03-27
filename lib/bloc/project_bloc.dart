import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'dart:async';
import 'package:todo_bloc/utils/color_utils.dart';
import 'package:todo_bloc/db/dao/project_dao.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:rxdart/rxdart.dart';
class ProjectBloc implements BlocBase {
  BehaviorSubject<List<ProjectModel>> _projectController = BehaviorSubject<List<ProjectModel>>();

  Stream<List<ProjectModel>> get projects => _projectController.stream;

  StreamController<ColorPalette> _colorController = StreamController<ColorPalette>.broadcast();

  Stream<ColorPalette> get colorSelection => _colorController.stream;

  ProjectDB _projectDB = ProjectDB.get();
  bool isInboxVisible = false;

  ProjectBloc() {
    _loadProjects(isInboxVisible);
  }

  @override
  void dispose() {
    _projectController.close();
    _colorController.close();
  }

  void _loadProjects(bool isInboxVisible) {
    _projectDB.getProjects(isInboxVisible: isInboxVisible).then((projects) {
      _projectController.sink.add(projects);
    });
  }

  void createProject(ProjectModel project) {
    _projectDB.insertOrReplace(project).then((value) {
      if (value == null) return;
      _loadProjects(isInboxVisible);
    });
  }

  void updateColorSelection(ColorPalette colorPalette) {
    _colorController.sink.add(colorPalette);
  }

  void refresh(){
    _loadProjects(isInboxVisible);
  }
}
