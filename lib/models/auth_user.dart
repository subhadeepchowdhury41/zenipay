import 'package:flutter/material.dart';

enum LoginStatus {
  loggedin,
  loggedout
}

@immutable
class AuthUser {
  final String uid;
  final String phone;
  final LoginStatus status;
  const AuthUser({
    required this.uid,
    required this.phone,
    required this.status
  });
  AuthUser copyWith({
    String? uid,
    String? phone,
    LoginStatus? status
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      status: status ?? this.status
    );
  }
}