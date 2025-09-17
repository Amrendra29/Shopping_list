import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  meat,
  dairy,
  fruit,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category  {
 const Category(this.category,this.color);

  final String category;
 final Color color;

}
