import 'package:flutter/material.dart';

class BuildCheckButtons{
  Widget buildCheckButtons(
      List<String> list,
      String? selected,
      void Function(String?) updateSelectedList,
      void Function() reloadDataFunction,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(list.length, (index) {
          final select = list[index];
          final isSelected = selected == select;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                // Mettre à jour les genres sélectionnés
                if (isSelected) {
                  selected = null;
                } else {
                  selected = select;
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
              child: Text(select),
            ),
          );
        }),
      ),
    );
  }
}