import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Interfaces/Media/media_dashboard.dart';
import 'package:flutter_project_n1/Interfaces/Media/media_index.dart';
import 'package:flutter_project_n1/Logic/replace_database.dart';
import 'package:flutter_project_n1/constants/const.dart';

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
  late DatabaseInit _databaseInit;

  String? mediaIndexStatut = null;

  final home = new MediaIndex("Series",null);
  String selectedTableName = "Series";

  static int _currentPage = 0;
  PageController _pageController = PageController();

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    
  }

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
        title: Text(AppConst.ItemsTitle[_currentPage]),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
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
                  for (int i = 0; i < AppConst.sidebarItems.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        backgroundColor: AppConst.sidebarItems[i] == selectedTableName
                            ? MaterialStateProperty.all(Colors.transparent)
                            : MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedTableName = AppConst.sidebarItems[i];
                          _changePage(i + 1, null);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppConst.sidebarItems[i],
                        style: TextStyle(
                          fontWeight: AppConst.sidebarItems[i] == selectedTableName
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
                    child: const Text("Dashboard"),
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
                    child: const Text("Exporter BDD"),
                  ),
                  TextButton(
                    onPressed: () {
                      ReplaceDatabse.replaceDatabase(_databaseInit);
                      Navigator.pop(context);
                    },
                    child: const Text("Remplacer BDD"),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          MediaDashboard(onPageChanged: (page, mediaIndexStatut) {_changePage(page, mediaIndexStatut); },),
          MediaIndex("Series",mediaIndexStatut), //1
          MediaIndex("Animes",mediaIndexStatut), //2
          MediaIndex("Games",mediaIndexStatut), //3
          MediaIndex("Webtoons",mediaIndexStatut), //4
          MediaIndex("Books",mediaIndexStatut), //5
          MediaIndex("Movies", mediaIndexStatut), //6
          //MediaCompare(),
          //UtilisateurManager(),
        ],
      ),
    );
  }


}
