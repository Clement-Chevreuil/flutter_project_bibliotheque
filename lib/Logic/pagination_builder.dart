import 'package:flutter/material.dart';

class PaginationBuilder{
  // Fonction pour créer les boutons en fonction du nombre de pages
  Widget paginationBuilder(int pageCount, int page, Function(int) setPageFunction) {
    // Assurez-vous qu'il y a au moins deux boutons à afficher
    if (pageCount < 2) {
      return SizedBox();
    }

    // Définissez le nombre total de boutons à afficher autour de la page actuelle (toujours 7)
    int totalButtons = 7;
    int pageMin = 2;
    int pageMax = 2;
    // Calculez les bornes inférieures et supérieures pour afficher les boutons
    int lowerBound = page - pageMin;
    int upperBound = page + pageMax;

    // Ajustez les bornes pour s'assurer qu'il y a toujours 7 boutons
    if (lowerBound < 1) {
      lowerBound = 1;
      upperBound = lowerBound + totalButtons - 2;
    }
    if (upperBound > pageCount) {
      upperBound = pageCount;
      lowerBound = upperBound - totalButtons + 2;
    }
    if (page == 3) {
      upperBound += 1;
    }

    if (page == pageCount - 2) {
      lowerBound -= 1;
    }

    // Générez les boutons en fonction des bornes inférieures et supérieures
    List<Widget> buttons = [];

    for (int i = lowerBound; i <= upperBound; i++) {
      buttons.add(buildButton(i, page, setPageFunction));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (lowerBound > 1) buildButton(1, page, setPageFunction), // Bouton de la page minimum
          ...buttons, // Boutons centraux
          if (upperBound < pageCount)
            buildButton(pageCount, page, setPageFunction), // Bouton de la page maximum
        ],
      ),
    );
  }

  Widget buildButton(int pageNumber, int page, Function(int) setPageFunction) {
    final isSelected =
        pageNumber == page; // Vérifiez si le bouton est sélectionné

    return SizedBox(
      width: 36.0, // Largeur fixe
      height: 36.0, // Hauteur fixe
      child: TextButton(
        onPressed: () {
          // Mettez à jour la page sélectionnée
          setPageFunction(pageNumber);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Aucun remplissage autour du texte
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0), // Bordures carrées
          ),
          backgroundColor:
          isSelected ? Colors.blue : Colors.transparent, // Couleur de fond
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // Couleur du texte
          ),
        ),
      ),
    );
  }
}