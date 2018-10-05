/**
    import 'package:flutter/material.dart';

    class CounterDisplay extends StatelessWidget {
    CounterDisplay({this.count});

    final int count;

    @override
    Widget build(BuildContext context) {
    return new Text('Count: $count');
    }
    }

    class CounterIncrease extends StatelessWidget {
    CounterIncrease({this.onPressed});

    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) {
    return new RaisedButton(
    onPressed: onPressed,
    child: new Text('Increment'),
    );
    }
    }

    class Counter extends StatefulWidget {
    @override
    _CounterState createState() => new _CounterState();
    }

    class _CounterState extends State<Counter> {
    int _counter = 0;

    void _increment() {
    setState(() {
    ++_counter;
    });
    }

    @override
    Widget build(BuildContext context) {
    return new Row(children: <Widget>[
    new CounterIncrease(onPressed: _increment),
    new CounterDisplay(count: _counter),
    ]);
    }
    }
 */

import 'package:flutter/material.dart';

class LifecycleAppPage extends StatefulWidget {
  @override
  State<LifecycleAppPage> createState() {
    return new _LifecycleAppPageState('构造函数');
  }
}

class _LifecycleAppPageState extends State<LifecycleAppPage>
    with WidgetsBindingObserver {
  String str;

  int count = 0;

  _LifecycleAppPageState(this.str);

  @override
  void initState() {
    print(str);
    print('initState');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(LifecycleAppPage oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        print('AppLifecycleState.resumed');
        break;
      case AppLifecycleState.suspending:
        print('AppLifecycleState.suspending');
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('生命周期'),
        centerTitle: true,
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Text(
              '当前计数值：$count',
              style: new TextStyle(
                  color: orientation == Orientation.portrait
                      ? Colors.blue
                      : Colors.red),
            ),
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text('click'),
          onPressed: () {
            count++;
            setState(() {});
          }),
    );
  }
}

class LifecyclePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new LifecycleAppPage(),
    );
  }
}
