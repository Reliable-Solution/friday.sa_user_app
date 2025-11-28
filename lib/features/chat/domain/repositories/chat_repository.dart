import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/chat/domain/models/conversation_model.dart';
import 'package:friday_sa/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:friday_sa/features/chat/enums/user_type_enum.dart';
import 'package:friday_sa/util/app_constants.dart';

class ChatRepository implements ChatRepositoryInterface {
  ChatRepository({required this.apiClient, required this.sharedPreferences});
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  @override
  Future getList({
    int? offset,
    bool conversationList = false,
    String? type,
    bool searchConversationalList = false,
    String? name,
  }) async {
    if (conversationList) {
      return _getConversationList(offset!, type!);
    } else if (searchConversationalList) {
      return _searchConversationList(name!);
    }
  }

  Future<ConversationsModel?> _getConversationList(
    int offset,
    String type,
  ) async {
    ConversationsModel? conversationModel;
    Response response = await apiClient.getData(
      '${AppConstants.conversationListUri}?limit=10&offset=$offset&type=$type',
    );
    if (response.statusCode == 200) {
      conversationModel = ConversationsModel.fromJson(response.body);
    }
    return conversationModel;
  }

  Future<ConversationsModel?> _searchConversationList(String name) async {
    ConversationsModel? searchConversationModel;
    Response response = await apiClient.getData(
      '${AppConstants.searchConversationListUri}?name=$name&limit=20&offset=1',
    );
    if (response.statusCode == 200) {
      searchConversationModel = ConversationsModel.fromJson(response.body);
    }
    return searchConversationModel;
  }

  @override
  Future<Response> getMessages(
    int offset,
    int? userID,
    String userType,
    int? conversationID,
  ) async {
    return apiClient.getData(
      '${AppConstants.messageListUri}?${conversationID != null
          ? 'conversation_id'
          : userType == UserType.admin.name
          ? 'admin_id'
          : userType == UserType.vendor.name
          ? 'vendor_id'
          : 'delivery_man_id'}=${conversationID ?? userID}&offset=$offset&limit=10',
    );
  }

  @override
  Future<Response> sendMessage(
    String message,
    String orderId,
    List<MultipartBody> images,
    int? userID,
    String userType,
    int? conversationID,
  ) async {
    Map<String, String> fields = {};
    if (orderId.isNotEmpty) {
      fields.addAll({'order_id': orderId});
    }
    fields.addAll({
      'message': message,
      'receiver_type': userType,
      'offset': '1',
      'limit': '10',
    });
    if (conversationID != null) {
      fields.addAll({'conversation_id': conversationID.toString()});
    } else {
      fields.addAll({'receiver_id': userID.toString()});
    }
    return apiClient.postMultipartData(
      AppConstants.sendMessageUri,
      fields,
      images,
    );
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
