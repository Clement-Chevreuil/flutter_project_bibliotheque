import 'package:flutter/material.dart';
import 'package:flutter_project_n1/constants/app_consts.dart';
import 'package:flutter_project_n1/interfaces/genres_index.dart';
import 'package:flutter_project_n1/interfaces/widgets/build_check_buttons.dart';
import 'package:flutter_project_n1/interfaces/widgets/build_radio_buttons.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';
import 'package:provider/provider.dart';

class AdvancedSearch extends StatelessWidget {
  const AdvancedSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 4.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Genre :',
                              style: TextStyle(
                                fontSize: 16, // Taille du texte
                                fontWeight: FontWeight.bold, // Texte en gras
                              ),
                            ),
                            Container(
                              transform: Matrix4.translationValues(0, -6.0, 0),
                              child: IconButton(
                                onPressed: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GenresIndex(
                                        mediaParam1: context.read<MediaProvider>().tableName,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    context.read<MediaProvider>().genresData();
                                  }
                                },
                                icon: const Icon(Icons.settings),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        buildCheckButtons(
                          context.watch<MediaProvider>().genresList,
                          context.watch<MediaProvider>().selectedGenres,
                          (selectedGenresReturn) {
                            context.read<MediaProvider>().updateSelectedGenres(selectedGenresReturn);
                          },
                          () {
                            context.read<MediaProvider>().setCurrentPage(1);
                            context.read<MediaProvider>().loadMedia();
                          },
                        ),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      // Marge autour du widget complet
                      child: const Column(children: [
                        Text(
                          "Ordre :",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    buildRadioButtons(AppConsts.orderList, context.watch<MediaProvider>().selectedOrder, false, (
                      selectedOrderReturn,
                    ) {
                      context.read<MediaProvider>().setSelectedOrder(selectedOrderReturn);
                    }, () {
                      context.read<MediaProvider>().setCurrentPage(1);
                      context.read<MediaProvider>().loadMedia();
                    }),
                    const SizedBox(height: 8.0),
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      // Marge autour du widget complet
                      child: const Column(children: [
                        Text(
                          "Statut :",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                      ]),
                    ),
                    //Statut
                    buildRadioButtons(AppConsts.statutList, context.watch<MediaProvider>().selectedStatut, true, (selectedStatutReturn) {
                      context.read<MediaProvider>().setSelectedStatut(selectedStatutReturn);
                    }, () {
                      context.read<MediaProvider>().setCurrentPage(1);
                      context.read<MediaProvider>().loadMedia();
                    }),
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      // Marge autour du widget complet
                      child: const Column(children: [
                        Text(
                          "Sens :",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                      ]),
                    ),
                    buildRadioButtons(AppConsts.orderListAscDesc, context.watch<MediaProvider>().selectedOrderAscDesc, false,
                        (selectedOrderAscDescReturn) {
                      context.read<MediaProvider>().setSelectedOrderAscDesc(selectedOrderAscDescReturn!);
                    }, () {
                      context.read<MediaProvider>().setCurrentPage(1);
                      context.read<MediaProvider>().loadMedia();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
