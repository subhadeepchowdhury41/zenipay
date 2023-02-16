import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction.dart';
import '../../../services/firestore_services.dart';
import '../../../utils/app_contants.dart';
import '../../widgets/row_details_widget.dart';

class TransactonDetailsScreen extends StatelessWidget {
  final String transactionId;
  final bool backToHome;
  final String transactionType;
  const TransactonDetailsScreen({
    Key? key,
    required this.transactionId,
    this.backToHome = false,
    required this.transactionType,
  }) : super(key: key);

  Future<Transaction?> _getTransactionDetails() async {
    return FirestoreServices.getTransactionDetails(transactionId);
  }

  Widget _getStatusIcon(TransactionState state) {
    if (state == TransactionState.successful) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: darkGreen,
        child: Icon(
          FontAwesomeIcons.check,
          size: 32,
          color: success,
        ),
      );
    } else if (state == TransactionState.pending) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: warning.withOpacity(0.15),
        child: Icon(
          FontAwesomeIcons.rotate,
          size: 32,
          color: warning,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 32,
        backgroundColor: error.withOpacity(0.15),
        child: Icon(
          Icons.error,
          size: 32,
          color: error,
        ),
      );
    }
  }

  String _getDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String dateF = DateFormat().format(DateTime.parse(date));
    Duration diff = DateTime.now().difference(dateTime);

    if (diff.inDays != 0) {
      if (diff.inDays > 7) {
        return '${diff.inDays / 7} weeks ago';
      } else if (diff.inDays > 30) {
        return '${diff.inDays / 30} months ago';
      } else if (diff.inDays > 365) {
        return '${diff.inDays / 7} years ago';
      }
      return '${diff.inDays} days ago';
    } else if (diff.inHours != 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes != 0) {
      return '${diff.inMinutes} mins ago';
    } else {
      return '${diff.inSeconds} seconds ago';
    }
  }

  String getState(TransactionState stats) {
    if (stats == TransactionState.successful) {
      return 'Successful';
    } else if (stats == TransactionState.pending) {
      return 'Pending';
    } else {
      return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                'ID: ${transactionId}',
                style: TextStyle(
                  color: text300,
                  fontSize: body1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          elevation: 0.0,
          backgroundColor: background,
        ),
        body: FutureBuilder(
          future: _getTransactionDetails(),
          builder: (context, AsyncSnapshot<Transaction?> transactionDetails) {
            if (transactionDetails.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (transactionDetails.hasError ||
                transactionDetails.data == null) {
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
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    _getStatusIcon(transactionDetails.data!.state),
                    const SizedBox(height: 15),
                    Text(
                      transactionDetails.data!.state ==
                              TransactionState.successful
                          ? 'Successful'
                          : (transactionDetails.data?.state ==
                                  TransactionState.pending
                              ? 'Pending'
                              : 'Failed'),
                      style: TextStyle(
                        color: text300,
                        fontSize: body1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// Identification
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                        color: text100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Identification',
                            style: TextStyle(
                              color: text300,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Transaction Type',
                              value: transactionType.substring(
                                  16, transactionType.length)),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Details',
                              value: '${transactionDetails.data!.details}'),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Date',
                              value:
                                  _getDate(transactionDetails.data!.dateTime!)),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Amount',
                              value: '${transactionDetails.data!.amount} INR'),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Sender',
                              value: '${transactionDetails.data!.sender}'),
                          const SizedBox(height: 25),
                          RowDetailWidget(
                              title: 'Receiver',
                              value:
                                  '${transactionDetails.data!.recipentName}  Uid: ${transactionDetails.data!.receiver}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
