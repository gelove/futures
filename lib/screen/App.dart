import 'package:flutter/material.dart';

import 'market/Market.dart';
import 'trade/Trade.dart';
import 'mine/Mine.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  final List<String> titles = ['行情', '交易', '我'];
  final List<StatefulWidget> vcSet = [
    new Market(),
    new LifecycleAppPage(),
    new Mine()
  ];

  //定义底部导航项目
  final List<BottomNavigationBarItem> listSet = [
    new BottomNavigationBarItem(
      title: new Text("行情"),
      icon: new Icon(Icons.call_missed_outgoing, color: Colors.grey),
      activeIcon: new Icon(Icons.call_missed_outgoing, color: Colors.blue),
    ),
    new BottomNavigationBarItem(
      title: new Text("交易"),
      icon: new Icon(Icons.attach_money, color: Colors.grey),
      activeIcon: new Icon(Icons.attach_money, color: Colors.blue),
    ),
    new BottomNavigationBarItem(
      title: new Text("我"),
      icon: new Icon(Icons.perm_identity, color: Colors.grey),
      activeIcon: new Icon(Icons.perm_identity, color: Colors.blue),
    ),
  ];

  //定义底部导航Tab
  TabController _bottomNavigation;

  @override
  void dispose() {
    _bottomNavigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text(titles[_index]),
      ), //头部的标题AppBar
      body: vcSet[_index],
      bottomNavigationBar: new BottomNavigationBar(
        items: listSet,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _index = index;
          });
        },
        currentIndex: _index,
      ),
    );
  }
}
