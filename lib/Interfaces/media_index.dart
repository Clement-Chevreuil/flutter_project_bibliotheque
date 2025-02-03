import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/constants/routes.dart';
import 'package:flutter_project_n1/interfaces/widgets/advanced_search.dart';
import 'package:flutter_project_n1/interfaces/widgets/media_widget.dart';
import 'package:flutter_project_n1/interfaces/widgets/pagination_builder.dart';
import 'package:flutter_project_n1/models/media.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';
import 'package:provider/provider.dart';
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
          await Navigator.of(context).pushNamed(Routes.mediaCreate);
        },
        mini: true,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: <Widget>[
          SearchBar(
            hintText: "Recherche...",
            controller: _controllerNom,
            onChanged: (value) {
              context.read<MediaProvider>().setSearch(value);
              context.read<MediaProvider>().loadMedia();
            },
            leading: const Icon(Icons.search, color: Colors.black),
            trailing: [
              if (_controllerNom.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _controllerNom.clear();
                    context.read<MediaProvider>().setSearch('');
                    context.read<MediaProvider>().loadMedia();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.sort, color: Colors.black),
                onPressed: () {
                  context.read<MediaProvider>().toggleAdvancedSearchVisible();
                },
              ),
            ],
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
