import 'package:flutter/material.dart';
import 'dart:async';

//import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:futures/model/quotations.dart';
import 'Detail.dart';

class Market extends StatefulWidget {
  const Market({Key key}) : super(key: key); //构造函数中增加参数
  @override
  _MarketState createState() => new _MarketState();
}

///定义TAB页对象，这样做的好处就是，可以灵活定义每个tab页用到的对象，可结合Iterable对象使用
class MarketTab {
  String text;
  MarketItem marketItem;

  MarketTab(this.text, this.marketItem);
}

class _MarketState extends State<Market> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final List<MarketTab> marketTabs = <MarketTab>[
    new MarketTab('香港', new MarketItem('hk')),
//    new MarketTab('纽约', new MarketItem('ny')),
//    new MarketTab('欧洲', new MarketItem('euro')),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: marketTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blueAccent,
        title: new TabBar(
          controller: _tabController,

          ///MarketTab 可以不用声明
          tabs: marketTabs.map((MarketTab item) {
            return new Tab(text: item.text ?? '错误');
          }).toList(),
          indicatorColor: Colors.white,

          ///水平滚动的开关，开启后Tab标签可自适应宽度并可横向拉动，关闭后每个Tab自动压缩为总长符合屏幕宽度的等宽，默认关闭
          isScrollable: true,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: marketTabs.map((item) {
          return item.marketItem;
        }).toList(),
      ),
    );
  }
}

class MarketItem extends StatefulWidget {
  final String name;

  MarketItem(this.name);

  @override
  _MarketItemState createState() => new _MarketItemState();
}

class _MarketItemState extends State<MarketItem>
    with AutomaticKeepAliveClientMixin {
  static Map<String, Quotation> _allQuotations;

//  static List<Quotation> _quotations;
  static const MethodChannel _channel =
      MethodChannel('futures.flutter.io/quotation');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
//    _quotations = new List();
    _allQuotations = new Map();
    _channel.setMethodCallHandler(platformCallHandler);
  }

  @override
  void didUpdateWidget(MarketItem oldWidget) {
//    print('didUpdateWidget');
//    print(oldWidget.quotations);
    super.didUpdateWidget(oldWidget);
  }

  Future<dynamic> platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "initQuotation":
        print('call.arguments');
        print(call.arguments);
        String arg = call.arguments.toString();
        RegExp exp = new RegExp(r'{datalist');
        if (exp.hasMatch(arg)) {
          arg = arg.substring(12, arg.length - 1);
          print(arg);
        }
        Quotations quotations = new Quotations(arg);
        List<Quotation> dataList = quotations.list;
        print('Quotation dataList');
        print(dataList);
        Map<String, Quotation> _map = new Map();
        dataList.forEach((item) {
          _map[item.contractNo] = item;
        });
        setState(() {
//          _quotations = dataList;
          _allQuotations = _map;
        });
        break;
      case "setQuotation":
        Quotations quotations = new Quotations(call.arguments);
        List<Quotation> dataList = quotations.list;
//        print(dataList[0].contractName + ' ' + dataList[0].lastPrice);
        Map<String, Quotation> _map = _allQuotations;
        dataList.forEach((item) {
          _map[item.contractNo] = item;
        });
        setState(() {
//          _quotations = dataList;
          _allQuotations = _map;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new QuotationListWidget(quotations: _allQuotations.values.toList());
  }
}

///行情列表
class QuotationListWidget extends StatelessWidget {
  final List<Quotation> quotations;

//  final Map<String, Quotation> quotations;

  QuotationListWidget({this.quotations});

  @override
  Widget build(BuildContext context) {
    //这里返回你需要的控件
    //这里末尾有没有的逗号，对于格式化代码而已是不一样的。
//    return new Demo('abcd');
    ///一个页面的开始
    ///如果是新页面，会自带返回按键
    return new Scaffold(
      ///背景样式
      backgroundColor: Colors.blue,

//      ///标题栏，当然不仅仅是标题栏
//      appBar: new AppBar(
//        ///这个title是一个Widget
//        title: new Text("Title"),
//      ),

      ///正式的页面开始
      body: new ListView.builder(
        itemBuilder: (context, index) {
          if (quotations != null) {
            return new ListItem(quotations[index]);
          }
        },
        itemCount: quotations == null ? 0 : quotations.length,
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final Quotation quotation;

  ListItem(this.quotation);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
          child: new FlatButton(
              onPressed: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return new Detail();
                }));
              },
              child: new Padding(
                padding: new EdgeInsets.only(
                    left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
//                        new ItemCell(utf8.decode(base64Decode(quotation.contractName))),
                        new ItemCell(quotation.contractName),
                        new ItemCell(
                          quotation.lastPrice,
                        ),
                        new ItemCell(
                            double.parse(quotation.changeRate)
                                    .toStringAsFixed(2) +
                                "%",
                            compare: double.parse(quotation.changeRate) >= 0),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }
}

class ItemCell extends StatelessWidget {
  final String text;
  final bool compare;

  ItemCell(this.text, {this.compare});

  @override
  Widget build(BuildContext context) {
    ///充满 Row 横向的布局
    return new Expanded(
      flex: 1,

      ///居中显示
      child: new Center(
        ///横向布局
        child: new Row(
          ///主轴居中,即是横向居中
          mainAxisAlignment: MainAxisAlignment.center,

          ///大小按照最大充满
          mainAxisSize: MainAxisSize.max,

          ///竖向也居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ///间隔
            new Padding(padding: new EdgeInsets.only(left: 5.0)),
            ///显示文本
            new Text(
              text,
              ///设置字体样式：颜色灰色，字体大小14.0
              style: new TextStyle(
                  color: this.compare == null
                      ? Colors.grey
                      : (this.compare ? Colors.red : Colors.green),
                  fontSize: 14.0),
              ///超过的省略为...显示
              overflow: TextOverflow.ellipsis,
              ///最长一行
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
