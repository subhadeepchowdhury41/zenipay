import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/services/auth_repository.dart';
import 'package:zenipay/services/firestore_services.dart';
import 'package:zenipay/views/pages/register/user_details_page.dart';
import '../../../utils/app_contants.dart';
import '../../../utils/ui_functions.dart';
import '../login/login_page.dart';

enum UserDetailsMode { view, change }

class UserDeatilsViewPage extends ConsumerStatefulWidget {
  final bool isEdit;
  // final UserDetailsMode mode;
  const UserDeatilsViewPage({super.key, this.isEdit = false});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserDeatilsPageState();
}

class _UserDeatilsPageState extends ConsumerState<UserDeatilsViewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  bool _isMerchant = false;

  Future<void> _initialize() async {
    await FirestoreServices.getUserDetails(
            FirebaseAuth.instance.currentUser!.uid)
        .then((data) {
      _nameCtrl.text = data?['user']['name'] ?? '';
      _emailCtrl.text = data?['user']['email'] ?? '';
      _addressCtrl.text = data?['user']['address'] ?? '';

      if (data != null &&
          data.containsKey('accountType') &&
          data['accountType'] == 'merchant') {
        _isMerchant = true;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
          style: TextStyle(
            color: text500,
            fontSize: title,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthRepository>().logOut().then(
                (value) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (ctx) {
                      return const LoginPage();
                    },
                  ), (route) => true);
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const UserDeatilsPage(isEdit: true)));
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 70),
               Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              _isMerchant ? const Color.fromARGB(74, 177, 124, 55) : const Color.fromARGB(37, 84, 173, 87),
                          child: Icon(
                            
                            _isMerchant ? Icons.storefront : Icons.person,
                            size: 60,
                            color: _isMerchant ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 70,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     

                      /// Name number
                      Text(
                        'Name',
                        style: TextStyle(
                          color: text500,
                          fontSize: body2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: text150,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: _nameCtrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Name';
                            } else if (value.length > 100) {
                              return 'Name should be less than 100 characters';
                            }
                            return null;
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: text400,
                          ),
                          decoration: getInputDecoration('Name'),
                          enabled: false,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// email
                      Text(
                        'Email',
                        style: TextStyle(
                          color: text500,
                          fontSize: body2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: text150,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'Please Enter a valid email';
                              }
                            }

                            return null;
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: text400,
                          ),
                          enabled: false,
                          decoration: getInputDecoration('Email'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// pincode
                      Text(
                        'Address',
                        style: TextStyle(
                          color: text500,
                          fontSize: body2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: text150,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _addressCtrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a address';
                            }

                            return null;
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: text500,
                          ),
                          decoration: getInputDecoration(
                              '102/578 ,jankipuram, sector D, Lucknow, 226017'),
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
