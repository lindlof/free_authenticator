import 'package:flutter/material.dart';
import 'package:free_authenticator/database_helper.dart';
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
  TextEditingController nameInput = TextEditingController();
  TextEditingController keyInput = TextEditingController();
  final entries = <Entry>[];
  final dbFuture = DatabaseHelper.instance.database;

  _MyHomePageState() {
    loadEntries();
  }

  loadEntries() async {
    final db = await dbFuture;
    final mapItems = await db.query(Entry.table);
    if (mapItems.isNotEmpty) {
      List<Entry> entries = mapItems.map((e) => Entry.fromMap(e)).toList();
      setState(() {
        this.entries.addAll(entries);
      });
    }
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter a key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameInput,
                  decoration: InputDecoration(hintText: "Name"),
                ),
                TextField(
                  controller: keyInput,
                  decoration: InputDecoration(hintText: "Key"),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () async {
                  final entry = Entry(nameInput.text, keyInput.text);
                  final db = await dbFuture;
                  final id = await db.insert(Entry.table, entry.toMap());
                  print('inserted row id: $id');

                  setState(() {
                    entries.add(entry);
                  });
                  nameInput.text = "";
                  keyInput.text = "";
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
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
              title: Text(entry.name),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _displayDialog(context); },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
