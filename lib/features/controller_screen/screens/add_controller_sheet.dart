import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/custom_text_field.dart';
import 'package:friday_sa/features/controller_screen/controller/controller_screen_controller.dart';

void showControllerSheet() {
  Get.bottomSheet(
    const AddControllerSheet(),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class AddControllerSheet extends StatefulWidget {
  const AddControllerSheet({super.key});

  @override
  State<AddControllerSheet> createState() => _AddControllerSheetState();
}

class _AddControllerSheetState extends State<AddControllerSheet> {
  final channelIdController = TextEditingController();
  final readKeyController = TextEditingController();
  final writeKeyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addController'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: writeKeyController,
              labelText: 'writeApiKey'.tr,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomTextField(
                controller: readKeyController,
                labelText: 'readApiKey'.tr,
              ),
            ),
            CustomTextField(
              labelText: 'enterChannelId'.tr,
              hintText: '',
              controller: channelIdController,
            ),
            const SizedBox(height: 30),
            GetBuilder<ControllerController>(
              builder: (controller) {
                return CustomButton(
                  buttonText: "save".tr,
                  color: Theme.of(context).primaryColor,
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          if (channelIdController.text.isEmpty) {
                            showCustomSnackBar('pleaseEnterChannelId'.tr);
                          } else {
                            Get.back();
                            await Get.find<ControllerController>()
                                .addController(
                                  channelId: channelIdController.text,
                                  readKey: readKeyController.text,
                                  writeKey: writeKeyController.text,
                                );
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
