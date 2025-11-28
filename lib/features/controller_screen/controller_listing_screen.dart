import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/features/controller_screen/controller/controller_screen_controller.dart';
import 'package:friday_sa/features/controller_screen/screens/add_controller_sheet.dart';
import 'package:friday_sa/helper/route_helper.dart';

class ControllerListingScreen extends StatefulWidget {
  const ControllerListingScreen({super.key});

  @override
  State<ControllerListingScreen> createState() =>
      _ControllerListingScreenState();
}

class _ControllerListingScreenState extends State<ControllerListingScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Get.find<ControllerController>().getController();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "myControllers".tr),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<ControllerController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () {
              return Get.find<ControllerController>().getController();
            },
            child: ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 20, right: 10, top: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (controller.controllerList?.length ?? 3) + 1,
                  itemBuilder: (context, index) {
                    final docData =
                        (controller.controllerList?.length ?? 3) <= index
                        ? null
                        : controller.controllerList?[index];

                    return (controller.controllerList?.length ?? 3) <= index
                        ? GestureDetector(
                            onTap: showControllerSheet,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                color: Colors.grey.shade200,
                              ),
                              height: 100,
                              alignment: Alignment.center,
                              child: Text(
                                "addController".tr,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: controller.controllerList == null
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                              ),
                              color: controller.controllerList == null
                                  ? Colors.grey.shade100
                                  : Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .1),
                            ),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: controller.controllerList == null
                                        ? 10
                                        : 0,
                                    children: [
                                      controller.controllerList == null
                                          ? Shimmer(
                                              child: Container(
                                                height: 15,
                                                width: 180,
                                                color: Theme.of(
                                                  context,
                                                ).shadowColor,
                                              ),
                                            )
                                          : Text(
                                              "${'controller'.tr} ${index + 1}",
                                            ),
                                      controller.controllerList == null
                                          ? Shimmer(
                                              child: Container(
                                                height: 10,
                                                width: 80,
                                                color: Theme.of(
                                                  context,
                                                ).shadowColor,
                                              ),
                                            )
                                          : Text(
                                              "${'channel_id'.tr}: ${docData?.channelId ?? ""}",
                                            ),
                                    ],
                                  ),
                                ),
                                if (controller.controllerList != null)
                                  IconButton(
                                    onPressed: () {
                                      Get.toNamed(
                                        RouteHelper.getControllerRoute(
                                          channelId: docData?.channelId ?? '',
                                          readKey: docData?.readKey ?? '',
                                          writeKey: docData?.writeKey ?? '',
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.remove_red_eye_rounded,
                                    ),
                                  ),
                                if (controller.controllerList != null)
                                  controller.isDeleteLoading &&
                                          controller.deleteId == docData?.id
                                      ? Container(
                                          height: 30,
                                          width: 30,
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                          ),
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 3,
                                              ),
                                        )
                                      : IconButton(
                                          onPressed: () =>
                                              controller.deleteController(
                                                docData?.id ?? 0,
                                              ),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                              ],
                            ),
                          );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String capLatter(String value) {
    return value.split('').first.toUpperCase() +
        value.substring(1, value.length);
  }
}
