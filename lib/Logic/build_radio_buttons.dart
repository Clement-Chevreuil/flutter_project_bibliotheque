import 'package:flutter/material.dart';

class BuildRadioButtons{

  Widget buildRadioButtons(
      List<String> list,
      Set<String> selected,
      void Function(Set<String>) updateSelectedList,
      void Function() reloadDataFunction,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(list.length, (index) {
          final genre = list[index];
          final isSelected = selected.contains(genre);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                // Mettre à jour les genres sélectionnés
                if (isSelected) {
                  selected.remove(genre);
                } else {
                  selected.add(genre);
                }
                updateSelectedList(selected);
                // Charger les médias avec les nouveaux genres sélectionnés
                reloadDataFunction();
              },
              style: ButtonStyle(
                backgroundColor: isSelected
                    ? MaterialStateProperty.all<Color>(Colors.blue)
                    : null,
              ),
              child: Text(genre),
            ),
          );
        }),
      ),
    );
  }


}