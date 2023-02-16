import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenipay/views/pages/transactions/transaction_details.dart';

class TransactionPage extends ConsumerStatefulWidget {
  
  const TransactionPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  leading: snapshot.data?['amount'],
                  title: snapshot.data?['id'],
                  subtitle: snapshot.data?['recipentName'],
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (contxet) =>
                            TransactonDetailsScreen(
                              transactionId: snapshot.data?[index]['id'],
                              transactionType: 'TransactionType.outgoing',
                          )
                        )
                      );
                    },
                    child: const Text('Details')
                  ),
                )
              );
            } else {
              return const Text('Some Error Occured');
            }
          })
        ],
      ),
    );
  }
}