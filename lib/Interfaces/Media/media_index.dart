import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/constants/app_consts.dart';
import 'package:flutter_project_n1/interfaces/media/widgets/advanced_search.dart';
import 'package:flutter_project_n1/interfaces/media/widgets/media_widget.dart';
import 'package:flutter_project_n1/interfaces/widgets/pagination_builder.dart';
import 'package:flutter_project_n1/models/media.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';
import 'package:provider/provider.dart';
import 'media_manager.dart';
import 'package:intl/intl.dart';

class MediaIndex extends StatefulWidget {
  final String mediaParam1;

  const MediaIndex(this.mediaParam1, {super.key});

  @override
  State<MediaIndex> createState() => _MediaIndexState();
}

class _MediaIndexState extends State<MediaIndex> {
  final String? mediaParam1;

  final DateFormat formatter = DateFormat('yyyy MM dd');
  final TextEditingController _controllerNom = TextEditingController();

  List<String> statutList = AppConsts.statutList;
  _MediaIndexState() : mediaParam1 = null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().setTableName(widget.mediaParam1);
      context.read<MediaProvider>().loadMedia();
      DatabaseInit();
      context.read<MediaProvider>().genresData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaManager(
                mediaParam: null,
                tableName: context.read<MediaProvider>().tableName,
              ),
            ),
          );
          if (result != null) {
            if (!context.mounted) {
              return;
            }
            context.read<MediaProvider>().loadMedia();
          }
        },
        mini: true,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      hintText: "Recherche...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5), // Texte d'indication en noir
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      context.read<MediaProvider>().setSearch(value);
                      context.read<MediaProvider>().loadMedia();
                    },
                    controller: _controllerNom,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<MediaProvider>().toggleAdvancedSearchVisible();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      Icons.sort,
                      color: Colors.black, // Icône en noir
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (context.watch<MediaProvider>().isAdvancedSearchVisible) const AdvancedSearch(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (Media media in context.watch<MediaProvider>().medias) MediaWidget(media: media),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: context.read<MediaProvider>().pageMax != null
                ? paginationBuilder(
                    context.read<MediaProvider>().pageMax!,
                    context.read<MediaProvider>().currentPage,
                    (pageSelectedReturned) {
                      context.read<MediaProvider>().setCurrentPageMedia(pageSelectedReturned);
                      context.read<MediaProvider>().loadMedia();
                    },
                  )
                : const SizedBox(),
          )
        ],
      ),
    );
  }
}
