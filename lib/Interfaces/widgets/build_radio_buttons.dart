import 'package:flutter/material.dart';

Widget buildRadioButtons(
  List<String> list,
  String? selected,
  bool nullable,
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
          child: ChoiceChip(
            label: Text(select),
            selected: isSelected,
            onSelected: (bool selected) {
              if (isSelected && nullable == true) {
                selected = false;
                updateSelectedList(null);
              } else {
                updateSelectedList(select);
              }
              reloadDataFunction();
            },
          ),
        );
      }),
    ),
  );
}
