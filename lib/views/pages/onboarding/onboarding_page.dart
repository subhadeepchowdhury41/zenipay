import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/services/firestore_services.dart';
import 'package:zenipay/views/pages/home/home_page.dart';
import 'package:zenipay/views/pages/login/login_page.dart';
import 'package:zenipay/views/pages/register/user_details_page.dart';

class OnBoardingPage extends ConsumerStatefulWidget {
  const OnBoardingPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends ConsumerState<OnBoardingPage> {
  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => const LoginPage()
        )
      );
    } else {
      await FirestoreServices.userExists(user.uid).then((exists) {
        if (exists) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(
              builder: (context) => const HomePage()
            )
          );
        } else {
          Navigator.pushReplacement(
            context, MaterialPageRoute(
              builder: (context) => const UserDeatilsPage(
                isEdit: true,
              )
            )
          );
        }
        
      });
    }
    });
    
  }
  @override
  void initState() {
    _initialize();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ZeniPay',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 43
          )
        ),
      )
    );
  }
}