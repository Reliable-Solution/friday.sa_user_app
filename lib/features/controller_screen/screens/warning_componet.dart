import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showWarningComponet(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog without reconnecting
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning,
                size: 50,
              ),
              // Image.asset(
              //   'assets/no_internet.png', // Add your custom illustration here
              //   height: 120,
              // ),
              const SizedBox(height: 20),
              Text(
                "ControllerIsSusspend".tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // _checkInitialConnection(); // Recheck connection when retry is pressed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "ok".tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
