// import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';
// import 'package:friday_sa/features/upload_doc/models/upload_doc_model.dart';

// class UploadDocController extends GetxController {
//   List<UploadDocModel> _docList = [];
//   List<UploadDocModel> get docList => _docList;

//   bool isLoad = false;

//   void addDocuments(UploadDocModel documents) {
//     // isLoad = true;
//     // update();
//     final dummyList = [..._docList] + [documents];
//     _docList = dummyList;
//     // isLoad = false;
//     // update();
//   }

//   Future<void> pickFiles() async {
//     FilePickerResult? files =
//         await FilePicker.platform.pickFiles(allowMultiple: true);

//     for (var file in files?.files ?? <PlatformFile>[]) {
//       addDocuments(UploadDocModel(url: file.xFile.path, docId: docList.length));
//     }
//     update();
//   }

//   void removeDoc(int index) {
//     _docList.removeAt(index);
//     update();
//   }
// }
