import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zenipay/services/firestore_services.dart';
import 'package:zenipay/views/pages/payment/do_payment.dart';
import '../../../utils/app_contants.dart';
import '../../../utils/ui_functions.dart';

class SendPayment extends StatefulWidget {
  const SendPayment({super.key});

  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  String receiverId = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState<Map<String, dynamic>>> _autokey =
      GlobalKey();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _receiverCtrl = TextEditingController();
  late AutoCompleteTextField searchTextField;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// login text
                Align(
                  child: Text(
                    'Payment',
                    style: TextStyle(
                      color: text500,
                      fontSize: 43,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height:80),

                /// lets started
                Text(
                  'Enter your payment details',
                  style: TextStyle(
                    color: text500,
                    fontSize: heading1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 25),

                /// Name number
                Text(
                  'Amount',
                  style: TextStyle(
                    color: text500,
                    fontSize: body2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: text150,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _amountCtrl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your amount';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: getInputDecoration('Enter the amount'),
                  ),
                ),

                const SizedBox(height: 10),

                /// email
                Text(
                  'Name',
                  style: TextStyle(
                    color: text500,
                    fontSize: body2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: FirestoreServices.getUsersByName(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: error,
                            fontSize: body1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return searchTextField =
                          AutoCompleteTextField<Map<String, dynamic>>(
                        itemBuilder: (context, item) {
                          return Container(
                            margin: const EdgeInsets.all(13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  item['name'],
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(15.0),
                                ),
                                Text(
                                  item['phone'],
                                )
                              ],
                            ),
                          );
                        },
                        itemFilter: (item, query) {
                          return item['name']
                              .toLowerCase()
                              .startsWith(query.toLowerCase());
                        },
                        itemSorter: (a, b) {
                          return a['name'].compareTo(b['name']);
                        },
                        controller: _receiverCtrl,
                        itemSubmitted: (item) {
                          debugPrint(_receiverCtrl.text);
                          setState(() {
                            searchTextField.textField?.controller!.text =
                                item['id'];
                            _receiverCtrl.text = item['name'];
                            receiverId = item['id'];
                          });
                          debugPrint(_receiverCtrl.text);
                        },
                        textChanged: (String? data) {
                          if (data == null || data.isEmpty) {}
                        },
                        key: _autokey,
                        suggestions: [
                          ...snapshot.data!.where((element) => (element['id'] !=
                              FirebaseAuth.instance.currentUser!.uid))
                        ],
                        style: const TextStyle(color: Colors.white, fontSize: 16.0),
                        clearOnSubmit: false,
                        decoration: getInputDecoration('Enter the name of the User'),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),

                /// PAYMENT BUTTON
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      /// Navigate to the do payments screen
                      if (_formKey.currentState!.validate() &&
                          receiverId.isNotEmpty) {
                        print('-----------> $receiverId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return DoPaymentsScreen(
                                amount: int.parse(_amountCtrl.text),
                                reveiverId: receiverId,
                                description: 'Payment to',
                              );
                            },
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 61.0),
                      maximumSize: const Size(double.infinity, 61.0),
                      backgroundColor: accentBG,
                    ),
                    child: Text(
                      'Proceed',
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
        ),
      ),
    );
  }
}
