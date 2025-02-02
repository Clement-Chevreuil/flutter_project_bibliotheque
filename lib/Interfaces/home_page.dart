import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Interfaces/media/media_dashboard.dart';
import 'package:flutter_project_n1/Interfaces/media/media_index.dart';
import 'package:flutter_project_n1/constants/app_consts.dart';
import 'package:flutter_project_n1/enums/categories_enum.dart';
import 'package:flutter_project_n1/functions/database/replace_database.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool activeMediaIndex = true;
  late DatabaseInit _databaseInit;

  String? mediaIndexStatut;

  final home = MediaIndex(CategoriesEnum.series.name);
  String selectedCategories = CategoriesEnum.series.name;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    context.read<MediaProvider>().setCurrentPage(page);
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<MediaProvider>().pageName),
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
                  for (int i = 0; i < AppConsts.sidebarItems.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        selectedCategories = AppConsts.sidebarItems[i];
                        _changePage(i + 1);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppConsts.sidebarItems[i],
                        style: TextStyle(
                          fontWeight: AppConsts.sidebarItems[i] == selectedCategories ? FontWeight.bold : FontWeight.normal,
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

                      _changePage(0);

                      Navigator.pop(context);
                    },
                    child: const Text("Dashboard"),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     activeMediaIndex = false;
                  //
                  //       _changePage(8);
                  //
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text("Parametres"),
                  // ),
                  // TextButton(
                  //   onPressed: () {
                  //     activeMediaIndex = false;
                  //
                  //       _changePage(7);
                  //
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
                      replaceDatabase(_databaseInit);
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
          context.read<MediaProvider>().setCurrentPage(page);
        },
        children: <Widget>[
          MediaDashboard(
            onPageChanged: (page) {
              _changePage(page);
            },
          ),
          MediaIndex(CategoriesEnum.series.name), //1
          MediaIndex(CategoriesEnum.animes.name), //2
          MediaIndex(CategoriesEnum.games.name), //3
          MediaIndex(CategoriesEnum.webtoons.name), //4
          MediaIndex(CategoriesEnum.books.name), //5
          MediaIndex(CategoriesEnum.movies.name), //6
          //MediaCompare(),
          //UtilisateurManager(),
        ],
      ),
    );
  }
}
