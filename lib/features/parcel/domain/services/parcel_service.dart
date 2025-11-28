import 'package:get/get_connect/http/src/response/response.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/checkout/domain/models/place_order_body_model.dart';
import 'package:friday_sa/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:friday_sa/features/parcel/domain/models/parcel_category_model.dart';
import 'package:friday_sa/features/parcel/domain/models/video_content_model.dart';
import 'package:friday_sa/features/parcel/domain/models/why_choose_model.dart';
import 'package:friday_sa/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:friday_sa/features/parcel/domain/services/parcel_service_interface.dart';
import 'package:friday_sa/features/payment/domain/models/offline_method_model.dart';

import '../models/parcel_instruction_model.dart';

class ParcelService implements ParcelServiceInterface {
  ParcelService({
    required this.parcelRepositoryInterface,
    required this.checkoutRepositoryInterface,
  });
  final ParcelRepositoryInterface parcelRepositoryInterface;
  final CheckoutRepositoryInterface checkoutRepositoryInterface;

  @override
  Future<List<ParcelCategoryModel>?> getParcelCategory() async {
    return await parcelRepositoryInterface.getList();
  }

  @override
  Future<List<Data>?> getParcelInstruction(int offset) async {
    return await parcelRepositoryInterface.getList(
      offset: offset,
      parcelCategory: false,
    );
  }

  @override
  Future<WhyChooseModel?> getWhyChooseDetails({
    required DataSourceEnum source,
  }) async {
    return await parcelRepositoryInterface.get(
      null,
      isVideoDetails: false,
      source: source,
    );
  }

  @override
  Future<VideoContentModel?> getVideoContentDetails({
    required DataSourceEnum source,
  }) async {
    return await parcelRepositoryInterface.get(
      null,
      isVideoDetails: true,
      source: source,
    );
  }

  @override
  Future<Response> getPlaceDetails(String? placeID) async {
    return parcelRepositoryInterface.getPlaceDetails(placeID);
  }

  @override
  Future<List<OfflineMethodModel>?> getOfflineMethodList() async {
    return await checkoutRepositoryInterface.getList();
  }

  @override
  Future<int> getDmTipMostTapped() async {
    return checkoutRepositoryInterface.getDmTipMostTapped();
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody) async {
    return checkoutRepositoryInterface.placeOrder(orderBody, null);
  }
}
