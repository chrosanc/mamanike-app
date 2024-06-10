import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({ Key? key }) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 67, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
        
              const SizedBox(height: 24,),
        
              Text("Pengaturan Akun",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                ),
              ),        
              const SizedBox(height: 16,),
              
              _pengaturanAkun(),
        
              const SizedBox(height: 24,),       
              Text("Lainnya",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                ),
              ),        
              const SizedBox(height: 16,),        
              _Lainnya(),

              const SizedBox(height: 16,),        
              Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
          decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
      children: [        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Keluar",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),                
                ],
              ),
            ),
            SvgPicture.asset('assets/svg/arrow_right.svg'),
        
            const SizedBox(height: 24,),                       
          ],
        ),        
      ],
          ),
        ),
      )
            ],
          ),
        ),
      ),
    );
  }

  Card _Lainnya() {
    return Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
          decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Setelan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Pengaturan lainnya",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset('assets/svg/arrow_right.svg'),
        
            const SizedBox(height: 24,),
        
            
          ],
        ),
        
        const SizedBox(height: 24,),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bantuan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Pusat bantuan untuk kendala",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset('assets/svg/arrow_right.svg'),
        
            const SizedBox(height: 24,),                       
          ],
        ),        
      ],
          ),
        ),
      );
  }

  Card _pengaturanAkun() {
    return Card(
elevation: 1,
child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(4),
  ),
  child: Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Akun Saya",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Ubah informasi profil pribadi",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/svg/arrow_right.svg'),
      
          const SizedBox(height: 24,),
      
          
        ],
      ),
      
      const SizedBox(height: 24,),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alamat",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Buat atau ubah alamat",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/svg/arrow_right.svg'),
      
          const SizedBox(height: 24,),
      
          
        ],
      ),


      const SizedBox(height: 24,),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notifikasi",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Atur notifikasi untuk pemberitahuan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/svg/arrow_right.svg'),
      
          const SizedBox(height: 24,),
      
          
        ],
      ),

      const SizedBox(height: 24,),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keamanan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Atur Password Akun",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/svg/arrow_right.svg'),
      
          const SizedBox(height: 24,),
      
          
        ],
      ),
    ],
  ),
),
);
  }

  Card _header() {
    return Card(
            elevation: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4)
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/images/avatar.png',
                    width: 54,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        "Nama",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        ),
                      Text(
                        "email@gmail.com",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 14
                        ),
                        )
                    ],),
                  )
                ],
              ),
            ),
          );
  }
}