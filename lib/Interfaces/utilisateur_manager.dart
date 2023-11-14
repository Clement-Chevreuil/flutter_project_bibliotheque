import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Database/database_init.dart';
import '../Database/database_utilisateur.dart';
import '../Model/utilisateur.dart';
import '../Logic/function_helper.dart';
import '../Logic/interface_helper.dart';

class UtilisateurManager extends StatefulWidget {
  UtilisateurManager();

  @override
  _UtilisateurManagerState createState() => _UtilisateurManagerState();
}

class _UtilisateurManagerState extends State<UtilisateurManager> {
  InterfaceHelper? interfaceHelper;
  final bdUtilisateur = DatabaseUtilisateur();
  late DatabaseInit _databaseInit;
  FunctionHelper databaseHelper = new FunctionHelper();
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
      return CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                // This bool value toggles the switch.
                value: (utilisateur!.saison == 1) ? true : false,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    if (value == true) {
                      utilisateur!.saison = 1;
                    } else {
                      utilisateur!.saison = 0;
                    }
                  });
                },
              ),
              Switch(
                // This bool value toggles the switch.
                value: (utilisateur!.episode == 1) ? true : false,
                activeColor: Colors.blue,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    if (value == true) {
                      utilisateur!.episode = 1;
                    } else {
                      utilisateur!.episode = 0;
                    }
                  });
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    DatabaseInit.update(utilisateur!);
                  },
                  child: Text("Valider")),
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
