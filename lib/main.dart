//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TodoItem> _todoList = [];
List<String> _titles = [];

Future<void> saveTasks() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('_titles', _titles);
  for (var item in _todoList) {
    prefs.setString(item.name, item.description);
  }
}

Future<void> readTasks() async {
  final prefs = await SharedPreferences.getInstance();
  _titles = prefs.getStringList('_titles') ?? [];
  for (var item in _titles) {
    _todoList.add(TodoItem(
        key: UniqueKey(),
        name: item,
        description: prefs.getString(item) ?? 'Empty'));
  }
}

Future<void> removeTask(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    readTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _addPage() async {
    await Navigator.push(
      context,
      PageTransition(
          child: const FormPage(),
          type: PageTransitionType.leftToRightWithFade),
    );
    setState(() {});
  }

  void _refresh(){
    setState(() {
    });
  }

  @override
  void dispose() {
    saveTasks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.add_task),
        title: const Text('Todos'),
        centerTitle: true,
      ),
      //floatingActionButton: 
      body: Container(
        color: const Color.fromARGB(255, 0, 255, 255),
        child: Column(
          children: [Expanded(child: ListView(
            children: (_todoList.isEmpty)
                ? [
                    const TodoItem(
                      name: 'Add a new Item',
                      description: 'Add a new item by tapping on the + icon',
                    ),
                  ]
                : _todoList.reversed.toList(),
            ),
          ),
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(10),
          child: FloatingActionButton(
            heroTag: null,
            onPressed: _refresh,
            tooltip: 'Refresh Page',
            child: const Icon(Icons.refresh),
          ),),
          Padding(padding: const EdgeInsets.all(10),
          child: FloatingActionButton(
            onPressed: _addPage,
            tooltip: 'Add item',
            child: const Icon(Icons.add),
          ),),
        ],
      ),
        ],
      ),
    ),),);
  }
}

class TodoItem extends StatefulWidget {
  const TodoItem({Key? key, required this.name, required this.description})
      : super(key: key);

  final String name;
  final String description;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool _completed = false;

  void _descriptionPage() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: DescriptionPage(
              name: widget.name,
              description: widget.description,
            )));
  }

  void _deleteItem(BuildContext context) {
    var item = context.findAncestorWidgetOfExactType<TodoItem>();
    int index = (item == null) ? -1 : _todoList.indexOf(item);
    final snackBar = SnackBar(
      content: const Text('Task Removed Successfully!'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Undo(Refresh Needed)',
        onPressed: () {
          if (item != null && index != -1) {
            _todoList.insert(index, item);
            _titles.insert(index, item.name);
          }
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if (item != null) {
      context.findAncestorStateOfType<_MyHomePageState>()?.setState(() {
        _titles.remove(item.name);
        _todoList.remove(item);
      });
    }
    saveTasks();
  }

  void _toggleComplete(BuildContext context) {
    setState(() {
      _completed = !_completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: _deleteItem,
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: _toggleComplete,
            backgroundColor: const Color.fromARGB(255, 0, 182, 6),
            foregroundColor: Colors.white,
            icon: Icons.done_all_rounded,
            label: 'Mark as Done',
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: ListTile(
          leading: (_completed) ? const Icon(Icons.done) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: (_completed)
              ? Colors.green
              : const Color.fromARGB(255, 255, 213, 128),
          trailing: const Icon(
            Icons.drag_handle_rounded,
            size: 30,
          ),
          title: Text(
            widget.name,
          ),
          subtitle: Text(widget.description),
          onTap: _descriptionPage,
        ),
      ),
    );
  }
}

class DescriptionPage extends StatelessWidget {
  const DescriptionPage(
      {Key? key, required this.name, required this.description})
      : super(key: key);

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => Navigator.pop(context)),
        tooltip: 'Return',
        child: const Icon(Icons.undo),
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 255, 255),
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 7,
            color: const Color.fromARGB(255, 255, 235, 189),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(description),
            ),
          ),
        ),
      ),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add New Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => Navigator.pop(context)),
        tooltip: 'Return',
        child: const Icon(Icons.undo),
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 255, 255),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Card(
                elevation: 7,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextFormField(
                    autofocus: true,
                    controller: titleController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title_rounded),
                      border: OutlineInputBorder(),
                      labelText: 'Add a Title',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          _titles.contains(value)) {
                        return 'Please enter a unique title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextFormField(
                    controller: descriptionController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description_rounded),
                      border: OutlineInputBorder(),
                      labelText: 'Add a Description',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _titles.add(titleController.text);
                      _todoList.add(TodoItem(
                        key: UniqueKey(),
                        name: titleController.text,
                        description: (descriptionController.text.isEmpty)
                            ? 'Empty'
                            : descriptionController.text,
                      ));
                      final snackBar = SnackBar(
                        content: const Text('Task Added Successfully!'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            _todoList.removeLast();
                            _titles.removeLast();
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      saveTasks();
                    }
                  },
                  child: const Text('Add Task!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
