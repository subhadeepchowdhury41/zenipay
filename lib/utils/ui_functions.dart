import 'package:flutter/material.dart';

import 'app_contants.dart';


InputDecoration getInputDecoration(String hintText) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10.0),
    ),
    hintText: hintText,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Color.fromARGB(255, 153, 97, 205)),
    ),
    errorStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    filled: true,
    fillColor: text100,
  );
}
