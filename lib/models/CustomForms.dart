import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomForms extends StatelessWidget {

  final String title;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;

const CustomForms({ Key? key, required this.title, required this.controller , required this.onChanged, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF383434)
                  ),
                  ),
                  
              const  SizedBox(height: 12,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  color: const  Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: TextFormField(
                  onChanged: onChanged,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10), 
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 140 / 100,
                      letterSpacing: 0.2,
                      color: const Color(0xFF9E9E9E),
                    )
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12
                  ),
                ),
              ),
            ],);
  }
  }