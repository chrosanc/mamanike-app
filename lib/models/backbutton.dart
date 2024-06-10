import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBackbutton extends StatefulWidget {
  const CustomBackbutton({ Key? key }) : super(key: key);

  @override
  _BackbuttonState createState() => _BackbuttonState();
}

class _BackbuttonState extends State<CustomBackbutton> {
  @override
  Widget build(BuildContext context) {
   return Positioned(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB113),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/back.svg',
              color: Colors.white,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}