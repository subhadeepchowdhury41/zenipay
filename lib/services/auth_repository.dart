import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthServices {}

class AuthRepository extends AuthServices {
  static final FirebaseAuth _instance = FirebaseAuth.instance;
  Future<void> signInWithPhone(
      {required String phone,
      required Function(FirebaseAuthException) onError,
      required Function(String, int?) onCodeSent,
      required Function(String) onTimeOut,
      required Function(PhoneAuthCredential) onCompleted}) async {
    await _instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: onCompleted,
        verificationFailed: onError,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onTimeOut,
        timeout: const Duration(seconds: 60));
  }

  Future<UserCredential> verifyOtp(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    return await _instance.signInWithCredential(credential);
  }

  Future<void> logOut() async {
    await _instance.signOut();
  }
}

final authRepositoryProvider =
    RepositoryProvider(create: (context) => AuthRepository());
