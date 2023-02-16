import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/services/firestore_services.dart';
import '../../../services/uploader.dart';
import '../../../utils/app_contants.dart';
import '../../../utils/pick_file.dart';
import '../../../utils/ui_functions.dart';

class UserDeatilsPage extends ConsumerStatefulWidget {
  final bool isEdit;
  const UserDeatilsPage({super.key, this.isEdit = false});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserDeatilsPageState();
}

class _UserDeatilsPageState extends ConsumerState<UserDeatilsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  bool _isMerchant = false;
  bool _isLoading = false;

  late Uint8List _profilePicture;
  Future<void> _initialize() async {
    await FirestoreServices.getUserDetails(
            FirebaseAuth.instance.currentUser!.uid)
        .then((data) {
      _nameCtrl.text = data?['user']['name'] ?? '';
      _emailCtrl.text = data?['user']['email'] ?? '';
      _addressCtrl.text = data?['user']['address'] ?? '';
    });
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _uploadProfilePicture() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await PickFile.pickAndGetFileAsBytes().then(
      (platformFile) async {
        setState(() {
          _isLoading = true;
        });
        if (platformFile != null) {
          /// upload bytes in firebase
          if (platformFile.path != null) {
            File fileImage = File(platformFile.path!);
            Uint8List imageData = await fileImage.readAsBytes();
            // debugPrint('we got imageData\n\n');
            await FileUploader.uploadFile(
                dbPath: 'profile_picture/$userId', fileData: imageData);

            // update in field_verifier
            await FirestoreServices.updateDatabase(data: {
              'profile_picture': 'profile_picture/$userId',
            }, collection: 'users', docId: userId);
            setState(() {
              _profilePicture = imageData;
            });
          }
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  /// setting the image for display on screen
  Future<void> _setProfilePicture() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    /// setting profile picture from local storage if present

    try {
      await FirebaseStorage.instance
          .ref()
          .child('profile_picture/$userId')
          .getData()
          .then(
        (photo) async {
          if (photo != null) {
            // debugPrint('photo is not null\n');
            _profilePicture = photo;
          }
        },
      );
    } catch (E) {
      ByteData imageBytes = await rootBundle.load('assets/gaandu.jpg');
      Uint8List bytes = imageBytes.buffer.asUint8List();
      _profilePicture = bytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit' : 'Register',
          style: TextStyle(
            color: text500,
            fontSize: title,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: FutureBuilder(
                future: _setProfilePicture(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snap.hasError) {
                    return const Text('Something went wrong');
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipOval(
                                  child: Image.memory(
                                    _profilePicture,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.lightBlue,
                                    child: IconButton(
                                      onPressed: () async {
                                        /// upload profile photo
                                        await _uploadProfilePicture()
                                            .then((value) {});
                                      },
                                      icon: const Icon(
                                        Icons.add_a_photo,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Merchant Account',
                                  style: TextStyle(
                                    color: text500,
                                    fontSize: body2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Switch(
                                  value: _isMerchant,
                                  activeColor: accent1,
                                  onChanged: (current) {
                                    setState(() {
                                      _isMerchant = !_isMerchant;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// Name number
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                color: text500,
                                fontSize: body2,
                                fontWeight: FontWeight.w500,
                              ),
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
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// email
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                color: text500,
                                fontSize: body2,
                                fontWeight: FontWeight.w500,
                              ),
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
                              decoration: getInputDecoration('Email'),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// pincode
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              'Address',
                              style: TextStyle(
                                color: text500,
                                fontSize: body2,
                                fontWeight: FontWeight.w500,
                              ),
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
                              keyboardType: TextInputType.text,
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
                                color: text400,
                              ),
                              decoration: getInputDecoration(
                                  '102/578 ,jankipuram, sector D, Lucknow, 226017'),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// Edit Or create
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await FirestoreServices.saveUserDetails(
                                      FirebaseAuth.instance.currentUser!.uid, {
                                    'name': _nameCtrl.text,
                                    'email': _emailCtrl.text,
                                    'phone': FirebaseAuth
                                        .instance.currentUser!.phoneNumber,
                                    'address': _addressCtrl.text
                                  }).then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Successfully updated details')));
                                    Navigator.of(context).pop();
                                  }).catchError((err) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Oops! something went wrong')));
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: const Size(double.infinity, 50.0),
                                maximumSize: const Size(double.infinity, 60.0),
                                backgroundColor: accent1,
                              ),
                              child: Text(
                                widget.isEdit ? 'Save Changes' : 'Save',
                                style: TextStyle(
                                  color: text500,
                                  fontSize: heading2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
