import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/models/auth_user.dart';

class AuthNotifier extends StateNotifier<AuthUser> {
  AuthNotifier() : super(
    const AuthUser(
      phone: '',
      uid: '',
      status: LoginStatus.loggedout
    )
  );
  void setLoggedInUser({required String uid, required String phone}) {
    state.copyWith(
      uid: uid, phone: phone,
      status: LoginStatus.loggedin
    );
  }
  void logOut() {
    state.copyWith(
      uid: '', phone: '',
      status: LoginStatus.loggedout
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthUser>(
  (ref) => AuthNotifier()
);