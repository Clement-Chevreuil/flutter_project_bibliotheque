import 'add_update_media.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Database/database_helper.dart';
import '../Database/database_media.dart';
import '../Model/media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatefulWidget {
  final String? mediaParam1;

  HomeScreen({this.mediaParam1});

  @override
  _HomeScreenState createState() => _HomeScreenState(mediaParam1: mediaParam1);
}

class _HomeScreenState extends State<HomeScreen> {
  final String? mediaParam1;
  final TextEditingController _controller = TextEditingController();
  final List<String> sidebarItems = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];
  String tableName = "Series";
  List<Media> books = [];
  final bdMedia = DatabaseMedia("Series");
  final GlobalKey<AnimatedListState> _listKey = GlobalKey(); // Clé pour la ListView.builder
  int? pageMax = 1;

  _HomeScreenState({this.mediaParam1});

  void initState() {
    super.initState();
    loadMedia();
    
  }

  void loadMedia() async {
    bdMedia.changeTable(tableName);
    List<Media> updatedMediaList = await bdMedia.getMedias();
    setState(() {
      books.clear();
      books.addAll(updatedMediaList); // Ajoutez les médias chargés depuis la base de données
      _listKey.currentState?.setState(() {}); // Mettre à jour la ListView.builder
    });
  }

  Future replaceDatabase() async {
    try {
      // Sélectionner un fichier depuis l'appareil
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        // Récupérer le fichier sélectionné
        final file = File(result.files.single.path!);

        String sourceDBPath = p.join(await getDatabasesPath(), "maBDD2.db");
        File sourceFile = File(sourceDBPath);

        // Supprimer l'ancien fichier de base de données s'il existe
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }

        bdMedia.closeDatabase();
        final appDirectory = await getDatabasesPath();
        final databasePath = '${appDirectory}/maBDD3.db'; // Changement de nom ici
        await file.copy(databasePath);
        bdMedia.initDatabase("maBDD3.db");
        loadMedia();

        return sourceFile.path;
      } else {
        // L'utilisateur a annulé la sélection du fichier
        return null;
      }
    } catch (e) {
      print(e);
      // Gérer l'erreur de remplacement du fichier de base de données
      return null;
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Livres'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Sidebar Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            for (String item in sidebarItems)
              ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    tableName = item;
                    loadMedia();
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          FutureBuilder<int?>(
            future: bdMedia.countPageMedia(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Display a loading indicator while waiting for the count.
              } else if (snapshot.hasError || !snapshot.hasData) {
                // Handle errors or cases where count is not available
                return Text('Error or no data available.');
              } else {
                int pageCount = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(pageCount, (i) {
                      final pageNumber = i + 1;
                      return ElevatedButton(
                        onPressed: () {
                          // Handle button tap for page number 'pageNumber'.
                          // You can use 'pageNumber' to load data for the selected page.
                          print('Button for page $pageNumber pressed.');
                        },
                        child: Text('Page $pageNumber'),
                      );
                    }),
                  ),
                );
              }
            },
          ),

          Expanded(
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMedias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Aucun livre enregistré.'),
                  );
                } else {
                  books = snapshot.data!;
                  return ListView.builder(
                    key: _listKey, // Utilisation de la clé ici
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      Media book = books[index];
                      return ListTile(
                        title: Text(book.nom ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Note: ${book.note ?? ''}'),
                            Text('Statut: ${book.statut ?? ''}'),
                            Text('Genres: ${book.genres?.join(', ') ?? ''}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddUpdateBookScreen(
                                        mediaParam: book, // Vous pouvez passer une instance Media si nécessaire
                                        tableName: tableName,
                                      ),
                                    ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await DatabaseMedia(tableName).deleteMedia(book);
                                loadMedia();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Livre supprimé')),
                                );
                              },
                            ),
                          ],
                        ),
                        leading: Image.memory(book.image ?? Uint8List(0)),
                      );
                    },
                  );
                }
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUpdateBookScreen(
                          mediaParam: null,
                          tableName: tableName,
                        ),
                      ),
                    );
                  },
                  child: Text('Creer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    DatabaseHelper().exportDatabase(context);
                  },
                  child: Text('Exporter la base de données'),
                ),
                ElevatedButton(
                  onPressed: () {
                    replaceDatabase();
                  },
                  child: Text('Remplacer la base de données'),
                ),
                // Add more buttons here if needed
              ],
            ),
          )
        ],
      ),
    );
  }
}
