import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _homePageState();
  }
}

class _homePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  String? _newTaskContent;
  Box? _box;
  _homePageState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly!",
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (
        BuildContext _context,
        AsyncSnapshot _snapshot,
      ) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _taskList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(task.timeStamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: Colors.blueGrey,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(
                _index,
                task.toMap(),
              );
              setState(() {});
            },
            onLongPress: () {
              _box!.deleteAt(_index);
              setState(() {});
            },
          );
        });
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopUp,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext _context) => AlertDialog(
        title: const Text("Add new Task!"),
        content: TextField(
          onSubmitted: (_value) {
            if (_newTaskContent != null) {
              var _task = Task(
                  content: _newTaskContent!,
                  timeStamp: DateTime.now(),
                  done: false);
              _box!.add(_task.toMap());
              setState(() {
                _newTaskContent = null;
              });
              Navigator.pop(context);
            }
          },
          onChanged: (_value) => setState(() {
            _newTaskContent = _value;
          }),
        ),
      ),
    );
  }
}
