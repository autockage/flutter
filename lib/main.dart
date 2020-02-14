import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'AutoFront',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var list;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return createListView();
  }

  Future<Null> _getData() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    String apiUrl =
        'https://protected-ridge-35353.herokuapp.com/api/pages/page_test';
    http.Response response = await http.get(apiUrl);
    final items = json.decode(response.body);

    setState(() {
      list = items;
    });

    return null;
  }

  List<Widget> handleWidgets(list) {
    List<Widget> childrenWidgets = [];
    for (final item in list) {
      final value = new MapStringDynamicInferface(item);
      if (item['type'] == 'text') {
        childrenWidgets
            .add(TextWidget(params: value));
      } else if (item['type'] == 'input') {
        childrenWidgets
            .add(InputWidgetState(params: value));
      } else if (item['type'] == 'select') {
        childrenWidgets.add(
            DropdownButtonWidget(params: value));
      }
       else if (item['type'] == 'cards') {
        childrenWidgets.add(
            CardWidgetState(params: value));
      }
    }
    return childrenWidgets;
  }

  Widget createListView() {
    List<Widget> childrenWidgets = [];
    String titleScaffold = "";

    if (list != null) {
      childrenWidgets = this.handleWidgets(list['data']['body']['render']);
      titleScaffold = list['data']['header']['title']['text'];
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(titleScaffold),
        ),
        body: new RefreshIndicator(
            key: refreshKey,
            onRefresh: _getData,
            child: new ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return new Column(
                  children: childrenWidgets,
                );
              },
            )));
  }
}

class TextWidget extends StatelessWidget {
  final MapStringDynamicInferface params;

  TextWidget({Key key, @required this.params}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(this.params.data['value']['text']));
  }
}

class MapStringDynamicInferface {
  final Map<String, dynamic> data;

  MapStringDynamicInferface(this.data);
}

class InputWidgetState extends StatelessWidget {
  final MapStringDynamicInferface params;

  // In the constructor, require a Person
  InputWidgetState({Key key, @required this.params}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: params.data['value']['name'],
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AutoInputInferface {
  final String label;

  AutoInputInferface(this.label);
}

class DropdownButtonWidget extends StatefulWidget {
  final MapStringDynamicInferface params;

  DropdownButtonWidget({Key key, @required this.params}) : super(key: key);

  @override
  DropdownButtonWidgetState createState() =>
      DropdownButtonWidgetState(params: null);
}

class DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  String dropdownValue = 'One';
  final MapStringDynamicInferface params;

  // In the constructor, require a Person
  DropdownButtonWidgetState({Key key, @required this.params});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class CardWidgetState extends StatelessWidget {
  final MapStringDynamicInferface params;

  // In the constructor, require a Person
  CardWidgetState({Key key, @required this.params}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paramsStyle = this.params.data['value'];

    final styles = {
      "scrollDirection": (paramsStyle['type'] == "horizontal") ? Axis.horizontal : Axis.vertical,
      "groupHeight": paramsStyle['style']['groupHeight'].toDouble(),
      "cardwidth": paramsStyle['style']['groupHeight'].toDouble(),
    };

    return Container(
        height: styles['groupHeight'],
        child: ListView.builder(
          scrollDirection: styles['scrollDirection'],
          itemCount: paramsStyle['cards'].length,
          itemBuilder: (BuildContext context, int i) => Card(
            child: Container(
              width: styles['cardwidth'],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(paramsStyle['cards'][i]['text']),
                ],
              ),
            ),
          ),
        ));
  }
}
