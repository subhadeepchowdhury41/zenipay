import 'package:flutter/cupertino.dart';


import '../../utils/app_contants.dart';

class RowDetailWidget extends StatelessWidget {
  const RowDetailWidget({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: text300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded
        (
          child: Text(
            value,
            style: TextStyle(
              fontSize: body1,
              color: text500,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
