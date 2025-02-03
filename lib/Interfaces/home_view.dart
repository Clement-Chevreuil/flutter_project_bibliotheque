import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/enums/categories_enum.dart';
import 'package:flutter_project_n1/functions/database/replace_database.dart';
import 'package:flutter_project_n1/interfaces/dashboard_view.dart';
import 'package:flutter_project_n1/interfaces/media_index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
                    decoration: BoxDecoration(),
                    child: Center(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < CategoriesEnum.values.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      onPressed: () {
                        selectedCategories = CategoriesEnum.values[i].name;
                        _changePage(i + 1);
                        Navigator.pop(context);
                      },
                      child: Text(
                        CategoriesEnum.values[i].name,
                        style: TextStyle(
                          fontWeight: CategoriesEnum.values[i].name == selectedCategories ? FontWeight.bold : FontWeight.normal,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              context.read<MediaProvider>().setCurrentPage(page);
            },
            children: <Widget>[
              DashboardView(
                onPageChanged: (page) {
                  _changePage(page);
                },
              ),
              MediaIndex(CategoriesEnum.series.name),
              MediaIndex(CategoriesEnum.animes.name),
              MediaIndex(CategoriesEnum.games.name),
              MediaIndex(CategoriesEnum.webtoons.name),
              MediaIndex(CategoriesEnum.books.name),
              MediaIndex(CategoriesEnum.movies.name),
            ],
          ),
        ),
      ),
    );
  }
}
