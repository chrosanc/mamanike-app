// search_form.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        style: GoogleFonts.poppins(
          color: const Color.fromARGB(255, 81, 81, 81),
          fontSize: 14,
        ),
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
          prefixIcon: const Icon(
            IconlyLight.search,
            size: 20,
            color: Color(0xFF9E9E9E),
          ),
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFFBDBDBD),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              IconlyLight.filter,
              color: Color(0xFFFFB113),
              size: 20,
            ),
            onPressed: () {},
          ),
          hintText: "Search",
        ),
      ),
    );
  }
  
  
}
