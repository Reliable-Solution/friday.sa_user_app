import 'package:flutter/material.dart';

class TaxiOrderDetailsScreen extends StatefulWidget {
  const TaxiOrderDetailsScreen(
      {super.key, required this.tripId, this.fromCheckout = false, this.phone,});
  final int tripId;
  final bool? fromCheckout;
  final String? phone;

  @override
  State<TaxiOrderDetailsScreen> createState() => _TaxiOrderDetailsScreenState();
}

class _TaxiOrderDetailsScreenState extends State<TaxiOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
