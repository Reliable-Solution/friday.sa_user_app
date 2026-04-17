import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/banner/domain/models/banner_model.dart';
import 'package:friday_sa/features/banner/domain/models/others_banner_model.dart';
import 'package:friday_sa/features/banner/domain/models/promotional_banner_model.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/features/banner/domain/services/banner_service_interface.dart';

class BannerController extends GetxController implements GetxService {
  BannerController({required this.bannerServiceInterface});
  final BannerServiceInterface bannerServiceInterface;

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;

  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;

  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;

  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;

  List<dynamic>? _featuredBannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  ParcelOtherBannerModel? _parcelOtherBannerModel;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;

  PromotionalBanner? _promotionalBanner;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  Future<void> getFeaturedBanner() async {
    BannerModel? bannerModel = await bannerServiceInterface
        .getFeaturedBannerList();
    if (bannerModel != null) {
      List<String?> featuredBannerList = [];
      List<dynamic> featuredBannerDataList = [];

      List<int?> moduleIdList = bannerServiceInterface.moduleIdList();

      for (var campaign in bannerModel.campaigns!) {
        if (featuredBannerList.contains(campaign.imageFullUrl)) {
          featuredBannerList.add(
            '${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}',
          );
        } else {
          featuredBannerList.add(campaign.imageFullUrl);
        }
        featuredBannerDataList.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if (featuredBannerList.contains(banner.imageFullUrl)) {
          featuredBannerList.add(
            '${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}',
          );
        } else {
          featuredBannerList.add(banner.imageFullUrl);
        }
        if (banner.item != null &&
            moduleIdList.contains(banner.item!.moduleId)) {
          featuredBannerDataList.add(banner.item);
        } else if (banner.store != null &&
            moduleIdList.contains(banner.store!.moduleId)) {
          featuredBannerDataList.add(banner.store);
        } else if (banner.type == 'default') {
          featuredBannerDataList.add(banner.link);
        } else {
          featuredBannerDataList.add(null);
        }
      }
      _featuredBannerList = featuredBannerList;
      _featuredBannerDataList = featuredBannerDataList;
    }
    update();
  }

  void clearBanner() {
    _bannerImageList = null;
  }

  Future<void> getBannerList(
    bool reload, {
    DataSourceEnum dataSource = DataSourceEnum.local,
    bool fromRecall = false,
  }) async {
    if (_bannerImageList == null || reload || fromRecall) {
      if (reload) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if (dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(
          source: DataSourceEnum.local,
        );
        await _prepareBanner(bannerModel);

        getBannerList(
          false,
          dataSource: DataSourceEnum.client,
          fromRecall: true,
        );
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(
          source: DataSourceEnum.client,
        );
        _prepareBanner(bannerModel);
      }
    }
  }

  _prepareBanner(BannerModel? bannerModel) async {
    if (bannerModel != null) {
      List<String?>? bannerImageList = [];
      List<dynamic>? bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if (bannerImageList.contains(campaign.imageFullUrl)) {
          bannerImageList.add(
            '${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}',
          );
        } else {
          bannerImageList.add(campaign.imageFullUrl);
        }
        bannerDataList.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if (bannerImageList.contains(banner.imageFullUrl)) {
          bannerImageList.add(
            '${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}',
          );
        } else {
          bannerImageList.add(banner.imageFullUrl);
        }

        if (banner.item != null) {
          bannerDataList.add(banner.item);
        } else if (banner.store != null) {
          bannerDataList.add(banner.store);
        } else if (banner.type == 'default') {
          bannerDataList.add(banner.link);
        } else {
          bannerDataList.add(null);
        }
      }
      _bannerImageList = bannerImageList;
      _bannerDataList = bannerDataList;
    }
    update();
  }

  Future<void> getTaxiBannerList(bool reload) async {
    if (_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      BannerModel? bannerModel = await bannerServiceInterface
          .getTaxiBannerList();
      if (bannerModel != null) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.imageFullUrl);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.imageFullUrl);
          if (banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          } else if (banner.store != null) {
            _taxiBannerDataList!.add(banner.store);
          } else if (banner.type == 'default') {
            _taxiBannerDataList!.add(banner.link);
          } else {
            _taxiBannerDataList!.add(null);
          }
        }
        if (ResponsiveHelper.isDesktop(Get.context) &&
            _taxiBannerImageList!.length % 2 != 0) {
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }
      }
      update();
    }
  }

  Future<void> getParcelOtherBannerList(
    bool reload, {
    DataSourceEnum dataSource = DataSourceEnum.local,
    bool fromRecall = false,
  }) async {
    if (_parcelOtherBannerModel == null || reload || fromRecall) {
      ParcelOtherBannerModel? parcelOtherBannerModel;
      if (dataSource == DataSourceEnum.local) {
        parcelOtherBannerModel = await bannerServiceInterface
            .getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
        getParcelOtherBannerList(
          false,
          dataSource: DataSourceEnum.client,
          fromRecall: true,
        );
      } else {
        parcelOtherBannerModel = await bannerServiceInterface
            .getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
      }
    }
  }

  _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
    if (parcelOtherBannerModel != null) {
      _parcelOtherBannerModel = parcelOtherBannerModel;
    }
    update();
  }

  Future<void> getPromotionalBannerList(bool reload) async {
    if (_promotionalBanner == null || reload) {
      _promotionalBanner = null;
      PromotionalBanner? promotionalBanner = await bannerServiceInterface
          .getPromotionalBannerList();
      if (promotionalBanner != null) {
        _promotionalBanner = promotionalBanner;
      }
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }
}
