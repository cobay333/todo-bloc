import 'package:flutter/material.dart';
import 'package:todo_bloc/utils/app_utils.dart';
import 'package:todo_bloc/utils/app_constant.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                        leading:
                        Icon(Icons.bug_report, color: Colors.black),
                        title: Text("Rpeort an Issue"),
                        subtitle: Text("Having an issue ? Report it here"),
                        onTap: () => launchURL("https://github.com/cobay333/todo-bloc/issues")),
                    ListTile(
                      leading: Icon(Icons.update, color: Colors.black),
                      title: Text("Version"),
                      subtitle: Text("0.0.1"),
                    )
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("Author",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    ListTile(
                      leading:
                      Icon(Icons.perm_identity, color: Colors.black),
                      title: Text("Cobay333"),
                      subtitle: Text("Cobay333"),
                      onTap: () => launchURL("https://github.com/cobay333/todo-bloc"),
                    ),
                    ListTile(
                        leading:
                        Icon(Icons.bug_report, color: Colors.black),
                        title: Text("Fork on Github"),
                        onTap: () => launchURL("https://github.com/cobay333/todo-bloc")),
                    ListTile(
                        leading: Icon(Icons.email, color: Colors.black),
                        title: Text("Send an Email"),
                        subtitle: Text("vantucntt90@gmail.com"),
                        onTap: () => launchURL("vantucntt90@gmail.com")),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("Ask Question ?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset("assets/twitter_logo.png",scale: 8.75,),
                            onPressed: () => launchURL("https://github.com/cobay333/todo-bloc"),
                          ),
                          IconButton(
                            icon: Image.asset("assets/twitter_logo.png"),
                            onPressed: () => launchURL("https://github.com/cobay333/todo-bloc"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("Apache Licenese",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        subtitle: Text("Copyright 2018 Cobay333"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}