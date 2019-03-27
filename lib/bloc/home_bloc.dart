import 'bloc_provider.dart';
import 'dart:async';
import 'package:todo_bloc/models/filter_model.dart';

class HomeBloc implements BlocBase {
  StreamController<String> _titleController = StreamController<String>.broadcast();
  Stream<String> get title => _titleController.stream;


  @override
  void dispose() {
    _titleController.close();
  }

  void updateTitle(String title) {
    _titleController.sink.add(title);
  }

  void applyFilter(String title, Filter filter) {
    updateTitle(title);
  }
}