import 'package:flutter/material.dart';

import 'life_event.dart';
import 'objectbox.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const LifeCounterPagee(),
    );
  }
}

class LifeCounterPagee extends StatefulWidget {
  const LifeCounterPagee({Key? key}) : super(key: key);

  @override
  State<LifeCounterPagee> createState() => _LifeCounterPageeState();
}

class _LifeCounterPageeState extends State<LifeCounterPagee> {
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];

  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('人生カウンター'),
        ),
        body: ListView.builder(
          itemCount: lifeEvents.length,
          itemBuilder: (context, index) {
            final lifeEvent = lifeEvents[index];
            return Text(lifeEvent.title);
          },
        ));
  }
}
