import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mamanike/screens/auth/phoneverification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class RegisterScreen extends StatefulWidget {


const RegisterScreen({ super.key });


@override
  _PasswordWidgetState createState() => _PasswordWidgetState();
}



class _PasswordWidgetState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _confirmObscureText = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _namapenggunaFilled = false;
  bool _emailFilled = false;
  bool _passwordFilled = false;
  bool _confirmPasswordFilled = false;


  

bool _isFormFilled() {
  return _namapenggunaFilled &&
         _emailFilled &&
         _passwordFilled &&
         _confirmPasswordFilled &&
         _passwordController.text == _confirmPasswordController.text;
}


Future<void> _register() async {
  setState(() {
    _isLoading = true;
  });

  try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set(
          {
            'full_name': _nameController.text,
            'email' : _emailController.text,
            'fcmToken' : ''
          }
        );
       if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneverificationScreen(user: userCredential.user!),
          ),
        );
      }

  } on FirebaseAuthException catch (e) {
    CherryToast.error(
      description: Text(e.toString(), ),
      animationType: AnimationType.fromTop,
    ).show(context);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Stack(
                      children: [
                        Positioned(
                          child: SvgPicture.asset(
                            'assets/svg/registerdecor.svg',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _header(context),
                            const SizedBox(height: 34),
                            _namapengguna(),
                            const SizedBox(height: 12),
                            _email(),
                            const SizedBox(height: 12),
                            _password(),
                            const SizedBox(height: 12),
                            _konfirmasipassword(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _button(context),
            ),
          ],
        ),
      ),
    );
  }


  Container _button(BuildContext context) {
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isFormFilled() ?  _register: null,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: _isFormFilled() ? const Color(0xFFFFB113) : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child:_isLoading ? 
      const SizedBox( 
        height: 24, width:24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white), strokeWidth: 2,
           )
           )
      : Text(
        'Daftar',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
  }



    Column _konfirmasipassword() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child:  Text(
                  'Konfirmasi Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9E9E9E)
                  ),
                  ),
                  ),
                  
                const SizedBox(height: 12,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _confirmPasswordFilled = value.isNotEmpty ;
                    });
                  },
                  controller: _confirmPasswordController,
                  obscureText: _confirmObscureText,
                  validator: (value) {
                    if ( value != _passwordController.text) {
                      return 'Konfirmasi Password harus sama dengan password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Konfirmasi Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                      _confirmObscureText ? IconlyBold.show : IconlyBold.hide,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmObscureText = !_confirmObscureText;
                        });
                      },
                  
                    ),                      
                    contentPadding: const EdgeInsets.symmetric(vertical: 18), 
                    hintStyle: GoogleFonts.poppins( 
                      fontSize: 14,
                      height: 140 / 100,
                      letterSpacing: 0.2,
                      color: const Color(0xFF9E9E9E),
                    )
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14
                  ),
                ),
              ),

               const SizedBox(height: 6,),
                if (_confirmPasswordFilled && _confirmPasswordController.text != _passwordController.text) ...{
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      
                      const Icon(IconlyBold.info_circle, color: Colors.red, size: 20),

                      Text(
                        
                        "Konfirmasi Password harus sama!",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 12
                        )
                      ),
                    ],
                  ),
                  )
                },
            ],);
  }



    Column _password() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child:  Text(
                  'Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9E9E9E),
                    
                  ),
                
                  ),
                  ),
                  
               

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  color: const  Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                  borderRadius: BorderRadius.circular(16)
                ),
                  child: TextFormField(
                    onChanged: (value) {
                    setState(() {
                      _passwordFilled = value.isNotEmpty;
                    });
                  },
                    controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                      _obscureText ? IconlyBold.show : IconlyBold.hide,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                  
                    ),
                      
                    contentPadding: const EdgeInsets.symmetric(vertical: 18), 
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 140 / 100,
                      letterSpacing: 0.2,
                      color: const Color(0xFF9E9E9E),
                    )
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14
                  ),
                ),
                
              ),
            ],);
  }



    Column _email() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child:  Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9E9E9E)
                  ),
                  ),
                  ),
                  
              const  SizedBox(height: 12,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _emailFilled = value.isNotEmpty;
                    });
                  },
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    contentPadding: const EdgeInsets.symmetric(vertical: 18), 
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 140 / 100,
                      letterSpacing: 0.2,
                      color: const Color(0xFF9E9E9E),
                    )
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14
                  ),
                ),
              ),
            ],);
  }



  Column _namapengguna() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                child:  Text(
                  'Nama Pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9E9E9E)
                  ),
                  ),
                  ),
                  
              const  SizedBox(height: 12,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  color: const  Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _namapenggunaFilled = value.isNotEmpty;
                    });
                  },
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Nama Lengkap",
                    contentPadding: const EdgeInsets.symmetric(vertical: 18), 
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 140 / 100,
                      letterSpacing: 0.2,
                      color: const Color(0xFF9E9E9E),
                    )
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14
                  ),
                ),
              ),
            ],);
  }

  Column _header(BuildContext context) {
    return Column(
            children: [
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                  
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: IconButton(
                      icon: SvgPicture.asset('assets/svg/back.svg', color: Colors.white), 
                      onPressed: () {
                        Navigator.of(context).pop();
                      },)
                      
                    ),
                    Expanded(
                      child: Text(
          'Registrasi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
                      ),
                    ),
                  const  SizedBox(width: 60), // Add space between the text and the right edge of the screen
                  ],
            )
          ],);
  }
}