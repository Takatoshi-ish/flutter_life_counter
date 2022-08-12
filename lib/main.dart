import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './life_event.dart';
import './objectbox.g.dart';

// まずは main 関数が実行されます
void main() {
  // runApp の中に書いた Widget が最初に表示されます
  // この Widget と ルート Widget と呼んだりもします
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // この primarySwatch プロパティの色は自分好みに変更してOKです
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LifeCounterPage(),
    );
  }
}

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  // ObjectBoxを利用するにはまず store が必要になります
  // ですが store を作成するには openStore という非同期関数の実行が必要です
  // なのでこの段階で初期値として store を代入することはできません
  // そのためまずは null を入れる必要があります
  // 変数に null が入ることを許容するには Store? のように ? をつければよいです
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];

  /// Store と Box を用意します
  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    fetchLifeEvents();
  }

  /// Box から LifeEvent 一覧を取得します
  void fetchLifeEvents() {
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  void deleteAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Alert"),
          content: const Text("LifeEvent をすべて削除しますか？"),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text("削除する"),
              onPressed: () {
                deleteLifeEvents();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteLifeEvents() {
    lifeEventBox?.removeAll();
    fetchLifeEvents();
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
        actions: [
          IconButton(
            onPressed: lifeEvents.isNotEmpty ? deleteAlertDialog : null,
            icon: const Icon(Icons.remove_circle),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: lifeEvents.length, // ここには必ずListの総数を与えてください
        itemBuilder: (context, index) {
          // List は　[要素番号] でその一つひとつの要素を取得できます
          final lifeEvent = lifeEvents[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lifeEvent.title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${lifeEvent.count}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  // ここでカウントアップしています
                  onPressed: () {
                    lifeEvent.count++;
                    lifeEventBox?.put(lifeEvent);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.plus_one),
                ),
                IconButton(
                  // ここでカウントダウンしています
                  onPressed: () {
                    lifeEvent.count--;
                    lifeEventBox?.put(lifeEvent);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.exposure_minus_1),
                ),
                IconButton(
                  // ここでデータを削除しています
                  onPressed: () {
                    lifeEventBox?.remove(lifeEvent.id);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        // ここで画面遷移とデータを新規追加しています
        onPressed: () async {
          final newLifeEvent = await Navigator.of(context).push<LifeEvent>(
            MaterialPageRoute(
              builder: (context) {
                return const AddLifeEventPage();
              },
            ),
          );
          if (newLifeEvent != null) {
            lifeEventBox?.put(newLifeEvent);
            fetchLifeEvents();
          }
        },
      ),
    );
  }
}

class AddLifeEventPage extends StatefulWidget {
  const AddLifeEventPage({super.key});

  @override
  State<AddLifeEventPage> createState() => _AddLifeEventPageState();
}

class _AddLifeEventPageState extends State<AddLifeEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ライフイベント追加'),
      ),
      body: TextFormField(
        onFieldSubmitted: (text) {
          final lifeEvent = LifeEvent(title: text, count: 0);
          Navigator.of(context).pop(lifeEvent);
        },
      ),
    );
  }
}
