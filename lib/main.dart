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
      BuildContext context, int myIdx, ScrollableTabsState state) {
    return state.conditions
        .where((c) => c.persons.contains(myIdx))
        .map((c) {
          return [
            Divider(height: 1),
            InkWell(
                onTap: () => c.showEditDialog(context, state),
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
  ConditionData(String _label)
      : label = _label,
        name = _label;

  final String label;
  String name;
  double price = 0.0;
  List<int> persons = [];
  bool isNew = true;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();

  void showEditDialog(BuildContext context, ScrollableTabsState state) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setState) => SimpleDialog(
                  title: Text(isNew ? 'Add new condition' : 'Edit condition'),
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Container(
                            height: 6 * 48.0, // TODO: size appropriately
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                TextField(
                                  controller: namecontroller,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    filled: true,
                                    hintText: 'What do they have to pay for?',
                                    labelText: label,
                                  ),
                                  onChanged: (value) => setState(() {
                                        name = value;
                                      }),
                                ),
                                TextField(
                                  controller: pricecontroller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      filled: true,
                                      labelText: 'Price per person',
                                      hintText: 'How much did it cost?',
                                      prefixText: '\€ ',
                                      suffixText: 'Euro',
                                      suffixStyle:
                                          TextStyle(color: Colors.green)),
                                  onChanged: (value) => setState(() {
                                        price = double.tryParse(
                                                value.replaceAll(',', '.')) ??
                                            0.0;
                                      }),
                                  maxLines: 1,
                                )
                              ]..addAll(
                                  List.generate(state.personData.length, (idx) {
                                    return CheckboxListTile(
                                      title: Text(state.personData[idx].name),
                                      value: persons.contains(idx),
                                      secondary: Icon(Icons.person),
                                      onChanged: (value) => setState(() {
                                            if (value) {
                                              if (!persons.contains(idx))
                                                persons.add(idx);
                                            } else
                                              persons.remove(idx);
                                          }),
                                    );
                                  }),
                                ),
                            ))),
                    Container(
                        margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Center(
                                  child: FlatButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'REMOVE'),
                                      child: Row(children: [
                                        Icon(Icons.delete_forever),
                                        Text('REMOVE')
                                      ]))),
                              Center(
                                  child: FlatButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'SAVE'),
                                      child: Row(children: [
                                        Icon(Icons.check),
                                        Text('SAVE')
                                      ]))),
                            ])),
                  ])),
    ).then((value) {
      if (value == 'REMOVE') persons.clear();
      if (!state.conditions.contains(this)) {
        isNew = false;
        namecontroller.text = name;
        pricecontroller.text = price.toString();
        state.conditions.add(this);
      }
      state.updateResults();
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PersonData> personData = [
    PersonData('Person 1', 0),
    PersonData('Person 2', 0),
    PersonData('Person 3', 0),
    PersonData('Person 4', 0),
  ];

  List<ConditionData> conditions = [];

  String specialnote = '';

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

  void _add(BuildContext context) {
    switch (_pageid) {
      case PageID.Persons:
        setState(() {
          personData.add(
              PersonData('Person ' + (personData.length + 1).toString(), 0));
        });
        break;
      case PageID.Conditions:
        ConditionData('Condition ' + (conditions.length + 1).toString())
            .showEditDialog(context, this);
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
      conditions.removeWhere((c) => c.persons.isEmpty);
      for (int i = 0; i < personData.length; ++i) {
        if (personData[i].namecontroller.text.isNotEmpty)
          personData[i].name = personData[i].namecontroller.text;
        personData[i].paid = double.tryParse(
                personData[i].paidcontroller.text.replaceAll(',', '.')) ??
            0.0;
      }
      double total = personData.fold(0.0, (total, p) => total + p.paid);
      double priceperperson = total / personData.length;
      for (int i = 0; i < personData.length; ++i)
        personData[i].hastopay = priceperperson - personData[i].paid;
      for (ConditionData c in conditions) {
        for (int i = 0; i < personData.length; ++i) {
          personData[i].hastopay += (c.persons.contains(i) ? c.price : 0);
          personData[i].hastopay -=
              c.price * c.persons.length / personData.length;
        }
      }
      double totalconditionsprice = conditions.fold(
          0.0,
          (totalconditionsprice, c) =>
              totalconditionsprice + c.price * c.persons.length);
      if (totalconditionsprice >= total + 0.01)
        specialnote = 'Note: Total price of the conditions (' +
            totalconditionsprice.toStringAsFixed(2) +
            ') is greater than the total amount in the pot (' +
            total.toStringAsFixed(2) +
            ').';
      else
        specialnote = '';
    });
    if (specialnote.isNotEmpty)
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(specialnote)));
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
                            labelText: 'Has paid',
                            prefixText: '\€ ',
                            hintText: 'How much?',
                            suffixText: 'Euro',
                            suffixStyle: TextStyle(color: Colors.green)),
                        onChanged: (value) => updateResults(),
                        maxLines: 1,
                      ),
                    )
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
                              .buildConditionsList(context, idx, this)),
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

  Widget buildFloatingActionButton(BuildContext context) {
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
            onPressed: () => _add(context),
            tooltip: 'Add',
            child: Icon(Icons.add),
          ),
        ]);

      case PageID.Conditions:
        return FloatingActionButton(
          onPressed: () => _add(context),
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
      key: _scaffoldKey,
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
      floatingActionButton: buildFloatingActionButton(context),
    );
  }
}
