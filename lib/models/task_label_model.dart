class TaskLabelModel{
  static final tblTaskLabel = "taskLabel";
  static final dbId = "id";
  static final dbTaskId = "taskId";
  static final dbLabelId = "labelId";

  int id, taskId, labelId;

  TaskLabelModel.create(this.taskId, this.labelId);

  TaskLabelModel.update({this.id, this.taskId, this.labelId});

  TaskLabelModel.fromMap(Map<String, dynamic> map)
      : this.update(
      id: map[dbId], taskId: map[dbTaskId], labelId: map[dbLabelId]);
}