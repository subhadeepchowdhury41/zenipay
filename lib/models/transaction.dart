import 'package:flutter/cupertino.dart';

enum TransactionState { pending, successful, failed }

enum TransactionType { incoming, outgoing, subscription }

class Transaction {
  final String? details;
  final double amount;
  final String? txId;
  final TransactionState state;
  final String? sender;
  final String? recipentName;
  final String? receiver;
  final String? dateTime;
  final TransactionType type;
  Transaction(
      {required this.details,
      required this.amount,
      this.txId,
      this.dateTime,
      required this.state,
      required this.sender,
      required this.receiver,
      required this.type,
      required this.recipentName});
  factory Transaction.fromJson(Map<String, dynamic> data, String id) {
    debugPrint(data.toString());

    late TransactionState transactionState;
    if (data['status'] == 'TransactionState.pending') {
      transactionState = TransactionState.pending;
    } else if (data['status'] == 'TransactionState.successful') {
      transactionState = TransactionState.successful;
    } else {
      transactionState = TransactionState.failed;
    }
    late TransactionType transactionType;
    if (data['type'] == 'TransactionType.incoming') {
      transactionType = TransactionType.incoming;
    } else if (data['type'] == 'TransactionType.outgoing') {
      transactionType = TransactionType.outgoing;
    } else {
      transactionType = TransactionType.subscription;
    }
    return Transaction(
        recipentName: data['recipentName'],
        details: data['details'],
        amount: data['amount'],
        txId: id,
        state: transactionState,
        sender: data['sender'] ?? '',
        receiver: data['receiver'] ?? '',
        type: transactionType,
        dateTime: data['dateTime']);
  }
}
