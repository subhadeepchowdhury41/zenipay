import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/providers/auth_provider.dart';
import 'package:zenipay/views/pages/login/bloc/phone_auth_bloc.dart';
import 'package:zenipay/views/pages/onboarding/onboarding_page.dart';
import 'package:zenipay/views/widgets/otp_widget.dart';
import 'package:zenipay/views/widgets/phone_number_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneNumberController;
  late TextEditingController _codeController;
  @override
  void initState() {
    _phoneNumberController = TextEditingController();
    _codeController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _phoneNumberController.dispose();
    _codeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return Scaffold(
      body: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
        listener: (context, state) {
          if (state is PhoneAuthVerified) {
            final String uid = FirebaseAuth.instance.currentUser!.uid;
            print('$uid, >>>>>>>>>> ${_phoneNumberController.text}');
            print(user.uid);
            ref
                .read(authProvider.notifier)
                .setLoggedInUser(uid: uid, phone: _phoneNumberController.text);
            print(user.uid);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const OnBoardingPage(),
              ),
            );
          }

          //Show error message if any error occurs while verifying phone number and otp code
          if (state is PhoneAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            alignment: Alignment.center,
            child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state is! PhoneAuthCodeSentSuccess)
                        PhoneNumberWidget(
                          phoneNumberController: _phoneNumberController,
                        )
                      else
                        OtpWidget(
                          codeController: _codeController,
                          verificationId: state.verificationId,
                        ),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}
