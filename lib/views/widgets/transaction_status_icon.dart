import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:zenipay/models/transaction.dart';

class TransactionStatusIcon extends StatefulWidget {
  const TransactionStatusIcon({super.key, required this.state});
  final String state;
  @override
  State<TransactionStatusIcon> createState() => _TransactionStatusIconState();
}

class _TransactionStatusIconState extends State<TransactionStatusIcon> {
  Color color = Colors.transparent;
  IconData chooseIcon() {
    if (widget.state.contains('success')) {
      color = const Color.fromARGB(250, 0, 252, 4);
      return Icons.done;
    } else if (widget.state.contains('pending')) {
      color = const Color.fromARGB(255, 239, 152, 11);
      return Icons.info;
    } else {
      color = const Color.fromARGB(240, 255, 0, 60);
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white12,
      child: Icon(
        color: color,
        chooseIcon()
      ),
    );
  }
}