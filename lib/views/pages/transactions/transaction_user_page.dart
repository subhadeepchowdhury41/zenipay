import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/models/transaction.dart';
import 'package:zenipay/services/firestore_services.dart';
import 'package:zenipay/views/pages/payment/do_payment.dart';
import 'package:zenipay/views/widgets/transaction_status_icon.dart';

class TransactionWithUser extends ConsumerStatefulWidget {
  const TransactionWithUser({super.key, required this.recipentId});
  final String recipentId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionWithUserState();
}

class _TransactionWithUserState extends ConsumerState<TransactionWithUser> {
  Map<String, dynamic>? receiver;
  bool isFetchingUser = true;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> _initialize() async {
    receiver =
        await FirestoreServices.getUserDetails(widget.recipentId).then((value) {
      setState(() {
        isFetchingUser = false;
      });
      return value;
    });
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 45, 39, 114),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isFetchingUser
                  ? 'Loading User Details..'
                  : receiver?['user']['name'],
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Text(
              isFetchingUser
                  ? 'Loading User Details..'
                  : receiver?['user']['phone'],
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: StreamBuilder(
                stream: FirestoreServices.getTranscationsWithUser(
                    FirebaseAuth.instance.currentUser!.uid, widget.recipentId),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Transaction>?> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          // isThreeLine: true,
                          title: Text('${snapshot.data?[index].txId}'),
                          leading: TransactionStatusIcon(
                              state: snapshot.data![index].state.toString()),
                          subtitle:
                              Text('${snapshot.data?[index].recipentName}'),
                          trailing: Text(
                            '${snapshot.data?[index].type == TransactionType.outgoing ? '-' : ''}${(snapshot.data?[index].amount as double)}',
                            style: TextStyle(
                              color: snapshot.data?[index].type ==
                                      TransactionType.outgoing
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Some error Occured');
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Enter the amount you want to send'),
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value == '') {
                            return 'Enter some amount to send';
                          } else if (double.tryParse(value) == null) {
                            return 'Enter some valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: height / 16,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            backgroundColor:
                                const Color.fromARGB(255, 45, 39, 114),
                            foregroundColor: Colors.white,
                            fixedSize: Size(0, height / 16)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DoPaymentsScreen(
                                  amount: int.parse(_controller.text),
                                  reveiverId: widget.recipentId,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.send)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
