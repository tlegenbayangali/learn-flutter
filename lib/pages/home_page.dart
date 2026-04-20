import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // vars
  int _counter = 0;

  // actions
  void increment() {
    setState(() {
      _counter++;
    });
  }

  //ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home page'), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You pressed: '),
            Text(_counter.toString()),
            SizedBox(height: 26),
            ElevatedButton(onPressed: increment, child: Icon(Icons.plus_one)),
          ],
        ),
      ),
    );
  }
}
