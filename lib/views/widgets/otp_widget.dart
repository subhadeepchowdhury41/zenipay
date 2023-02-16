import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenipay/views/pages/login/bloc/phone_auth_bloc.dart';

class OtpWidget extends StatelessWidget {
  OtpWidget(
      {Key? key, required this.codeController, required this.verificationId})
      : super(key: key);
  final TextEditingController codeController;
  final String verificationId;
  final GlobalKey<FormState> _otpFormKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _otpFormKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            controller: codeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter OTP',
              prefixIcon: Icon(Icons.message),
            ),
            validator: (value) {
              if (value!.length != 6) {
                return 'Please enter valid OTP';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: const Color.fromARGB(255, 87, 48, 134),
                foregroundColor: Colors.white,
                fixedSize: const Size(0, 61)
              ),
              onPressed: () {
                if (_otpFormKey.currentState!.validate()) {
                  _verifyOtp(context: context);
                }
              },
              child: const Text('Verify OTP'),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyOtp({required BuildContext context}) {
    context.read<PhoneAuthBloc>().add(VerifySentOtpEvent(
      otpCode: codeController.text, verificationId: verificationId));
  }
}