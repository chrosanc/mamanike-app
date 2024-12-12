import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      useLegacyColorScheme: false,
      selectedLabelStyle: GoogleFonts.poppins(
        color: const Color(0xFFFFB113),
        fontSize: 14,
        fontWeight: FontWeight.w600
      ),
      selectedItemColor: const Color(0xFFFFB113),
      unselectedLabelStyle: GoogleFonts.poppins(
        color: const Color.fromARGB(255, 128, 128, 128),
        fontSize: 14,
        fontWeight: FontWeight.w600
      ),
      unselectedItemColor: const Color(0xFFD8D8D8),
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(IconlyLight.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/category.svg' , 
                      color: currentIndex == 1 ? const Color(0xFFFFB113) : const Color(0xFFD8D8D8),
),
          label: 'Kategori',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/bag.svg',
                                color: currentIndex == 2 ? const Color(0xFFFFB113) : const Color(0xFFD8D8D8),
),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/person.svg' , 
                                color: currentIndex == 3 ? const Color(0xFFFFB113) : const Color(0xFFD8D8D8),
),
          label: 'Akun',
        ),
      ],
    );
  }
}
