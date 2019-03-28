import 'package:todo_bloc/bloc/bloc_provider.dart';
import 'package:todo_bloc/db/dao/task_dao.dart';
import 'package:todo_bloc/db/dao/label_dao.dart';
import 'package:todo_bloc/db/dao/project_dao.dart';
import 'package:todo_bloc/models/task_model.dart';
import 'package:todo_bloc/models/label_model.dart';
import 'package:todo_bloc/models/project_model.dart';
import 'package:todo_bloc/models/priority.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class AddTaskBloc implements BlocBase {
  final TaskDao _taskDB = TaskDao.get();
  final ProjectDB _projectDB = ProjectDB.get();
  final LabelDB _labelDB = LabelDB.get();
  Status lastPrioritySelection = Status.PRIORITY_4;

  AddTaskBloc() {
    loadProjects();
    loadLabels();
    updateDueDate(DateTime.now().millisecondsSinceEpoch);
    _projectSelection.add(ProjectModel.getInbox());
    _prioritySelected.add(lastPrioritySelection);
  }

  //get list project
  BehaviorSubject<List<ProjectModel>> _projectController = BehaviorSubject<List<ProjectModel>>();
  Stream<List<ProjectModel>> get projects => _projectController.stream;

  ///get list label
  BehaviorSubject<List<LabelModel>> _labelController = BehaviorSubject<List<LabelModel>>();
  Stream<List<LabelModel>> get labels => _labelController.stream;

  ///item project select
  BehaviorSubject<ProjectModel> _projectSelection = BehaviorSubject<ProjectModel>();
  Stream<ProjectModel> get selectedProject => _projectSelection.stream;

  ///item label select
  BehaviorSubject<String> _labelSelected = BehaviorSubject<String>();
  Stream<String> get labelSelection => _labelSelected.stream;

  List<LabelModel> _selectedLabelList = List();
  List<LabelModel> get selectedLabels => _selectedLabelList;

  //priority
  BehaviorSubject<Status> _prioritySelected = BehaviorSubject<Status>();
  Stream<Status> get prioritySelected => _prioritySelected.stream;

  //due date
  BehaviorSubject<int> _dueDateSelected = BehaviorSubject<int>();
  Stream<int> get dueDateSelected => _dueDateSelected.stream;

  String updateTitle = "";

  @override
  void dispose() {
    _projectController.close();
    _labelController.close();
    _projectSelection.close();
    _labelSelected.close();
    _prioritySelected.close();
    _dueDateSelected.close();
  }

  void loadProjects() {
    _projectDB.getProjects(isInboxVisible: true).then((projects) {
      _projectController.add(List.unmodifiable(projects));
    });
  }

  void loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelController.add(List.unmodifiable(labels));
    });
  }

  void projectSelected(ProjectModel project) {
    _projectSelection.add(project);
  }

  void labelAddOrRemove(LabelModel label) {
    if (_selectedLabelList.contains(label)) {
      _selectedLabelList.remove(label);
    } else {
      _selectedLabelList.add(label);
    }
    _buildLabelsString();
  }

  void _buildLabelsString() {
    List<String> selectedLabelNameList = List();
    _selectedLabelList.forEach((label) {
      selectedLabelNameList.add("@${label.name}");
    });
    String labelJoinString = selectedLabelNameList.join("  ");
    String displayLabels =
    labelJoinString.length == 0 ? "No Labels" : labelJoinString;
    _labelSelected.add(displayLabels);
  }

  void updatePriority(Status priority) {
    _prioritySelected.add(priority);
    lastPrioritySelection = priority;
  }

  Observable<String> createTask() {
    return Observable.zip3(selectedProject, dueDateSelected, prioritySelected,
            (ProjectModel project, int dueDateSelected, Status status) {
          List<int> labelIds = List();
          _selectedLabelList.forEach((label) {
            labelIds.add(label.id);
          });

          var task = TaskModel.create(
            title: updateTitle,
            dueDate: dueDateSelected,
            priority: status,
            projectId: project.id,
          );
          _taskDB.updateTask(task, labelIDs: labelIds).then((task) {
            Notification.onDone();
          });
        });
  }

  void updateDueDate(int millisecondsSinceEpoch) {
    _dueDateSelected.add(millisecondsSinceEpoch);
  }
}