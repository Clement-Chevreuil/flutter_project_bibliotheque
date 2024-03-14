import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Function/ReplaceDatabase.dart';
import '../../data/datacontrol/database_init.dart';
import 'media_dashboard.dart';
import 'media_index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool activeMediaIndex = true;
  int _currentIndex = 0;
  late DatabaseInit _databaseInit;
  ReplaceDatabase replaceDatabase = new ReplaceDatabase();

  final home = new MediaIndex("Series", null);

  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

  final List<String> ItemsTitle = [
    "Dashboard",
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies",
    "Compare",
    "Parametres",
  ];

  String? mediaIndexStatut = null;

  List<IconData> itemIcons = [
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie
  ];
  String selectedTableName = "Series";

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
  }

  static int _currentPage = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int page, String? statut) {
    setState(() {
      mediaIndexStatut = statut;
      _currentPage = page;
      _pageController.jumpToPage(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ItemsTitle[_currentPage]),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < sidebarItems.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        backgroundColor: sidebarItems[i] == selectedTableName
                            ? MaterialStateProperty.all(Colors.transparent)
                            : MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedTableName = sidebarItems[i];
                          _changePage(i + 1, null);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        sidebarItems[i],
                        style: TextStyle(
                          fontWeight: sidebarItems[i] == selectedTableName
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      activeMediaIndex = false;
                      setState(() {
                        _changePage(0, null);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Dashboard"),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     activeMediaIndex = false;
                  //     setState(() {
                  //       _changePage(8);
                  //     });
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text("Parametres"),
                  // ),
                  // TextButton(
                  //   onPressed: () {
                  //     activeMediaIndex = false;
                  //     setState(() {
                  //       _changePage(7);
                  //     });
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text("Compare Media With Other"),
                  // ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _databaseInit.exportDatabaseWithUserChoice();
                    },
                    child: Text("Exporter BDD"),
                  ),
                  TextButton(
                    onPressed: () {
                      replaceDatabase.replaceDatabase(_databaseInit);
                      Navigator.pop(context);
                    },
                    child: Text("Remplacer BDD"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          MediaDashboard(
            onPageChanged: (page, mediaIndexStatut) {
              _changePage(page, mediaIndexStatut);
            },
          ),
          MediaIndex("Series", mediaIndexStatut), //1
          MediaIndex("Animes", mediaIndexStatut), //2
          MediaIndex("Games", mediaIndexStatut), //3
          MediaIndex("Webtoons", mediaIndexStatut), //4
          MediaIndex("Books", mediaIndexStatut), //5
          MediaIndex("Movies", mediaIndexStatut), //6
          //MediaCompare(),
          //UtilisateurManager(),
        ],
      ),
    );
  }
}
