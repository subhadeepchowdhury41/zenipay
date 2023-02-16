import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:zenipay/models/transaction.dart';

class FirestoreServices {
  static final _instance = FirebaseFirestore.instance;
  static Future<bool> userExists(String uid) async {
    final DocumentSnapshot doc =
        await _instance.collection('users').doc(uid).get();
    return doc.exists;
  }

  static Future<void> updateDatabase(
      {required Map<String, dynamic> data,
      required String collection,
      required String docId}) async {
    try {
      await _instance.collection(collection).doc(docId).update(data);
    } catch (e) {
      return;
    }
  }

  static Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    final DocumentSnapshot doc =
        await _instance.collection('users').doc(uid).get();
    return doc.exists ? {'user': doc.data(), 'id': doc.id} : null;
  }

  static Stream<Map<String, dynamic>?> getUserDataLive(String uid) {
    return _instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => event.data());
  }

  static Stream<List<Map<String, dynamic>>> getTranscationsOfUser(String uid) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = _instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots();

    Stream<List<Map<String, Object>>> list = snapshot.map((event) =>
        event.docs.map((e) => {'data': e.data(), 'txId': e.id}).toList());

    return list;
  }

  static Future<Transaction?> getTransactionDetails(String uid) async {
    final DocumentSnapshot doc =
        await _instance.collection('transactions').doc(uid).get();
    return doc.exists
        ? Transaction.fromJson(doc.data() as Map<String, dynamic>, doc.id)
        : null;
  }

  static Stream<List<Transaction>?> getTranscationsWithUser(
      String userId, String recipentId) {
    return _instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('receiver', isEqualTo: recipentId)
        .snapshots()
        .map((events) => events.docs
            .map((e) => Transaction.fromJson(e.data(), e.id))
            .toList());
  }

  static Future<void> changeAccountType(bool type, String uid) async {
    await _instance
        .collection('users')
        .doc(uid)
        .update({'accountType': type ? 'merchant' : 'personal'});
  }

  static Future<void> saveUserDetails(
      String uid, Map<String, dynamic> data) async {
    await _instance.collection('users').doc(uid).get().then((doc) async {
      if (doc.exists) {
        await _instance.collection('users').doc(uid).update(data);
      } else {
        await _instance.collection('users').doc(uid).set(data);
      }
    });
  }

  static Stream<List<Map<String, dynamic>>> getUsersByName(String phone) {
    return _instance
        .collection('users')
        .where('phone', isNotEqualTo: phone)
        .snapshots()
        .map((event) => event.docs.map((e) {
              return ({
                'id': e.id,
                'name': e.get('name'),
                'phone': e.get('phone')
              });
            }).toList());
  }

  static Stream<List<Map<String, dynamic>>> getSubscriptions() {
    return _instance
        .collection('subscriptions')
        .snapshots()
        .map((event) => event.docs.map(
          (e) => {...e.data()}).toList()
        );
  }

  static Future<void> transactionWithUser(
      String uid, String receiver, Transaction transaction) async {
    final userData = await _instance.collection('users').doc(uid).get();
    print(userData.data());
    final receiverData =
        await _instance.collection('users').doc(receiver).get();
    print(receiverData.data());
    double balance = (userData.data()?['balance'] ?? 0.0 as int).toDouble();
    double receiverBalance =
        (receiverData.data()?['balance'] ?? 0.0 as int).toDouble();
    print('user balance---->$balance  receiverBalance------> $receiverBalance');
    balance -= transaction.amount;
    receiverBalance += transaction.amount;
    int id = transaction.hashCode;
    await _instance.collection('users').doc(uid).update({'balance': balance});
    await _instance
        .collection('users')
        .doc(receiver)
        .update({'balance': receiverBalance});
    await _instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(id.toString())
        .set({
      'txId': id.toString(),
      'recipentName': transaction.recipentName,
      'amount': transaction.amount,
      'receiver': receiver,
      'details': transaction.details,
      'type': TransactionType.outgoing.toString(),
      'status': TransactionState.pending.toString(),
      'dateTime': transaction.dateTime
    });
    await _instance.collection('transactions').doc(id.toString()).set({
      'txId': id.toString(),
      'recipentName': transaction.recipentName,
      'amount': transaction.amount,
      'receiver': transaction.receiver,
      'sender': uid,
      'status': TransactionState.pending.toString(),
      'details': transaction.details,
      'dateTime': transaction.dateTime
    });
    await _instance
        .collection('users')
        .doc(receiver)
        .collection('transactions')
        .doc(id.toString())
        .set({
      'txId': id.toString(),
      'recipentName': transaction.recipentName,
      'amount': transaction.amount,
      'sender': uid,
      'details': transaction.details,
      'type': TransactionType.incoming.toString(),
      'status': TransactionState.pending.toString(),
      'dateTime': transaction.dateTime
    });
  }

  static Future<void> markFailTransaction(
      String uid, String receiver, Transaction transaction) async {
    final userTx = await _instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .get();
    if (userTx.exists) {
      await _instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .update({
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    } else {
      await _instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .set({
        'txId': transaction.hashCode.toString(),
        'recipentName': transaction.recipentName,
        'amount': transaction.amount,
        'receiver': receiver,
        'details': transaction.details,
        'type': TransactionType.outgoing.toString(),
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    }
    final receiverTx = await _instance
        .collection('users')
        .doc(receiver)
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .get();
    if (receiverTx.exists) {
      await _instance
          .collection('users')
          .doc(receiver)
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .update({
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    } else {
      await _instance
          .collection('users')
          .doc(receiver)
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .set({
        'txId': transaction.hashCode.toString(),
        'recipentName': transaction.recipentName,
        'amount': transaction.amount,
        'sender': uid,
        'details': transaction.details,
        'type': TransactionType.incoming.toString(),
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    }

    final txDetails = await _instance
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .get();
    if (txDetails.exists) {
      await _instance
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .update({
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    } else {
      await _instance
          .collection('transactions')
          .doc(transaction.hashCode.toString())
          .set({
        'txId': transaction.hashCode.toString(),
        'recipentName': transaction.recipentName,
        'amount': transaction.amount,
        'sender': uid,
        'receiver': receiver,
        'details': transaction.details,
        'type': TransactionType.incoming.toString(),
        'status': TransactionState.failed.toString(),
        'dateTime': DateTime.now().toString()
      });
    }
  }

  static Future<bool> checkIfEnoughMoney(double amount, String uid) async {
    final userData = await _instance.collection('users').doc(uid).get();
    double balance = userData.data()?['balance'] ?? 0.0;
    return balance.toDouble() > amount;
  }

  static Future<void> markSuccessfulTransaction(
      String uid, String receiver, Transaction transaction) async {
    await _instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .update({
      'dateTime': DateTime.now().toString(),
      'status': TransactionState.successful.toString(),
    });
    await _instance
        .collection('users')
        .doc(receiver)
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .update({
      'dateTime': DateTime.now().toString(),
      'status': TransactionState.successful.toString(),
    });
    await _instance
        .collection('transactions')
        .doc(transaction.hashCode.toString())
        .update({
      'dateTime': DateTime.now().toString(),
      'status': TransactionState.successful.toString()
    });
  }
}
