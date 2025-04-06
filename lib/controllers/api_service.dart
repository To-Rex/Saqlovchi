import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'get_controller.dart';

class ApiService {
  final _suPaBase = Supabase.instance.client;
  GetController get controller => Get.find<GetController>();

  // Kategoriyalarni olish
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _suPaBase
          .from('categories')
          .select('id, name, created_by, users!categories_created_by_fkey(full_name)')
          .order('created_at', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Kategoriyalarni olishda xato: $e');
    }
  }

  // Birliklarni olish
  Future<List<dynamic>> getUnits() async {
    try {
      final response = await _suPaBase.from('units').select('id, name').order('name', ascending: true);
      if (response.isEmpty) {
        print('Hech qanday birlik topilmadi');
      }
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Birliklarni olishda xato: $e');
    }
  }

  // Kategoriya qo‘shish
  Future<void> addCategory(String name) async {
    try {
      await _suPaBase.from('categories').insert({
        'name': name,
        'created_by': _suPaBase.auth.currentUser?.id,
      });
    } catch (e) {
      throw Exception('Kategoriya qo‘shishda xato: $e');
    }
  }

  // Kategoriyani tahrirlash
  Future<void> editCategory(String id, String newName) async {
    try {
      await _suPaBase.from('categories').update({'name': newName}).eq('id', id);
    } catch (e) {
      throw Exception('Kategoriyani tahrirlashda xato: $e');
    }
  }

  // Kategoriyani o‘chirish
  Future<void> deleteCategory(String id) async {
    try {
      await _suPaBase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Kategoriyani o‘chirishda xato: $e');
    }
  }

  // Mahsulotlarni olish
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _suPaBase
          .from('products')
          .select('id, name, category_id, cost_price, selling_price, quantity, unit_id, units(name), created_at, created_by, users!products_created_by_fkey(full_name), batches(id, batch_number, cost_price, quantity)')
          .order('created_at', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Mahsulotlarni olishda xato: $e');
    }
  }

  // Filtlangan va tartiblangan mahsulotlarni olish
  Future<List<dynamic>> getFilteredAndSortedProducts({String? unit, double? minQuantity, double? maxQuantity, DateTime? startDate, DateTime? endDate, double? minCostPrice, double? maxCostPrice, double? minSellingPrice, double? maxSellingPrice, required String sortColumn, required bool ascending,}) async {
    try {
      // Boshlang‘ich so‘rov
      var query = _suPaBase
          .from('products')
          .select('id, name, category_id, cost_price, selling_price, quantity, unit_id, units(name), created_at, created_by, users!products_created_by_fkey(full_name), batches(id, batch_number, cost_price, quantity)');

      // Filtrlarni ketma-ket qo‘llash
      if (unit != null && unit.isNotEmpty) {
        query = query.eq('units.name', unit);
      }
      if (minQuantity != null) {
        query = query.gte('quantity', minQuantity);
      }
      if (maxQuantity != null) {
        query = query.lte('quantity', maxQuantity);
      }
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      if (minCostPrice != null) {
        query = query.gte('cost_price', minCostPrice);
      }
      if (maxCostPrice != null) {
        query = query.lte('cost_price', maxCostPrice);
      }
      if (minSellingPrice != null) {
        query = query.gte('selling_price', minSellingPrice);
      }
      if (maxSellingPrice != null) {
        query = query.lte('selling_price', maxSellingPrice);
      }

      // Tartiblashni oxirida qo‘llash
      final sortedQuery = query.order(sortColumn, ascending: ascending);

      final response = await sortedQuery;
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Mahsulotlarni filtrlab olishda xato: $e');
    }
  }

  // Mahsulot qo‘shish
  Future<void> addProduct(String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    try {
      await _suPaBase.from('products').insert({
        'name': name,
        'category_id': categoryId,
        'cost_price': costPrice,
        'selling_price': sellingPrice ?? 0.0,
        'quantity': quantity ?? 0.0,
        'unit_id': unitId,
        'created_by': _suPaBase.auth.currentUser?.id,
      });
      print('Mahsulot qo‘shildi, trigger batches ga qo‘shdi');
    } catch (e) {
      print('Xato yuz berdi: $e');
      throw Exception('Mahsulot qo‘shishda xato: $e');
    }
  }

  // Mahsulotni tahrirlash
  Future<void> editProduct(String id, String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    print('EditProduct: id=$id, name=$name, category_id=$categoryId, cost_price=$costPrice, unit_id=$unitId, selling_price=$sellingPrice, quantity=$quantity');
    try {
      final updateData = {
        'name': name,
        'category_id': categoryId,
        'cost_price': costPrice,
        'unit_id': unitId,
      };
      if (sellingPrice != null) updateData['selling_price'] = sellingPrice;
      if (quantity != null) updateData['quantity'] = quantity;
      final response = await _suPaBase.from('products').update(updateData).eq('id', id);
      print('Update response: $response');
      print('Mahsulot yangilandi, trigger batches miqdorini yangiladi');
    } catch (e) {
      print('Xato yuz berdi: $e');
      throw Exception('Mahsulotni tahrirlashda xato: $e');
    }
  }

  // Mahsulotni o‘chirish
  Future<void> deleteProduct(String id) async {
    try {
      await _suPaBase.from('products').delete().eq('id', id);
    } catch (e) {
      print('Xato yuz berdi: $e');
      throw Exception('Mahsulotni o‘chirishda xato: $e');
    }
  }

  Future<Map<String, dynamic>> getWarehouseStats() async {
    try {
      // Umumiy tovarlar soni va qiymatini olish
      final productsResponse = await _suPaBase
          .from('products')
          .select('quantity, cost_price, selling_price, category_id, categories(name)')
          .order('created_at', ascending: false);

      // Statistikani hisoblash
      double totalQuantity = 0.0;
      double totalCostValue = 0.0;
      double totalSellingValue = 0.0;
      Map<String, double> categoryDistribution = {};

      for (var product in productsResponse) {
        totalQuantity += product['quantity'] ?? 0.0;
        totalCostValue += (product['cost_price'] ?? 0.0) * (product['quantity'] ?? 0.0);
        totalSellingValue += (product['selling_price'] ?? 0.0) * (product['quantity'] ?? 0.0);

        String categoryName = product['categories']['name'] ?? 'Noma’lum';
        categoryDistribution[categoryName] =
            (categoryDistribution[categoryName] ?? 0.0) + (product['quantity'] ?? 0.0);
      }

      return {
        'total_quantity': totalQuantity,
        'total_cost_value': totalCostValue,
        'total_selling_value': totalSellingValue,
        'category_distribution': categoryDistribution,
      };
    } catch (e) {
      throw Exception('Statistikani olishda xato: $e');
    }
  }

  // Sotilgan tovarlarni olish
  Future<List<dynamic>> getSoldItems() async {
    try {
      final response = await _suPaBase
          .from('sold_items')
          .select('id, quantity, selling_price, sale_date, product_id, products(name), seller_id, users!seller_id(full_name)')
          .order('sale_date', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Sotilgan tovarlarni olishda xato: $e');
    }
  }

  // Kirish (Sign In)
  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      final AuthResponse responses = await _suPaBase.auth.signInWithPassword(email: email, password: password);
      if (responses.user != null) {
        final userId = responses.user!.id;
        final userData = await _suPaBase.from('users').select('full_name').eq('id', userId).maybeSingle();
        if (userData != null && userData['full_name'] != null) {
          controller.fullName.value = userData['full_name'] as String;
        } else {
          controller.fullName.value = 'Noma’lum';
        }
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      throw Exception('Kirishda xato: $e');
    }
  }

  // Tizimdan chiqish
  Future<void> signOut() async {
    await _suPaBase.auth.signOut();
  }
}