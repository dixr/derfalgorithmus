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
  double conditionstopay = 0;
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
                child: Text(conditionstopay.toStringAsFixed(2) + ' \€',
                    style: TextStyle(fontSize: 14.0, color: Color(0x8a000000))))
          ]));
    };
  }

  List<Widget> buildConditionsList(
      BuildContext context, int myIdx, List<ConditionData> conditions) {
    return conditions
        .where((c) => c.persons.contains(myIdx))
        .map((c) {
          return [
            Divider(height: 1),
            InkWell(
                onTap: () => c.showEditDialog(context,
                    conditions), // if this doesn't work without setState, pass a callback from ScrollableTabsState
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(c.name,
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0xdd000000))),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(c.price.toStringAsFixed(2) + ' \€',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0x8a000000))),
                      ),
                      SizedBox(width: 8),
                    ])))
          ];
        })
        .expand((i) => i)
        .toList();
  }
}

class ConditionData {
  ConditionData(this.name, this.price, this.persons);

  String name = "";
  double price = 0.0;
  List<int> persons = [];
  bool isNew = true;

  void showEditDialog(BuildContext context, List<ConditionData> conditions) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
              title: Text(isNew ? 'Add new condition' : 'Edit condition'),
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        hintText: 'What do they have to pay for?',
                        labelText:
                            'Condition ' + (conditions.length + 1).toString(),
                      ),
                      onChanged: (value) => () {},
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          labelText: 'Price',
                          prefixText: '\€ ',
                          suffixText: 'Euro',
                          suffixStyle: TextStyle(color: Colors.green)),
                      onChanged: (value) => () {},
                      maxLines: 1,
                    )),
                //Divider(height: 1),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                          child: FlatButton(
                              onPressed: () {},
                              child: Row(children: [
                                Icon(Icons.delete_forever),
                                Text('REMOVE')
                              ]))),
                      Center(
                          child: FlatButton(
                              onPressed: () {},
                              child: Row(children: [
                                Icon(Icons.check),
                                Text('SAVE')
                              ]))),
                    ]),
              ]),
      // Navigator.pop(context, 'user03@gmail.com');
    ).then((value) {
      // parse value, need to call setState to save?
    });
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

  List<PersonData> personData = [
    PersonData('Person 1', 0),
    PersonData('Person 2', 0),
    PersonData('Person 3', 0),
    PersonData('Person 4', 0),
  ];

  List<ConditionData> conditions = [
    ConditionData('Coffee', 2.0, [1, 2, 5]),
    ConditionData('Bread', 5.0, [0, 2, 20]),
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
          personData.add(
              PersonData('Person ' + (personData.length + 1).toString(), 0));
        });
        break;
      default:
        break;
    }
    updateResults();
  }

  void _remove() {
    switch (_pageid) {
      case PageID.Persons:
        if (personData.length > 1)
          setState(() {
            personData.removeLast();
          });
        break;
      default:
        break;
    }
    updateResults();
  }

  void updateResults() {
    setState(() {
      for (int i = 0; i < personData.length; ++i) {
        if (personData[i].namecontroller.text.isNotEmpty)
          personData[i].name = personData[i].namecontroller.text;
        personData[i].paid = double.tryParse(
                personData[i].paidcontroller.text.replaceAll(',', '.')) ??
            0.0;
        print(
            personData[i].name + ': ' + personData[i].paid.toStringAsFixed(2));
      }
      double sum =
          personData.fold(0.0, (sum, p) => sum + p.paid) / personData.length;
      for (int i = 0; i < personData.length; ++i)
        personData[i].hastopay = sum - personData[i].paid;
    });
  }

  Widget createTabForms(BuildContext context, int pageidx) {
    switch (PageID.values[pageidx]) {
      case PageID.Persons:
        return Column(children: [
          Card(
            elevation: 5,
            child: Column(
                children: List.generate(personData.length, (idx) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: personData[idx].namecontroller,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Name',
                          labelText: 'Person ' + (idx + 1).toString(),
                        ),
                        onChanged: (value) => updateResults(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                      controller: personData[idx].paidcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Money paid',
                          prefixText: '\€ ',
                          suffixText: 'Euro',
                          suffixStyle: TextStyle(color: Colors.green)),
                      onChanged: (value) => updateResults(),
                      maxLines: 1,
                    ))
                  ]));
            })),
          ),
          SizedBox(height: 72)
        ]);

      case PageID.Conditions:
        return Column(children: [
          Container(
              margin: EdgeInsets.all(8),
              child: ExpansionPanelList(
                  expansionCallback: (int idx, bool isExpanded) {
                    setState(() {
                      personData[idx].conditionsexpanded = !isExpanded;
                    });
                  },
                  children: List.generate(personData.length, (idx) {
                    return ExpansionPanel(
                      isExpanded: personData[idx].conditionsexpanded,
                      headerBuilder: personData[idx].headerBuilder,
                      body: Column(
                          children: personData[idx]
                              .buildConditionsList(context, idx, conditions)),
                    );
                  }))),
          SizedBox(height: 72)
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
            rows: personData
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

  Widget buildFloatingActionButton() {
    switch (_pageid) {
      case PageID.Persons:
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: _remove,
            tooltip: 'Remove',
            child: Icon(Icons.remove),
          ),
          SizedBox(width: 8),
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
                    child: SingleChildScrollView(
                        child: createTabForms(context, pageidx))),
              );
            },
          )),
      floatingActionButton: buildFloatingActionButton(),
    );
  }
}
