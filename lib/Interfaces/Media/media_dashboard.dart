import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/Logic/line_chart_sample.dart';
import 'package:flutter_project_n1/Model/media.dart';
import 'package:flutter_project_n1/constants/const.dart';
import 'package:intl/intl.dart';

class MediaDashboard extends StatefulWidget {
  final Function(int, String?) onPageChanged;

  MediaDashboard({required this.onPageChanged});

  @override
  _MediaDashboardState createState() => _MediaDashboardState();
}

class _MediaDashboardState extends State<MediaDashboard> {
  late DatabaseInit _databaseInit;

  List<String> GenresList = [];

  List<Media>? mostRecentRecords;

  int selectMediaPage = 1;

  bool isInitComplete = false;
  int selectedGenreIndex = 0;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  String tableName = "Series";

  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  Map<String, int>? count;
  List<Map<String, dynamic>>? countDate = null;

  _MediaDashboardState();

  Map<String, int>? countsByStatut = null;

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    getLoadPage().then((value) => {isInitComplete = true});
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitComplete) {
      // Attendre que l'initialisation soit terminée
      return CircularProgressIndicator(); // Ou tout autre indicateur de chargement
    }

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text("All Category"),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConst.sidebarItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return InkWell(
                  onTap: () {
                    // Méthode pour naviguer vers la page "MediaCompare"
                    widget.onPageChanged(index + 1,
                        null); // Vous pouvez passer l'index de la page que vous souhaitez afficher
                  },
                  child: Container(
                    //height: MediaQuery.of(context).size.height * 0.2,
                    constraints: const BoxConstraints(
                      maxHeight: 80.0,
                      maxWidth: 120.0,
                      minWidth: 120.0,
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 7.0, vertical: 5.0),
                    child: Card(
                      elevation: 8.0,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Aligns children center vertically
                          children: [
                            Text(item, textAlign: TextAlign.center),
                            // Optional: center text horizontally
                            Text(count != null ? count![item].toString() : " 0",
                                textAlign: TextAlign.center)
                            // Optional: center text horizontally
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text("Category"),
            ),
          ),
          Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            children: AppConst.sidebarItems.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return Container(
                width: 120.0,
                height: 60.0,
                margin: EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedGenreIndex == index) {
                        // Désélectionnez l'élément s'il est déjà sélectionné
                        selectedGenreIndex = -1;
                      } else {
                        selectedGenreIndex = index;
                      }
                      tableName = AppConst.sidebarItems[index];
                      if (tableName == "Series") {
                        selectMediaPage = 1;
                      }
                      if (tableName == "Animes") {
                        selectMediaPage = 2;
                      }
                      if (tableName == "Games") {
                        selectMediaPage = 3;
                      }
                      if (tableName == "Webtoons") {
                        selectMediaPage = 4;
                      }
                      if (tableName == "Books") {
                        selectMediaPage = 5;
                      }
                      if (tableName == "Movies") {
                        selectMediaPage = 6;
                      }
                      bdMedia.changeTable(tableName);
                      getLoadPage();
                    });
                    print("Genre sélectionné : ${AppConst.sidebarItems[index]}");
                  },
                  // style: ElevatedButton.styleFrom(
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //     primary: selectedGenreIndex == index
                  //         ? Color.fromARGB(255, 222, 233, 243)
                  //         : Color.fromARGB(59, 222, 233,
                  //             243) // Changez la couleur du bouton ici
                  //     ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: selectedGenreIndex == index
                          ? Colors.black
                          : Colors.black,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(AppConst.sidebarItems[0]),
                ),
                Row(
                  children: [
                    Container(
                      height: 165.0,
                      width: 250.0,
                      child: Wrap(
                        spacing: 5.0, // gap between adjacent chips
                        runSpacing: 5.0, // gap between lines
                        children: AppConst.mediaData.map((data) {
                          return InkWell(
                            onTap: () {
                              widget.onPageChanged(
                                  selectMediaPage, data["label"]);
                            },
                            child: Container(
                              width: 120.0,
                              height: 80.0,
                              child: Card(
                                elevation: 9.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(data["label"]),
                                    Text(countsByStatut![data["countKey"]]
                                        .toString()),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 165.0,
                        child: Card(
                          elevation: 8.0,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Center(
                              child: countDate != null &&
                                      countDate! != [] &&
                                      countDate!.isNotEmpty
                                  ? LineChartSample(data: countDate!)
                                  : const Text(
                                      'No Data'), // Replace 'Loading data...' with your desired text
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Last Created/Updated"),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMostRecentRecords(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data?.length == 0) {
                  return const Center(
                    child: Text('Aucun Media.'),
                  );
                } else {
                  mostRecentRecords = snapshot.data!;
                  return ListView.builder(
                    key: _listKey,
                    itemCount: mostRecentRecords!.length + 1,
                    itemBuilder: (context, index) {
                      if (index < mostRecentRecords!.length) {
                        Media media = mostRecentRecords![index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 5.0), // Espace autour de la Card
                          child: Card(
                            elevation: 8.0,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  16.0), // Espace à l'intérieur de la Card
                              child: Row(
                                children: [
                                  // Informations sur le livre à droite
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              media.nom ?? '',
                                            ),
                                          ),
                                          if (media.updated_at != null)
                                            const Expanded(
                                              child: Text("Update"),
                                            )
                                          else
                                            const Expanded(
                                              child: Text("Create"),
                                            ),
                                          if (media.updated_at != null)
                                            Text(DateFormat("MMM d, ''yy")
                                                .format(media.updated_at!))
                                          else
                                            Text(DateFormat("MMM d, ''yy")
                                                .format(media.created_at!)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox(height: 50);
                      }
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Evolutions de vos Genres"),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Future getLoadPage() async {
    count = await bdMedia.getCountsForTables();
    countsByStatut = await bdMedia.getCountsByStatut();
    mostRecentRecords = await bdMedia.getMostRecentRecords();
    countDate = await bdMedia.getCountByDate();
    bdMedia.getMostViewedGenresByMonth();
    setState(() {});
  }
}
