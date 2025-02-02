import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/interfaces/media/media_manager.dart';
import 'package:flutter_project_n1/models/media.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MediaWidget extends StatelessWidget {
  final Media media;
  final DateFormat formatter = DateFormat('yyyy MM dd');

  MediaWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Card(
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.memory(
                  media.image ?? Uint8List(0),
                  height: 120,
                  width: 90,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GFTypography(
                        text: media.nom ?? '',
                        type: GFTypographyType.typo5,
                      ),
                      Text('Note: ${media.note ?? ''}'),
                      Text('Statut: ${media.statut ?? ''}'),
                      Text('Genres: ${media.genres?.join(', ') ?? ''}'),
                      Text('Crée le: ${media.created_at != null ? formatter.format(media.created_at!) : ''}'),
                      Text('Mis à jour le: ${media.updated_at != null ? formatter.format(media.updated_at!) : ''}'),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaManager(
                            mediaParam: media,
                            tableName: context.read<MediaProvider>().tableName,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await DatabaseMedia(context.read<MediaProvider>().tableName).deleteMedia(media);

                      if (!context.mounted) {
                        return;
                      }
                      context.read<MediaProvider>().loadMedia();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Livre supprimé')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
