import 'package:flutter/material.dart';
import 'app_provider.dart';

abstract class BlocBase {
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  final T bloc;
  final Widget child;

  BlocProvider({Key key,
    @required this.bloc,
    @required this.child}) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _BlocProviderState<T>();
  }

//  static T of<T extends BlocBase>(BuildContext context) {
//    final type = _typeOf<BlocProvider<T>>();
//    BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
//    return provider.bloc;
//  }

  static AppProvider on<T extends BlocBase>(BuildContext context) {
    return AppProvider.of(context);
  }

//  static Type _typeOf<T>() => T;
}
class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

}
