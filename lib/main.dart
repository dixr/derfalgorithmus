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

enum PageID {
  Persons,
  Conditions,
  Results,
}

class PersonData {
  PersonData(this.name, this.paid);
  String name = '';
  double paid = 0;
  double hastopay = 0;
  double conditiontopay = 0;
  bool conditionsexpanded = false;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController paidcontroller = TextEditingController();

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return Padding(
          padding: EdgeInsets.only(left: 16),
          child: Row(children: [
            SizedBox(width: 8),
            Expanded(
                flex: 3,
                child: Text(name,
                    style:
                        TextStyle(fontSize: 14.0, color: Color(0xdd000000)))),
            SizedBox(width: 8),
            Expanded(
                flex: 2,
                child: Text(conditiontopay.toStringAsFixed(2) + ' \€',
                    style: TextStyle(fontSize: 14.0, color: Color(0x8a000000))))
          ]));
    };
  }

  List<Widget> buildConditionsList() {
    return [
      Divider(height: 1),
      InkWell(
          onTap: () {}, // TODO: pass edit alert window callback
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text("Coffee",
                      style:
                          TextStyle(fontSize: 14.0, color: Color(0xdd000000))),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(conditiontopay.toStringAsFixed(2) + ' \€',
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 14.0, color: Color(0x8a000000))),
                ),
                SizedBox(width: 8),
              ])))
    ];
  }
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

  PageID _pageid = PageID.Persons;
  TabController _controller;

  List<PersonData> _personData = [
    PersonData('Person 1', 0),
    PersonData('Person 2', 0),
    PersonData('Person 3', 0),
    PersonData('Person 4', 0),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _allPages.length);
    _controller.addListener(_handlePageSelection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePageSelection() {
    setState(() {
      _pageid = PageID.values[_controller.index];
    });
  }

  void _add() {
    switch (_pageid) {
      case PageID.Persons:
        setState(() {
          _personData.add(
              PersonData('Person ' + (_personData.length + 1).toString(), 0));
        });
        break;
      default:
        break;
    }
    _updateResults();
  }

  void _remove() {
    switch (_pageid) {
      case PageID.Persons:
        if (_personData.length > 1)
          setState(() {
            _personData.removeLast();
          });
        break;
      default:
        break;
    }
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
      for (int i = 0; i < _personData.length; ++i)
        _personData[i].hastopay = sum - _personData[i].paid;
    });
  }

  Widget _createTabForms(int pageidx) {
    switch (PageID.values[pageidx]) {
      case PageID.Persons:
        return Column(children: [
          Card(
            elevation: 5,
            child: Column(
                children: List.generate(_personData.length, (idx) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(children: [
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
                    SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                      controller: _personData[idx].paidcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Money paid',
                          prefixText: '\€ ',
                          suffixText: 'Euro',
                          suffixStyle: TextStyle(color: Colors.green)),
                      onChanged: (value) => _updateResults(),
                      maxLines: 1,
                    ))
                  ]));
            })),
          ),
          SizedBox(
            height: 72,
          )
        ]);

      case PageID.Conditions:
        return Column(children: [
          Container(
              margin: EdgeInsets.all(8),
              child: ExpansionPanelList(
                  expansionCallback: (int idx, bool isExpanded) {
                    setState(() {
                      _personData[idx].conditionsexpanded = !isExpanded;
                    });
                  },
                  children: _personData.map((p) {
                    return ExpansionPanel(
                      isExpanded: p.conditionsexpanded,
                      headerBuilder: p.headerBuilder,
                      body: Column(children: p.buildConditionsList()),
                    );
                  }).toList())),
          SizedBox(
            height: 72,
          )
        ]);

      case PageID.Results:
        return Card(
          elevation: 2,
          child: DataTable(
            columns: [
              DataColumn(
                label: Text('Person'),
                onSort: (i, b) {},
              ),
              DataColumn(
                label: Text('Has to pay'),
                tooltip: 'The total amount of money this person has to pay.',
                numeric: true,
                onSort: (i, b) {},
              ),
            ],
            rows: _personData
                .map((p) => DataRow(cells: [
                      DataCell(Text(p.name), onTap: () {}),
                      DataCell(Text(p.hastopay.toStringAsFixed(2) + ' \€'),
                          onTap: () {}),
                    ]))
                .toList(),
          ),
        );
    }
    return null;
  }

  Widget _buildFloatingActionButton() {
    switch (_pageid) {
      case PageID.Persons:
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: _remove,
            tooltip: 'Remove',
            child: Icon(Icons.remove),
          ),
          SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            onPressed: _add,
            tooltip: 'Add',
            child: Icon(Icons.add),
          ),
        ]);

      case PageID.Conditions:
        return FloatingActionButton(
          onPressed: _add,
          tooltip: 'Add',
          child: Icon(Icons.add),
        );

      default:
        return null;
    }
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
          )),
      body: TabBarView(
          controller: _controller,
          children: List.generate(
            _allPages.length,
            (pageidx) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Container(
                    margin:
                        EdgeInsets.all(_pageid == PageID.Conditions ? 4 : 8),
                    alignment: Alignment(0.0, -1.0),
                    child:
                        SingleChildScrollView(child: _createTabForms(pageidx))),
              );
            },
          )),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
