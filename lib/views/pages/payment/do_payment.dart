import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:zenipay/models/transaction.dart';
import 'package:zenipay/services/firestore_services.dart';
import 'package:zenipay/services/notification_services.dart';
import 'package:zenipay/views/pages/home/home_page.dart';
import 'package:zenipay/views/pages/transactions/transaction_details.dart';
import '../../../utils/app_contants.dart';

class DoPaymentsScreen extends StatefulWidget {
  final String reveiverId;
  final int amount;
  final String? description;
  final TransactionType transactionType;
  const DoPaymentsScreen({
    super.key,
    required this.amount,
    required this.reveiverId,
    this.description,
    this.transactionType = TransactionType.outgoing,
  });
  @override
  State<DoPaymentsScreen> createState() => _DoPaymentsScreenState();
}

class _DoPaymentsScreenState extends State<DoPaymentsScreen> {
  Map<String, dynamic>? receiver;
  bool isFetchingUser = true;
  late Transaction _transaction;
  Future<void> processPayment() async {
    await FirestoreServices.transactionWithUser(
      FirebaseAuth.instance.currentUser!.uid,
      widget.reveiverId,
      _transaction,
    ).then((value) async {
      await FirestoreServices.markSuccessfulTransaction(
              FirebaseAuth.instance.currentUser!.uid,
              widget.reveiverId,
              _transaction)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Success')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => TransactonDetailsScreen(
                transactionId: _transaction.hashCode.toString(),
                transactionType: TransactionType.outgoing.toString())));
        NotificationServices.showInstantNotification(
            id: _transaction.hashCode, title: 'Success', body: 'Hurray! Your payment Successfull');
      });
    }).catchError((err) async {
      await FirestoreServices.markFailTransaction(
              FirebaseAuth.instance.currentUser!.uid,
              widget.reveiverId,
              _transaction)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed')));
        NotificationServices.showInstantNotification(
            id: 0, title: 'Failed', body: 'Oops! Your payment failed');
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => TransactonDetailsScreen(
                transactionId: _transaction.hashCode.toString(),
                transactionType: TransactionType.outgoing.toString())));
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong!')));
        NotificationServices.showInstantNotification(
            id: 0, title: 'Error', body: 'Sorry! something went wrong');
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => TransactonDetailsScreen(
                transactionId: _transaction.hashCode.toString(),
                transactionType: TransactionType.outgoing.toString())));
      });
    });
  }

  Future<void> _initialize() async {
    receiver =
        await FirestoreServices.getUserDetails(widget.reveiverId).then((value) {
      setState(() {
        isFetchingUser = false;
      });
      return value;
    });
    StripePayment.setOptions(
      StripeOptions(
        publishableKey:
            'pk_test_51MbG8bSCJKmUlto3XSFimf71Tr0OhOTwRo4jfqGAgnPwDl1pIRCvFDn5RoReuLku5ipzz7dqvmAciaoJFWnthLlY00NhlSNdum',
        merchantId: 'acct_1MbG8bSCJKmUlto3',
        androidPayMode: 'test',
      ),
    );
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
        title: const Text('Cofirm Payment', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: isFetchingUser
          ? const CircularProgressIndicator()
          : Padding(
            padding: const EdgeInsets.only(top: 48.0, bottom: 20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: text100,
                    ),
                    child: Column(
                      children: [
                        Text(
                          receiver?['user']['name'] ?? '',
                          style: TextStyle(
                            color: text500,
                            fontSize: heading1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          receiver?['user']['email'] ?? '',
                          style: TextStyle(
                            color: text400,
                            fontSize: heading2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          receiver?['user']['phone'] ?? '',
                          style: TextStyle(
                            color: text400,
                            fontSize: heading2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirestoreServices.checkIfEnoughMoney(
                                widget.amount.toDouble(),
                                FirebaseAuth.instance.currentUser!.uid)
                            .then((value) async {
                          if (!value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Not enough money!'),
                              ),
                            );
                            return;
                          } else {
                            _transaction = Transaction(
                              details: widget.description,
                              amount: widget.amount.toDouble(),
                              state: TransactionState.pending,
                              sender: FirebaseAuth.instance.currentUser!.uid,
                              receiver: widget.reveiverId,
                              type: TransactionType.outgoing,
                              recipentName: receiver?['user']['name'] ?? '',
                              dateTime: DateTime.now().toString()
                            );
                            await StripePayment.createSourceWithParams(
                              SourceParams(
                                  returnURL: 'example://stripe-redirect',
                                  type: 'ideal',
                                  currency: 'inr',
                                  amount: widget.amount),
                            ).then(
                              (source) async {
                                print('Stripe Success');
                                await processPayment();
                              },
                            ).catchError(
                              (err) async {
                                print('Stripe Failure');
                                await FirestoreServices.markFailTransaction(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  widget.reveiverId, _transaction).then((value) {
                                    NotificationServices.showInstantNotification(
                                    id: _transaction.hashCode,
                                    title: 'Failed',
                                    body: 'Oops! Your payment failed');
                                   Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (_) => const HomePage()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment failed'),
                                      ),
                                    );
                                  });
                              },
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50.0),
                        maximumSize: const Size(double.infinity, 60.0),
                        backgroundColor: accentBG,
                      ),
                      child: Text(
                        'Pay ${widget.amount}₹',
                        style: TextStyle(
                          color: text500,
                          fontSize: heading2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
          ),
    );
  }
}
