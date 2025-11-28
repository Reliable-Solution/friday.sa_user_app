// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:date_format/date_format.dart';
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
import 'package:friday_sa/features/controller_screen/screens/warning_componet.dart';

class OperationScreen extends StatefulWidget {
  const OperationScreen({
    super.key,
    required this.channelId,
    required this.writeKey,
    required this.readKey,
  });
  final String channelId;
  final String writeKey;
  final String readKey;

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  TimeOfDay time2 = TimeOfDay.now();
  TimeOfDay time1 = TimeOfDay.now();
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay _time1 = TimeOfDay.now();
  TimeOfDay? picked;
  TimeOfDay? picked1;
  HomeModel? m2 = HomeModel();
  String? onTime;
  String? onTime1;

  var idx;
  String? read;
  String? write;
  String? channel;
  HomeModel? data1;
  Timer? timer;
  Timer? minTimer;
  String? time;
  bool? check1;
  bool? check;
  DateTime now = DateTime.now();
  SharedHelper helper = SharedHelper();
  bool? switchButton = false;
  bool isSuspend = true;
  String onTimeHour1 = "";
  String onTimeMinute1 = "";
  String offTimeHour1 = "";
  String offTimeMinute1 = "";
  String onTimeHour = "";
  String onTimeMin = "";
  String offTimeHour = "";
  String offTimeMin = "";
  bool isScreen = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int id = 0;

  @override
  void initState() {
    super.initState();
    read = widget.readKey;
    write = widget.writeKey;
    channel = widget.channelId;
    readData();
    saveData();
  }

  @override
  void dispose() {
    minTimer!.cancel();
    super.dispose();
  }

  Future<void> saveData() async {
    switchButton = await helper.getMinutes() ?? false;
    debugPrint(
      "============================================== channel ${read}_check",
    );
    check = await helper.getCheck1();
    isSuspend = await helper.getScheduale() ?? true;
    debugPrint("Is Controller Suspend $isSuspend");
    setState(() {});
  }

  Future<void> readData() async {
    m2 =
        (await Services.helper.postforlist(
              api:
                  "${Get.find<ControllerController>().readApi}?api_key=$read&ChannelID=$channel&results=1",
            ))
            as HomeModel?;
    onTime1 = "${m2!.field3!.split("~")}";
    debugPrint("========== onTime ${m2!.field3!.substring(0, 13)}");
    debugPrint("========== onTime ${m2!.field3!.substring(15, 28)}");
    idx = m2!.field3!.split("~");
    onTime = m2!.field3!.substring(0, 13);
    onTime1 = m2!.field3!.substring(15, 28);
    onTimeHour = onTime!.substring(8, 10);
    onTimeMin = onTime!.substring(10, 12);
    offTimeHour = onTime1!.substring(8, 10);
    offTimeMin = onTime1!.substring(10, 12);
    setState(() {});
  }

  Future<Null> selectTime(BuildContext context) async {
    picked = await showTimePicker(context: context, initialTime: _time);
    setState(() {
      _time = picked!;
      onTimeHour = (_time.hour.toInt() <= 9)
          ? "0${_time.hour}"
          : _time.hour.toString();
      onTimeMin = (_time.minute.toInt() <= 9)
          ? "0${_time.minute}"
          : _time.minute.toString();
      debugPrint(picked.toString());
    });
  }

