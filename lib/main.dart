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
}

class ScrollableTabs extends StatefulWidget {
  @override
  ScrollableTabsState createState() => ScrollableTabsState();
}

class ScrollableTabsState extends State<ScrollableTabs>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  List<PersonData> _personData = [
    PersonData('Person 1', 0),
    PersonData('Person 2', 0),
    PersonData('Person 3', 0),
    PersonData('Person 4', 0),
  ];

  List<PersonData> _resultsData = [];

  void _add() {
    setState(() {
      switch (_controller.index) {
        case 0:
          _personData
              .add(PersonData('Person ' + _personData.length.toString(), 0));
          break;

        case 1:
          break;
      }
    });
  }

  void _remove() {
    setState(() {
      switch (_controller.index) {
        case 0:
          if (_personData.length > 1) _personData.removeLast();
          break;

        case 1:
          break;
      }
    });
  }

  void _computeResults() {
    double sum =
        _personData.fold(0.0, (sum, p) => sum + p.paid) / _personData.length;
    _resultsData = _personData
        .map((p) => PersonData(p.name, sum - p.paid))
        .toList(); // TODO: change to text with instruction
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
                child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'Name',
                      labelText: 'Person ' + (idx + 1).toString(),
                    ),
                    onSaved: (value) => _personData[idx].name = value),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Money paid',
                      prefixText: '\€',
                      suffixText: 'Euro',
                      suffixStyle: TextStyle(color: Colors.green)),
                  onSaved: (value) =>
                      _personData[idx].paid = num.tryParse(value),
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
      _computeResults();
      widgets.add(
        DataTable(
          columns: [
            DataColumn(
              label: Text('Person'),
            ),
            DataColumn(
              label: Text('Action'),
              tooltip:
                  'The total amount of money this person has to put in the pot.',
              numeric: true,
            ),
          ],
          rows: _resultsData
              .map(
                (p) => DataRow(
                      cells: [
                        DataCell(Text(p.name)),
                        DataCell(Text(p.paid.toString())),
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
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _allPages.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
