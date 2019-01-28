import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'DerFAlgorithmus',
    theme: ThemeData(primarySwatch: Colors.cyan),
    home: ScrollableTabs(),
  ));
}

class _Page {
  const _Page({this.icon, this.text});
  final IconData icon;
  final String text;
}

const List<_Page> _allPages = <_Page>[
  _Page(icon: Icons.group, text: 'PERSONS'),
  _Page(icon: Icons.playlist_add, text: 'CONDITIONS'),
  _Page(icon: Icons.check_circle, text: 'RESULTS'),
];

class PersonData {
  PersonData(this.name, this.paid);
  String name = '';
  double paid = 0;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController paidcontroller = TextEditingController();
}

class ScrollableTabs extends StatefulWidget {
  @override
  ScrollableTabsState createState() => ScrollableTabsState();
}

class ScrollableTabsState extends State<ScrollableTabs>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<ScrollableTabs> {
  @override
  bool get wantKeepAlive => true;

  TabController _controller;

  List<PersonData> _personData = [
    PersonData('Person 1', 0),
    PersonData('Person 2', 0),
    PersonData('Person 3', 0),
    PersonData('Person 4', 0),
  ];

  List<PersonData> _resultsData = [];

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _allPages.length);
    _resultsData = _personData.map((p) => PersonData(p.name, p.paid)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    setState(() {
      switch (_controller.index) {
        case 0:
          _personData.add(
              PersonData('Person ' + (_personData.length + 1).toString(), 0));
          break;
      }
    });
    _updateResults();
  }

  void _remove() {
    setState(() {
      switch (_controller.index) {
        case 0:
          if (_personData.length > 1) _personData.removeLast();
          break;
      }
    });
    _updateResults();
  }

  void _updateResults() {
    setState(() {
      for (int i = 0; i < _personData.length; ++i) {
        if (_personData[i].namecontroller.text.isNotEmpty)
          _personData[i].name = _personData[i].namecontroller.text;
        _personData[i].paid = double.tryParse(
                _personData[i].paidcontroller.text.replaceAll(',', '.')) ??
            0.0;
        print(_personData[i].name +
            ': ' +
            _personData[i].paid.toStringAsFixed(2));
      }
      double sum =
          _personData.fold(0.0, (sum, p) => sum + p.paid) / _personData.length;
      _resultsData =
          _personData.map((p) => PersonData(p.name, sum - p.paid)).toList();
    });
  }

  List<Widget> _createTabForms(int pageidx) {
    final widgets = <Widget>[];
    if (pageidx == 0) {
      for (int idx = 0; idx < _personData.length; idx++) {
        widgets.add(Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _personData[idx].namecontroller,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Name',
                    labelText: 'Person ' + (idx + 1).toString(),
                  ),
                  onChanged: (value) => _updateResults(),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _personData[idx].paidcontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Money paid',
                      prefixText: '\€',
                      suffixText: 'Euro',
                      suffixStyle: TextStyle(color: Colors.green)),
                  onChanged: (value) => _updateResults(),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ));
      }
    } else if (pageidx == 1) {
      widgets.add(
        Center(
          child: Icon(
            _allPages[pageidx].icon,
            size: 128.0,
          ),
        ),
      );
    } else {
      widgets.add(
        DataTable(
          columns: [
            DataColumn(
              label: Text('Person'),
              onSort: (i, b) {},
            ),
            DataColumn(
              label: Text('has to pay'),
              tooltip:
                  'The total amount of money this person has to put in the pot.',
              numeric: true,
              onSort: (i, b) {},
            ),
          ],
          rows: _resultsData
              .map(
                (p) => DataRow(
                      cells: [
                        DataCell(Text(p.name), onTap: () {}),
                        DataCell(Text(p.paid.toStringAsFixed(2)), onTap: () {}),
                      ],
                    ),
              )
              .toList(),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('DerFAlgorithmus'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          indicator: UnderlineTabIndicator(),
          tabs: _allPages.map<Tab>((_Page page) {
            return Tab(text: page.text, icon: Icon(page.icon));
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: List.generate(
          _allPages.length,
          (pageidx) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Container(
                key: ObjectKey(_allPages[pageidx].icon),
                padding: EdgeInsets.all(8.0),
                child: Card(
                  child: ListView(
                    padding: EdgeInsets.all(8),
                    children: _createTabForms(pageidx),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _remove,
            tooltip: 'Remove',
            child: Icon(Icons.remove),
          ),
          SizedBox(height: 4),
          FloatingActionButton(
            onPressed: _add,
            tooltip: 'Add',
            child: Icon(Icons.add),
          )
        ],
      ),
    );
  }
}
