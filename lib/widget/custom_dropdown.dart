import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;
  final TextEditingController? controller;

  CustomDropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    this.controller,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String selectedUnit; // Gunakan late untuk inisialisasi nilai setelah initState

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.value; // Inisialisasi selectedUnit dengan nilai awal dari widget.value
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Perbarui selectedUnit jika widget.value berubah
    if (widget.value != selectedUnit) {
      selectedUnit = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF383434)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUnit, // Gunakan selectedUnit sebagai nilai dropdown
                icon: SvgPicture.asset('assets/svg/arrow_down.svg'),
                iconSize: 24,
                elevation: 16,
                onChanged: (newValue) {
                  setState(() {
                    selectedUnit = newValue!; // Update selectedUnit dan trigger perubahan di UI
                  });
                  widget.onChanged(newValue); // Panggil fungsi onChanged yang dilewatkan dari luar
                },
                items: widget.items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
