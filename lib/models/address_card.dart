import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class AddressCard extends StatefulWidget {
  final String label;
  final String namePerson;
  final String phoneNumber;
  final String addressPerson;
  final Function() changeAddress;
  final Function() deleteAddress;
  final Color borderColor;
  final Color backgroundColor;
  const AddressCard({Key? key, required this.label, required this.namePerson, required this.phoneNumber, required this.addressPerson, required this.changeAddress, required this.deleteAddress, required this.borderColor, required this.backgroundColor}) : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor),
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: widget.deleteAddress,
                  child: Icon(IconlyLight.delete, size: 20, color: Colors.grey,))
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              widget.namePerson,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.phoneNumber,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.normal),
            ),
            Text(
              widget.addressPerson,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: Colors.grey,
                    )),
                minimumSize: const Size(double.infinity, 36),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: widget.changeAddress,
              child: Text(
                "Ubah Alamat",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
