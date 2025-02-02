// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_project_n1/Database/database_genre.dart';
// import 'package:flutter_project_n1/Database/database_init.dart';
// import 'package:flutter_project_n1/Database/database_media.dart';
// import 'package:flutter_project_n1/Database/database_reader.dart';
// import 'package:flutter_project_n1/constants/app_consts.dart';
// import 'package:flutter_project_n1/models/genre.dart';
// import 'package:flutter_project_n1/models/media.dart';
// import 'package:flutter_project_n1/models/media_dual.dart';
// import 'package:getwidget/getwidget.dart';
// import 'dart:typed_data';

// class MediaCompare extends StatefulWidget {
//   final String? mediaParam1;

//   const MediaCompare({super.key, this.mediaParam1});

//   @override
//   State<MediaCompare> createState() => _MediaCompareState(mediaParam1: mediaParam1);
// }

// class _MediaCompareState extends State<MediaCompare> {
//   final String? mediaParam1;
//   final TextEditingController _controllerNom = TextEditingController(text: '');
//   String? pathNewDb;
//   int selectedGenreIndex = -1;
//   int? idUpdate;
//   List<MediaDual> mediaCompareList = [];
//   List<MediaDual> compare = [];
//   String tableName = "Series";
//   List<Genre> genres = [];
//   List<Media> medias = [];
//   List<Media>? mediaBdd2 = [];
//   final bdCompare = DatabaseReader();
//   final bdGenres = DatabaseGenre();
//   final bdMedia = DatabaseMedia("Series");
//   String? querySecondBdd;

//   final GlobalKey<AnimatedListState> _listKey = GlobalKey();

//   _MediaCompareState({this.mediaParam1});

//   @override
//   void initState() {
//     super.initState();
//     DatabaseInit();

//     if (mediaParam1 != null) {
//       tableName = mediaParam1!;
//       selectedGenreIndex = AppConsts.sidebarItems.indexOf(mediaParam1!);
//     }

