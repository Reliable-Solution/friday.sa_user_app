import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/banner/domain/models/banner_model.dart';
import 'package:friday_sa/features/banner/domain/models/others_banner_model.dart';
import 'package:friday_sa/features/banner/domain/models/promotional_banner_model.dart';
import 'package:friday_sa/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:friday_sa/features/banner/domain/services/banner_service_interface.dart';
import 'package:friday_sa/features/location/domain/models/zone_response_model.dart';
import 'package:friday_sa/helper/address_helper.dart';

class BannerService implements BannerServiceInterface {
  BannerService({required this.bannerRepositoryInterface});
  final BannerRepositoryInterface bannerRepositoryInterface;

  @override
  Future<BannerModel?> getBannerList({required DataSourceEnum source}) async {
    return await bannerRepositoryInterface.getList(
      isBanner: true,
      source: source,
    );
  }

  @override
  Future<BannerModel?> getTaxiBannerList() async {
    return await bannerRepositoryInterface.getList(isTaxiBanner: true);
  }

  @override
  Future<BannerModel?> getFeaturedBannerList() async {
    return await bannerRepositoryInterface.getList(isFeaturedBanner: true);
  }

  @override
  Future<ParcelOtherBannerModel?> getParcelOtherBannerList({
    required DataSourceEnum source,
  }) async {
    return await bannerRepositoryInterface.getList(
      isParcelOtherBanner: true,
      source: source,
    );
  }

  @override
  Future<PromotionalBanner?> getPromotionalBannerList() async {
    return await bannerRepositoryInterface.getList(isPromotionalBanner: true);
  }

  @override
  List<int?> moduleIdList() {
    List<int?> moduleIdList = [];
    for (ZoneData zone
        in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (Modules module in zone.modules ?? []) {
        moduleIdList.add(module.id);
      }
    }
    return moduleIdList;
  }
}
