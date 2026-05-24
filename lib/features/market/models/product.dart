import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double pexPrice;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.pexPrice,
    required this.icon,
  });
}
