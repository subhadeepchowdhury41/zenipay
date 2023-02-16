import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenipay/views/pages/login/bloc/phone_auth_bloc.dart';

class PhoneNumberWidget extends StatefulWidget {
  const PhoneNumberWidget({Key? key, required this.phoneNumberController})
      : super(key: key);
  final TextEditingController phoneNumberController;

  @override
  State<PhoneNumberWidget> createState() => _PhoneNumberWidgetState();
}

class _PhoneNumberWidgetState extends State<PhoneNumberWidget> {
  CountryCode _countryCode = CountryCode(code: 'IN', dialCode: '+91');
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _phoneNumberFormKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.phone,
            controller: widget.phoneNumberController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color.fromARGB(255, 136, 80, 200), width: 1.3),
                borderRadius: BorderRadius.circular(13),
              ),
              hintText: 'Enter your phone number',
              prefixIcon: CountryCodePicker(
                onChanged: (CountryCode countryCode) {
                  setState(() {
                    _countryCode = countryCode;
                  });
                },
                initialSelection: 'IN',
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
              ),
            ),
            validator: (value) {
              if (value!.length != 10) {
                return 'Please enter valid phone number';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.all(3),
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
                if (_phoneNumberFormKey.currentState!.validate()) {
                  _sendOtp(
                      phoneNumber: widget.phoneNumberController.text,
                      context: context);
                }
              },
              child: const Text('Send OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }

  void _sendOtp({required String phoneNumber, required BuildContext context}) {
    final phoneNumberWithCode = "${_countryCode.dialCode}$phoneNumber";
    context.read<PhoneAuthBloc>().add(
      SendOtpToPhoneEvent(
        phoneNumber: phoneNumberWithCode,
      ),
    );
  }
}