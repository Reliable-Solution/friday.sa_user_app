// import 'package:friday_sa/common/widgets/custom_button.dart';
// import 'package:friday_sa/features/upload_doc/controller/upload_doc_controller.dart';
// import 'package:friday_sa/helper/auth_helper.dart';
// import 'package:friday_sa/common/widgets/custom_app_bar.dart';
// import 'package:friday_sa/common/widgets/menu_drawer.dart';
// import 'package:friday_sa/common/widgets/no_data_screen.dart';
// import 'package:friday_sa/common/widgets/not_logged_in_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// class UploadDocScreen extends StatefulWidget {
//   const UploadDocScreen({super.key});

//   @override
//   State<UploadDocScreen> createState() => _UploadDocScreenState();
// }

// class _UploadDocScreenState extends State<UploadDocScreen> {
//   ScrollController scrollController = ScrollController();
//   @override
//   void initState() {
//     super.initState();
//     initCall();
//   }

//   void initCall() {
//     if (AuthHelper.isLoggedIn()) {
//       Get.put<UploadDocController>(UploadDocController());
//       // Get.find<CouponController>().getDocList();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isLoggedIn = AuthHelper.isLoggedIn();
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: const CustomAppBar(title: "Upload documents"),
//       endDrawer: const MenuDrawer(),
//       endDrawerEnableOpenDragGesture: false,
//       bottomNavigationBar: IntrinsicHeight(
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: (MediaQuery.paddingOf(context).bottom / 2) + 10,
//             left: 20,
//             right: 20,
//             top: 10,
//           ),
//           child: const CustomButton(buttonText: 'Upload'),
//         ),
//       ),
//       body: isLoggedIn
//           ? GetBuilder<UploadDocController>(
//               builder: (uploadDocController) {
//                 if (!uploadDocController.isLoad) {
//                   return RefreshIndicator(
//                     onRefresh: () async => Future.wait([]),
//                     child: ListView(
//                       children: [
//                         GestureDetector(
//                           onTap: () => uploadDocController.pickFiles(),
//                           child: Container(
//                             width: double.infinity,
//                             margin: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               color: Theme.of(context)
//                                   .disabledColor
//                                   .withValues(alpha: .1),
//                               border: Border.all(
//                                 color: Theme.of(context).disabledColor,
//                               ),
//                             ),
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               spacing: 5,
//                               children: [
//                                 Icon(
//                                   Icons.add_rounded,
//                                   size: 30,
//                                   color: Theme.of(context).disabledColor,
//                                 ),
//                                 const Text("Upload your documents..."),
//                               ],
//                             ),
//                           ),
//                         ),
//                         if (uploadDocController.docList.isEmpty)
//                           const NoDataScreen(
//                             text: 'No documents found',
//                             showFooter: true,
//                           )
//                         else
//                           ListView.builder(
//                             shrinkWrap: true,
//                             padding: const EdgeInsets.only(left: 20, right: 10),
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: uploadDocController.docList.length,
//                             itemBuilder: (context, index) {
//                               final docData =
//                                   uploadDocController.docList[index];
//                               return Stack(
//                                 alignment: Alignment.topRight,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       // if()
//                                       launchUrlString(docData.url);
//                                     },
//                                     child: Container(
//                                       height: 60,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         color: Theme.of(context)
//                                             .disabledColor
//                                             .withValues(alpha: .1),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       margin: const EdgeInsets.only(
//                                         top: 15,
//                                         right: 10,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             height: 60,
//                                             alignment: Alignment.center,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   const BorderRadius.only(
//                                                 topLeft: Radius.circular(8),
//                                                 bottomLeft: Radius.circular(8),
//                                               ),
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                             ),
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 12,
//                                             ),
//                                             child: Text(
//                                               docData.url.contains('.')
//                                                   ? ".${docData.url.split('.').last}"
//                                                   : '.ext',
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .titleLarge
//                                                   ?.copyWith(
//                                                     color: Theme.of(context)
//                                                         .scaffoldBackgroundColor,
//                                                   ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 horizontal: 12,
//                                                 vertical: 8,
//                                               ),
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceAround,
//                                                 children: [
//                                                   Text(
//                                                     docData.url.split('/').last,
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .titleMedium,
//                                                   ),
//                                                   const Align(
//                                                     alignment:
//                                                         Alignment.bottomRight,
//                                                     child: Text(
//                                                       '10th Jan, 2025',
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                         fontSize: 10,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(5),
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           uploadDocController.removeDoc(index),
//                                       child: const CircleAvatar(
//                                         radius: 12,
//                                         child: Icon(
//                                           Icons.close_rounded,
//                                           size: 16,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                       ],
//                     ),
//                   );
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             )
//           : NotLoggedInScreen(
//               callBack: (bool value) {
//                 initCall();
//                 setState(() {});
//               },
//             ),
//     );
//   }
// }