//     loadDatas();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Container(
//             margin: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5.0),
//               border: Border.all(
//                 color: Colors.black, // Couleur du bord en noir
//                 width: 1.0, // Bordure plus fine
//               ),
//               color: Colors.transparent, // Fond transparent
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     style: const TextStyle(
//                       color: Colors.black, // Texte en noir
//                       fontSize: 16.0, // Taille du texte
//                     ),
//                     decoration: InputDecoration(
//                       hintText: "Recherche...",
//                       hintStyle: TextStyle(
//                         color: Colors.black.withOpacity(0.5), // Texte d'indication en noir
//                       ),
//                       border: InputBorder.none,
//                     ),
//                     controller: _controllerNom,
//                   ),
//                 ),
//                 // IconButton(
//                 //   icon: Icon(
//                 //     Icons.search,
//                 //     color: Colors.black, // Icône en noir
//                 //   ),
//                 //   onPressed: () {},
//                 // ),
//               ],
//             ),
//           ),
//           Wrap(
//             spacing: 0.0,
//             runSpacing: 0.0,
//             children: AppConsts.sidebarItems.asMap().entries.map((entry) {
//               int index = entry.key;
//               String item = entry.value;
//               return Container(
//                 width: 100.0,
//                 height: 40.0,
//                 margin: const EdgeInsets.all(2.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       if (selectedGenreIndex == index) {
//                         // Désélectionnez l'élément s'il est déjà sélectionné
//                         selectedGenreIndex = -1;
//                       } else {
//                         selectedGenreIndex = index;
//                       }
//                       tableName = AppConsts.sidebarItems[index];
//                     });
//                     bdMedia.changeTable(tableName);
//                     loadDatas();
//                   },
//                   // style: ElevatedButton.styleFrom(
//                   //   shape: RoundedRectangleBorder(
//                   //     borderRadius: BorderRadius.circular(10.0),
//                   //   ),
//                   //   primary: selectedGenreIndex == index
//                   //       ? Colors.blue
//                   //       : Colors.grey, // Changez la couleur du bouton ici
//                   // ),
//                   child: Text(
//                     item,
//                     style: TextStyle(
//                       color: selectedGenreIndex == index ? Colors.white : Colors.black,
//                       fontSize: 11.0,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//           Expanded(
//             child: FutureBuilder<List<MediaDual>>(
//               future: data(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data == null) {
//                   return const Center(
//                     child: Text('Aucun Genre.'),
//                   );
//                 } else {
//                   compare = snapshot.data!;
//                   return ListView.builder(
//                     key: _listKey,
//                     itemCount: compare.length + 1,
//                     itemBuilder: (context, index) {
//                       if (index < compare.length) {
//                         MediaDual mediaDual = compare[index];
//                         return Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
//                           child: Card(
//                             elevation: 8.0,
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           GFTypography(
//                                             text: mediaDual.nom ?? '',
//                                             type: GFTypographyType.typo5,
//                                           ),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   const Text("Moi"),
//                                                   Text("Note 1: ${mediaDual.note ?? 'N/A'}"),
//                                                   Text("Statut 1: ${mediaDual.statut ?? 'N/A'}"),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(right: 8.0),
//                                                 child: Image.memory(
//                                                   mediaDual.image ?? Uint8List(0),
//                                                   height: 120, // Ajustez la hauteur de l'image
//                                                   width: 90, // Ajustez la largeur de l'image
//                                                 ),
//                                               ),
//                                               // Colonne "toi"
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                                 children: [
//                                                   const Text("Toi"),
//                                                   Text("Note 2: ${mediaDual.note2 ?? 'N/A'}"),
//                                                   Text("Statut 2: ${mediaDual.statut2 ?? 'N/A'}"),
//                                                 ],
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         return const SizedBox(height: 50);
//                       }
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> chooseBDD() async {
//     String querySecondBdd = "SELECT * FROM $tableName WHERE LENGTH(Image) <= ${2 * 1024 * 1024} ";
//     int i = 0;
//     for (Media med in medias) {
//       if (i == 0) {
//         querySecondBdd += 'AND (Nom LIKE "%${med.nom!}%" ';
//       } else {
//         querySecondBdd += 'OR Nom LIKE "%${med.nom!}" ';
//       }
//       i++;
//     }
//     querySecondBdd += ') LIMIT 90';
//     mediaBdd2 = await bdCompare.ChooseDatabase(querySecondBdd);
//   }

//   Future<List<MediaDual>> data() async {
//     setState(() {
//       _listKey.currentState?.setState(() {}); // Mettre à jour la ListView.builder
//     });
//     return compare;
//   }

//   Future<void> loadDatas() async {
//     medias.clear();
//     mediaBdd2 = [];
//     getMyMedia().then((_) {
//       chooseBDD().then((_) {
//         List<String> nomsSecondeListe = mediaBdd2!.map((element) => element.nom!).toList();
//         medias.removeWhere((personnage) => !nomsSecondeListe.contains(personnage.nom));
//         compare = createMediaCompareList(medias, mediaBdd2!);
//         data();
//       });
//     });
//   }

//   Future<void> getMyMedia() async {
//     medias = await bdMedia.getMediasSimpleVersion();
//   }

//   List<MediaDual> createMediaCompareList(List<Media> media, List<Media> mediaBdd2) {
//     List<MediaDual> mediaCompareList = [];

//     for (Media mediaItem in media) {
//       // Recherche du média correspondant dans mediaBdd2 par nom
//       Media? matchingMediaBdd2 = mediaBdd2.firstWhere((mediaBdd2Item) => mediaBdd2Item.nom == mediaItem.nom);

//       if (matchingMediaBdd2 != null) {
//         // Si un correspondant est trouvé, crée un MediaCompare
//         MediaDual mediaCompare = MediaDual(
//           nom: mediaItem.nom,
//           nom2: matchingMediaBdd2.nom,
//           note: mediaItem.note,
//           note2: matchingMediaBdd2.note,
//           statut: mediaItem.statut,
//           statut2: matchingMediaBdd2.statut,
//           image: mediaItem.image,
//         );
//         mediaCompareList.add(mediaCompare);
//       }
//     }

//     return mediaCompareList;
//   }
// }