  Future<Null> selectTime1(BuildContext context) async {
    picked1 = await showTimePicker(context: context, initialTime: _time1);
    setState(() {
      _time1 = picked1!;
      offTimeHour = (_time1.hour.toInt() <= 9)
          ? "0${_time1.hour}"
          : _time1.hour.toString();
      offTimeMin = (_time1.minute.toInt() <= 9)
          ? "0${_time1.minute}"
          : _time1.minute.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formated = formatDate(now, [mm]);
    final formated1 = formatDate(now, [dd]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "OperationScreen".tr),
      body: m2 != null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     Text("$onTimeHour:$onTimeMin"),
                  //     Text("$offTimeHour:$offTimeMin"),
                  //   ],
                  // ),
                  Text("MachineOnTime".tr),
                  GestureDetector(
                    onTap: () {
                      selectTime(context);
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(top: 6, bottom: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        onTimeHour.isEmpty
                            ? "SelectTime".tr
                            : "$onTimeHour:$onTimeMin",
                        style: TextStyle(
                          color: onTimeHour.isEmpty
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Text("MachineOffTime".tr),
                  GestureDetector(
                    onTap: () {
                      selectTime1(context);
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(top: 6, bottom: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        onTimeHour.isEmpty
                            ? "SelectTime".tr
                            : "$offTimeHour:$offTimeMin",
                        style: TextStyle(
                          color: onTimeHour.isEmpty
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  CustomButton(
                    buttonText: 'UpdateSystem'.tr,
                    onPressed: () async {
                      // try {
                      debugPrint("=================== api timing $offTimeHour");
                      debugPrint("=================== api timing $offTimeMin");

                      showExitComponet(context: context);
                      HomeModel? data = await Get.find<ControllerController>()
                          .api1Call(
                            read: read!,
                            channel: channel,
                            context: context,
                          );
                      Get.find<ControllerController>().api2Call(
                        data: data,
                        context: context,
                        channel: channel,
                        write: write!,
                        field2: '001',
                        field3:
                            "${now.year}"
                            "$formated"
                            "$formated1"
                            "$onTimeHour"
                            "$onTimeMin"
                            "00"
                            "~"
                            "${now.year}"
                            "$formated"
                            "$formated1"
                            "$offTimeHour"
                            "$offTimeMin"
                            "00",
                      );
                      debugPrint("================== Api 3 call");
                      debugPrint(
                        "================= ${now.year} $formated $formated1 $onTimeHour $onTimeMin 00 ~ ${now.year} $formated $formated1 $offTimeHour $offTimeMin",
                      );
                      Api3("New time ported");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("SystemUpdatedSuccessfully".tr)),
                      );
                      // } catch (error) {
                      //   debugPrint(error.toString());
                      // }
                      setState(() {});
                    },
                  ),
                  const Divider(height: 50),
                  InkWell(
                    onTap: () async {
                      if (switchButton == true) {
                        showExitComponet(context: context, isFrom15Min: true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("15minHotOff".tr)),
                        );
                        switchButton = false;
                        helper.setMinutes(false);
                        timer?.cancel();

                        try {
                          HomeModel? data =
                              await Get.find<ControllerController>().api1Call(
                                read: read!,
                                channel: channel,
                                context: context,
                              );
                          Get.find<ControllerController>().api2Call(
                            data: data,
                            context: context,
                            channel: channel,
                            write: write!,
                            field2: '010',
                            field3: "${data?.field3}",
                          );
                          Api3("pump switched off");
                        } catch (error) {
                          debugPrint(error.toString());
                        }
                      } else {
                        showExitComponet(context: context, isFrom15Min: true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("15minHotOn".tr)),
                        );
                        switchButton = true;
                        helper.setMinutes(true);

                        try {
                          HomeModel? data =
                              await Get.find<ControllerController>().api1Call(
                                read: read!,
                                channel: channel,
                                context: context,
                              );
                          Get.find<ControllerController>().api2Call(
                            data: data,
                            context: context,
                            channel: channel,
                            write: write!,
                            field2: '015',
                            field3: "${data?.field3}",
                          );
                          Api3("pump  switched on");
                          // startTimer();
                        } catch (error) {
                          debugPrint(error.toString());
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: switchButton == false
                          ? Text("15minHotOff".tr, textAlign: TextAlign.center)
                          : Text(
                              "15minHotOn".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (isSuspend) {
                              showExitComponet(
                                context: context,
                                isFromSuspend: true,
                              );

                              helper.setSchedulare(false);
                              isSuspend = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "ScheduleSuspendSuccessfully".tr,
                                  ),
                                ),
                              );
                              try {
                                HomeModel? data =
                                    await Get.find<ControllerController>()
                                        .api1Call(
                                          read: read!,
                                          channel: channel,
                                          context: context,
                                        );
                                Get.find<ControllerController>().api2Call(
                                  data: data,
                                  context: context,
                                  channel: channel,
                                  write: write!,
                                  field2: '014',
                                  field3: "${data?.field3}",
                                );
                                Api3("pump is suspend");
                              } catch (error) {
                                debugPrint(
                                  "Api calling on Schedule suspend $error",
                                );
                              }
                            }
                            setState(() {});
                          },
                          child: Container(
                            alignment: Alignment.center,
                            // padding: EdgeInsets.all(2.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22.5,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "ScheduleSuspend".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isSuspend ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (!isSuspend) {
                              showExitComponet(
                                context: context,
                                isFromSuspend: true,
                              );

                              helper.setSchedulare(true);
                              isSuspend = true;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "ScheduleResumedSuccessfully".tr,
                                  ),
                                ),
                              );
                              try {
                                HomeModel? data =
                                    await Get.find<ControllerController>()
                                        .api1Call(
                                          read: read!,
                                          channel: channel,
                                          context: context,
                                        );
                                Get.find<ControllerController>().api2Call(
                                  data: data,
                                  context: context,
                                  channel: channel,
                                  write: write!,
                                  field2: '013',
                                  field3: "${data?.field3}",
                                );
                                Api3("pump is resume");
                              } catch (error) {
                                debugPrint(
                                  "Api calling on Schedule resume $error",
                                );
                              }
                            }

                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22.5,
                              vertical: 10,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "ScheduleResume".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSuspend ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : commonLoader(context),
    );
  }

  void showExitComponet({
    required BuildContext context,
    bool? isFrom15Min,
    bool? isFromSuspend,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, __) async {
            bool shouldLeave = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("ConfirmExit".tr),
                content: Text("DoYouWantToExitTheProcess?".tr),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Stay
                    child: Text("no".tr),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (isFrom15Min ?? false) {
                        helper.setMinutes(!switchButton!);
                      } else if (isFromSuspend ?? false) {
                        helper.setSchedulare(!isSuspend);
                      }
                    }, // Leave
                    child: Text("yes".tr),
                  ),
                ],
              ),
            );
            if (shouldLeave == true) {
              timer?.cancel();
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Navigate back
            }
          },
          child: commonLoader(context),
        );
      },
    );
  }

  Future<HomeModel?> Api3(String body) async {
    try {
      debugPrint(" Body For APi 3 $body");
      data1 = await Services.helper.postforlist2(
        api:
            "${Get.find<ControllerController>().readApi}?api_key=$read&ChannelID=$channel&results=1",
      );
      if (data1!.field2 == "102") {
        debugPrint("Success: Response 102");
        setState(() {
          if (body == "New time ported") {
            timer!.cancel();
            Navigator.pop(context); // Close the loader
          } else if (body == "pump switched off") {
            timer!.cancel();
            Navigator.pop(context); // Close the loader
          } else if (body == "pump  switched on") {
            startTimer();
            timer!.cancel();
            Navigator.pop(context); // Close the loader
          } else if (body == "pump is resume") {
            timer!.cancel();
            Navigator.pop(context); // Close the loader
          } else if (body == "pump is suspend") {
            timer!.cancel();
            Navigator.pop(context); // Close the loader
          }
        });
      } else if (data1!.field2 == "999") {
        showWarningComponet(context);
        helper.setSchedulare(false);
        timer!.cancel();
      } else {
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
        title: Text("Error".tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("ok".tr),
          ),
        ],
      ),
    );
  }

  Future<HomeModel?> checkTimer() async {
    data1 = await Services.helper.postforlist(
      api:
          "${Get.find<ControllerController>().readApi}?api_key=$read&ChannelID=$channel&results=1"
              .trim(),
    );
    return data1;
  }

  // Function to start the timer
  int _start = 15;
  void startTimer() {
    minTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_start == 0) {
        setState(() {
          minTimer!.cancel();
        });

        showExitComponet(context: context);

        try {
          HomeModel? data = await Get.find<ControllerController>().api1Call(
            read: read!,
            channel: channel,
            context: context,
          );
          Get.find<ControllerController>().api2Call(
            data: data,
            context: context,
            channel: channel,
            write: write!,
            field2: '010',
            field3: "${data?.field3}",
          );
          Api3("pump switched off");
          switchButton = false;
          helper.setMinutes(false);
        } catch (error) {
          debugPrint(error.toString());
        }
      } else {
        setState(() {
          _start--;
        });
        debugPrint("Time remaining: $_start");
      }
    });
  }
}
