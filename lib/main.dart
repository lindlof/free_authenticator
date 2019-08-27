import 'package:flutter/material.dart';
import 'package:free_authenticator/database_helper.dart';
import 'package:free_authenticator/create_entry.dart';
import 'package:free_authenticator/entry_base.dart';
import 'package:free_authenticator/entry.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Authenticator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'One-time Passwords'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final entries = <Entry>[];

  _MyHomePageState() {
    _loadEntries();
  }

  _loadEntries() async {
    final db = await DatabaseHelper.database;
    final mapItems = await db.query(EntryBase.table);
    if (mapItems.isNotEmpty) {
      var fEntries = mapItems.map((e) => EntryBase.fromDbFormat(e)).toList();
      var entries = await Future.wait(fEntries);
      setState(() {
        this.entries.addAll(entries);
      });
    }
  }

  _createEntry(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return CreateEntry(
            onCreate: (Entry entry) async {
              final db = await DatabaseHelper.database;
              final id = await db.insert(EntryBase.table, await entry.toDbFormat());
              print('inserted row id: $id');
              setState(() {
                entries.add(entry);
              });
            }
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, int) {
            var entry = entries[int];
            return ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text(entry.name + " " + entry.genPassword()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _createEntry(context); },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
