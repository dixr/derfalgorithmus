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
  static const String routeName = '/material/scrollable-tabs';

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

  List<Widget> _createTabForms(int pageidx) {
    final widgets = <Widget>[];
    if (pageidx == 0) {
      for (int idx = 0; idx < _personData.length; idx++) {
        widgets.add(const SizedBox(height: 16.0));
        widgets.add(TextFormField(
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            icon: Icon(Icons.person),
            hintText: 'What do people call you?',
            labelText: 'Person ' + (idx + 1).toString(),
          ),
          onSaved: (String value) {
            _personData[idx].name = value;
          },
        ));
        widgets.add(const SizedBox(height: 16.0));
        widgets.add(TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Money paid',
              prefixText: '\€',
              suffixText: 'Euro',
              suffixStyle: TextStyle(color: Colors.green)),
          maxLines: 1,
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
        Center(
          child: Icon(
            _allPages[pageidx].icon,
            size: 128.0,
          ),
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
        title: const Text('DerFAlgorithmus'),
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
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _createTabForms(pageidx)),
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
