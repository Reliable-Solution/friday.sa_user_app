import 'package:flutter/material.dart';

Widget commonLoader(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(
      color: Theme.of(context).primaryColor,
    ),
  );
}
