import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _CategoryChip("All"),
          _CategoryChip("Pizza"),
          _CategoryChip("Burger"),
          _CategoryChip("Drinks"),
          _CategoryChip("Desserts"),
          _CategoryChip("Snacks"),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;

  const _CategoryChip(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(title),
      ),
    );
  }
}