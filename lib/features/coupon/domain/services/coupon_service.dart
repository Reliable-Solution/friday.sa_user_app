import 'package:friday_sa/features/coupon/domain/models/coupon_model.dart';
import 'package:friday_sa/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:friday_sa/features/coupon/domain/services/coupon_service_interface.dart';

class CouponService implements CouponServiceInterface {
  CouponService({required this.couponRepositoryInterface});
  final CouponRepositoryInterface couponRepositoryInterface;

  @override
  Future<List<CouponModel>?> getCouponList() async {
    return await couponRepositoryInterface.getList(couponList: true);
  }

  @override
  Future<List<CouponModel>?> getTaxiCouponList() async {
    return await couponRepositoryInterface.getList(taxiCouponList: true);
  }

  @override
  Future<CouponModel?> applyCoupon(String couponCode, int? storeID) async {
    return await couponRepositoryInterface.applyCoupon(couponCode, storeID);
  }

  @override
  Future<CouponModel?> applyTaxiCoupon(
    String couponCode,
    int? providerId,
  ) async {
    return await couponRepositoryInterface.applyTaxiCoupon(
      couponCode,
      providerId,
    );
  }
}
