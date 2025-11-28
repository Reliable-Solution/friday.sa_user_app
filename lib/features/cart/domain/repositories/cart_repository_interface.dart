import 'package:friday_sa/features/cart/domain/models/cart_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class CartRepositoryInterface<OnlineCart>
    extends RepositoryInterface<OnlineCart> {
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList);
  @override
  Future<dynamic> update(
    Map<String, dynamic> body,
    int? id, {
    num price,
    int quantity,
    bool isUpdateQty = false,
  });
  @override
  Future<bool> delete(int? id, {bool isRemoveAll = false});
}
