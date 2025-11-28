import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/features/controller_screen/controller/controller_screen_controller.dart';
import 'package:friday_sa/features/controller_screen/models/homeModel.dart';
import 'package:friday_sa/features/controller_screen/repositories/services.dart';
import 'package:friday_sa/features/controller_screen/repositories/shared_helper.dart';
import 'package:friday_sa/features/controller_screen/screens/common_loader.dart';
import 'package:friday_sa/features/controller_screen/screens/operation_screen.dart';
import 'package:friday_sa/features/controller_screen/screens/warning_componet.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/util/images.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({
    super.key,
    required this.channelId,
    required this.readKey,
    required this.writeKey,
  });
  final String channelId;
  final String readKey, writeKey;

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  DateTime date = DateTime.now();
  Service s1 = Service();
  SharedHelper helper = SharedHelper();
  String? time;
  String? time1 = "";
  String? dateHome = "";
  var idx;
  HomeModel? m1;

  String? read;
  String? write;
  String? channel;
  bool? statusUpdate;
  String? name;
  bool? check1;
  Timer? timer;
  String? onTime = " isLoading...";
  String? offTime = " isLoading...";
  var idx1;
  String voltage = "";
  String current = "";
  String singlePhase = "";
  String water1 = "";
  String water2 = "";
  String building = "";
  String phase = "";
  String binaryData = "";

  HomeModel? data1;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int id = 0;

  String intToBinary(int number) {
    return number.toRadixString(2);
  }

  @override
  void initState() {
    super.initState();
    saveData();
  }

  Future<void> readData() async {
    m1 = await Services.helper.postforlist(
      api:
          "${Get.find<ControllerController>().readApi}?api_key=$read&ChannelID=$channel&results=1",
    );
    binaryData = "0${intToBinary(int.parse(m1!.field4!))}";
    print("============ binary data $binaryData");
    voltage = binaryData[3];
    current = binaryData[7];
    phase = binaryData[6];
    water1 = binaryData[5];
    water2 = binaryData[1];
    building = binaryData[2];
    singlePhase = binaryData[4];
    time = m1!.field7;
    check1 = true;
    print(
      "============ voltage = $voltage \n"
      "current = $current\n"
      "phase = $phase\n"
      "water1 = $water1\n"
      "water2 = $water2\n"
      "building = $building\n"
      "singlePhase = $singlePhase",
    );

    time1 = m1!.field7!
        .substring(0, 14)
        .replaceAll("--", " ")
        .replaceAll('Time ', '');
    dateHome = m1!.field7!
        .substring(15, m1!.field7!.length)
        .replaceAll("--", " ")
        .replaceAll("-", " ");

    idx1 = m1!.field3!.split("~");
    onTime = m1!.field3!.substring(0, 14);
    offTime = m1!.field3!.substring(15, 29);

    setState(() {});
  }

  Future<void> saveData() async {
    write = widget.writeKey;
    read = widget.readKey;
    channel = widget.channelId;
    name = await helper.getName();
    setState(() {});
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: name ?? "Controller"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${"LastStatusUpdateTime".tr}:  $time1 ${dateHome == "Time-left" ? '' : '|$dateHome'}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (dateHome == "Time-left")
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "${'TimeLeftForProcessDone'.tr}: ${int.parse(dateHome ?? '0')} ${'Min'.tr}.",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children:
                        [
                              ("Voltage".tr, voltage == "0", true),
                              ("", false, false),
                              ("Current".tr, current == "0", true),
                            ]
                            .map(
                              (e) => e.$3
                                  ? Expanded(
                                      child: Row(
                                        spacing: 10,
                                        children: [
                                          Text(e.$1),
                                          Image.asset(
                                            e.$2
                                                ? Images.redLine
                                                : Images.greenLine,
                                            height: 35,
                                            width: 35,
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 20,
                                      child: VerticalDivider(
                                        width: 40,
                                        thickness: 1,
                                        color: Theme.of(
                                          context,
                                        ).secondaryHeaderColor,
                                      ),
                                    ),
                            )
                            .toList(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children:
                        [
                              ("Water1".tr, water1 == "0", true),
                              ("", false, false),
                              ("Water2".tr, water2 == "0", true),
                            ]
                            .map(
                              (e) => e.$3
                                  ? Expanded(
                                      child: Row(
                                        spacing: 10,
                                        children: [
                                          Text(e.$1),
                                          Image.asset(
                                            e.$2
                                                ? Images.redLine
                                                : Images.greenLine,
                                            height: 35,
                                            width: 35,
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 20,
                                      child: VerticalDivider(
                                        width: 40,
                                        thickness: 1,
                                        color: Theme.of(
                                          context,
                                        ).secondaryHeaderColor,
                                      ),
                                    ),
                            )
                            .toList(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 10,
                          children: [
                            Text("Phase".tr),
                            Image.asset(
                              phase == "0" ? Images.redLine : Images.greenLine,
                              height: 35,
                              width: 35,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          width: 40,
                          thickness: 1,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          singlePhase == "0" ? "3Phase".tr : "SinglePhase".tr,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Text(
                        'Type'.tr,
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Building'.tr,
                              style: TextStyle(
                                color: building == "1"
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                            Image.asset(
                              building == "1" ? Images.greenDot : Images.redDot,
                              height: 15,
                              width: 15,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          width: 40,
                          thickness: 1,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Agriculture'.tr,
                              style: TextStyle(
                                color: building != "1"
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                            Image.asset(
                              building != "1" ? Images.greenDot : Images.redDot,
                              height: 15,
                              width: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: CustomButton(
                    buttonText: 'Operations'.tr,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OperationScreen(
                            channelId: widget.channelId,
                            readKey: widget.readKey,
                            writeKey: widget.writeKey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CustomButton(
                  buttonText: 'UpdateStatus'.tr,
                  onPressed: () async {
                    saveData();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: commonLoader,
                    );

                    try {
                      HomeModel? data = await Get.find<ControllerController>()
                          .api1Call(
                            read: read!,
                            channel: channel,
                            context: context,
                          );
                      Get.find<ControllerController>().api2Call(
                        data: data,
                        // ignore: use_build_context_synchronously
                        context: context,
                        channel: channel,
                        write: write!,
                        field2: '101',
                        field3: "$onTime~$offTime",
                      );
                      Api3("Status update");
                    } catch (error) {
                      debugPrint(error.toString());
                    }
                  },
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     InkWell(
                //       onTap: () {
                //         // setState(() {
                //         //   Navigator.push(
                //         //     context,
                //         //     MaterialPageRoute(
                //         //       builder: (context) => PasswordScreen(
                //         //         isOperation: true,
                //         //         homeScreenFunc: updateTaskStatus,
                //         //       ),
                //         //     ),
                //         //   );
                //         // });
                //       },
                //       child: Container(
                //         height: 40,
                //         width: 150,
                //         color: Colors.grey.shade400,
                //         alignment: Alignment.center,
                //         child: const Text("Operations"),
                //       ),
                //     ),
                //     InkWell(
                //       onTap: () async {
                //         saveData();
                //         showDialog(
                //           context: context,
                //           barrierDismissible: false,
                //           builder: commonLoader,
                //         );
                //         try {
                //           HomeModel? data =
                //               await Get.find<ControllerController>().api1Call(
                //             read: read!,
                //             channel: channel,
                //             context: context,
                //           );
                //           Get.find<ControllerController>().api2Call(
                //             data: data,
                //             context: context,
                //             channel: channel,
                //             write: write!,
                //             field: '101',
                //             field3: "$onTime~$offTime",
                //           );
                //           Api3("Status update");
                //         } catch (error) {
                //           print(error);
                //         }
                //       },
                //       child: Container(
                //         height: 40,
                //         width: 150,
                //         color: Colors.grey.shade400,
                //         alignment: Alignment.center,
                //         child: const Text("Status update"),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            // Table(
            //   columnWidths: const {
            //     0: IntrinsicColumnWidth(), // Adjusts width based on content
            //   },
            //   children: [
            //     TableRow(
            //       children: [
            //         const Text("Current on Time : "),
            //         Text("$onTime"),
            //       ],
            //     ),
            //     TableRow(
            //       children: [
            //         const Text("Current off Time : "),
            //         Text("$offTime"),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Future<HomeModel?> Api3(String body) async {
    try {
      data1 = await Services.helper.postforlist2(
        api:
            "${Get.find<ControllerController>().readApi}?api_key=$read&ChannelID=$channel&results=1",
      );

      time = data1!.field7;
      check1 = true;
      setState(() {});
      idx = time!.split("--");
      time1 = "${idx[0]} ${idx[1]}";
      dateHome = m1!.field7!
          .substring(15, m1!.field7!.length)
          .replaceAll("--", " ")
          .replaceAll("-", " ");

      print("API3 Data: ${data1!.field2}");

      if (data1!.field2 == "102") {
        print("Success: Response 102");
        setState(() {
          Navigator.pop(context);
        });
      } else if (data1!.field2 == "999") {
        showWarningComponet(context);
        helper.setSchedulare(false);
        timer!.cancel();
      } else {
        // Keep checking until the response is "102"
        timer?.cancel(); // Cancel any existing timer
        timer = Timer(const Duration(seconds: 15), () => Api3(body));
      }
      return data1;
    } catch (e) {
      showErrorDialog(context, "Something went wrong: $e");
    }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
