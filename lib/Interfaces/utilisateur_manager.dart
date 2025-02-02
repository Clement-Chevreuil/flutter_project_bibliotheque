import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/interfaces/media/interface_helper.dart';
import 'package:flutter_project_n1/models/utilisateur.dart';

class UtilisateurManager extends StatefulWidget {
  UtilisateurManager();

  @override
  _UtilisateurManagerState createState() => _UtilisateurManagerState();
}

class _UtilisateurManagerState extends State<UtilisateurManager> {
  InterfaceHelper? interfaceHelper;
  late DatabaseInit _databaseInit;
  _UtilisateurManagerState();
  bool isInitComplete = false;
  Utilisateur? utilisateur;

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    getUtilisateur().then((value) => setState(() {
          isInitComplete = true;
        }));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitComplete) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    DatabaseInit.update(utilisateur!);
                  },
                  child: const Text("Valider")),
            ],
          ),
        ),
      ),
    );
  }

  Future<Utilisateur?> getUtilisateur() async {
    utilisateur = await DatabaseInit.utilisateur;
    return utilisateur;
  }
}
