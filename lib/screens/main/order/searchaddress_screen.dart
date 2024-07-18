import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class SearchaddressScreen extends StatefulWidget {
  final Function(String) onAddressSelected;
  const SearchaddressScreen({ Key? key, required this.onAddressSelected }) : super(key: key);

  @override
  _SearchaddressScreenState createState() => _SearchaddressScreenState();
}

class _SearchaddressScreenState extends State<SearchaddressScreen> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Tentukan Pinpoint Lokasi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB113),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24,),
              child: Text(
                'Di mana lokasi tujuan kamu?',
                style: GoogleFonts.poppins(
                  fontSize: 12
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GooglePlaceAutoCompleteTextField(
                textStyle: GoogleFonts.poppins(
                  fontSize: 12,
                ),
                textEditingController: controller,
                inputDecoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey,),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  hintText: 'Tulis nama jalan/gedung/perumahan',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12
                    
                  )
                ),
                countries: ['id'],
                googleAPIKey: "AIzaSyBe_FibfHiJzUb2swAlStyRgy9_BfH-yYo",
                itemClick: (Prediction prediction) {
                  widget.onAddressSelected(prediction.description!);
                  Navigator.pop(context);
                },
                itemBuilder: (context, index, Prediction prediction) {
                  return Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 12,),
                        const Divider(thickness: 1,),
                        const SizedBox(height: 12,),                            
                        Text('${prediction.description?? ""}')
                      ],),
                    ],
                  );
                },
                ),
            ),
        
          ],
        ),
      ),
    );
  }
}