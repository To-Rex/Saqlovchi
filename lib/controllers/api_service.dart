import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'get_controller.dart';
import 'package:uuid/uuid.dart';


class ApiService {
  final _suPaBase = Supabase.instance.client;
  final Uuid _uuid = Uuid();
  GetController get controller => Get.find<GetController>();

  String? _getCurrentUserId() {
    final userId = _suPaBase.auth.currentUser?.id;
    if (userId == null) throw Exception('Foydalanuvchi tizimga kirmagan');
    return userId;
  }

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

  Future<List<dynamic>> getFilteredAndSortedProducts({String? unit, double? minQuantity, double? maxQuantity, DateTime? startDate, DateTime? endDate, double? minCostPrice, double? maxCostPrice, double? minSellingPrice, double? maxSellingPrice, required String sortColumn, required bool ascending}) async {
    try {
      var query = _suPaBase.from('products').select('id, name, category_id, cost_price, selling_price, quantity, unit_id, units(name), created_at, created_by, users!products_created_by_fkey(full_name), batches(id, batch_number, cost_price, quantity)');

      if (unit != null && unit.isNotEmpty) query = query.eq('units.name', unit);
      if (minQuantity != null) query = query.gte('quantity', minQuantity);
      if (maxQuantity != null) query = query.lte('quantity', maxQuantity);
      if (startDate != null) query = query.gte('created_at', startDate.toIso8601String());
      if (endDate != null) query = query.lte('created_at', endDate.toIso8601String());
      if (minCostPrice != null) query = query.gte('cost_price', minCostPrice);
      if (maxCostPrice != null) query = query.lte('cost_price', maxCostPrice);
      if (minSellingPrice != null) query = query.gte('selling_price', minSellingPrice);
      if (maxSellingPrice != null) query = query.lte('selling_price', maxSellingPrice);

      // SortColumn mavjudligini tekshirish
      final validColumns = ['name', 'quantity', 'cost_price', 'selling_price', 'created_at'];
      if (!validColumns.contains(sortColumn)) {
        throw Exception('Noto‘g‘ri tartiblash ustuni: $sortColumn');
      }

      final response = await query.order(sortColumn, ascending: ascending);
      return response;
    } catch (e) {
      Get.snackbar('Xatolik', 'Mahsulotlarni filtrlab olishda xato: $e');
      rethrow;
    }
  }

  // Mahsulot qo‘shish (validatsiya qo‘shildi)
  Future<void> addProduct(String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    try {
      if (name.isEmpty) throw Exception('Mahsulot nomi bo‘sh bo‘lmasligi kerak');
      if (costPrice < 0) throw Exception('Xarid narxi manfiy bo‘lmasligi kerak');
      if (sellingPrice != null && sellingPrice < 0) throw Exception('Sotuv narxi manfiy bo‘lmasligi kerak');
      if (quantity != null && quantity < 0) throw Exception('Miqdor manfiy bo‘lmasligi kerak');

      await _suPaBase.from('products').insert({
        'name': name,
        'category_id': categoryId,
        'cost_price': costPrice,
        'selling_price': sellingPrice ?? 0.0,
        'quantity': quantity ?? 0.0,
        'unit_id': unitId,
        'created_by': _getCurrentUserId(),
      });
      Get.snackbar('Muvaffaqiyat', 'Mahsulot qo‘shildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Mahsulot qo‘shishda xato: $e');
      rethrow;
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

  Future<void> returnProduct(String saleId, double quantity, String reason) async {
    try {
      await _suPaBase.from('sales').update({'status': 'returned'}).eq('id', saleId);
      await _suPaBase.from('stock_transactions').insert({
        'batch_id': (await _suPaBase.from('sold_items').select('batch_id').eq('sale_id', saleId).single())['batch_id'],
        'quantity': quantity,
        'transaction_date': DateTime.now().toIso8601String(),
        'notes': reason,
        'transaction_type': 'in',
        'source': 'Qaytarish',
        'created_by': _getCurrentUserId(),
      });
      Get.snackbar('Muvaffaqiyat', 'Tovar qaytarildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Tovar qaytarishda xato: $e');
      rethrow;
    }
  }

  Future<void> sellProduct({
    required String productId,
    required double quantity,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    bool isCredit = false,
    double? creditAmount,
    DateTime? creditDueDate,
    double discount = 0.0,
  }) async {
    try {
      if (quantity <= 0) throw Exception('Miqdor 0 dan katta bo‘lishi kerak');
      if (isCredit && (creditAmount == null || creditDueDate == null)) {
        throw Exception('Kredit uchun summa va muddatni kiriting');
      }
      if (isCredit && customerId == null && (customerName == null || customerName.isEmpty)) {
        throw Exception('Mijozni tanlang yoki yangi mijoz ismini kiriting');
      }
      if (discount < 0) throw Exception('Chegirma manfiy bo‘lmasligi kerak');

      // Mahsulot ma’lumotlari
      final productResponse = await _suPaBase
          .from('products')
          .select('selling_price, cost_price')
          .eq('id', productId)
          .maybeSingle(); // .single() o‘rniga .maybeSingle()
      if (productResponse == null) throw Exception('Mahsulot topilmadi');
      final baseSellingPrice = (productResponse['selling_price'] as num).toDouble();
      final totalPriceWithoutDiscount = baseSellingPrice * quantity;
      final finalSellingPrice = totalPriceWithoutDiscount - discount;

      // Zaxira tekshiruvi
      final stockResponse = await _suPaBase
          .from('stock')
          .select('quantity')
          .eq('product_id', productId)
          .maybeSingle();
      if (stockResponse == null) throw Exception('Mahsulot uchun zaxira topilmadi');
      final availableQuantity = stockResponse['quantity'] as double? ?? 0.0;
      if (availableQuantity < quantity) {
        throw Exception('Omborda yetarli mahsulot yo‘q: $availableQuantity');
      }

      // Batch ID
      final batchResponse = await _suPaBase
          .from('batches')
          .select('id')
          .eq('product_id', productId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();
      if (batchResponse == null) throw Exception('Mahsulot uchun batch topilmadi');
      final batchId = batchResponse['id'] as String;

      // Sotilgan mahsulot
      final soldItemResponse = await _suPaBase.from('sold_items').insert({
        'product_id': productId,
        'batch_id': batchId,
        'quantity': quantity,
        'selling_price': finalSellingPrice / quantity,
        'sale_date': DateTime.now().toIso8601String(),
        'created_by': _getCurrentUserId(),
      }).select('id').single();

      // Sotuv
      final saleId = _uuid.v4();
      await _suPaBase.from('sales').insert({
        'id': saleId,
        'sold_item_id': soldItemResponse['id'],
        'customer_id': customerId,
        'is_credit': isCredit,
        'credit_amount': isCredit ? creditAmount : 0.0,
        'credit_due_date': isCredit ? creditDueDate?.toIso8601String() : null,
        'created_by': _getCurrentUserId(),
        'status': 'completed',
      });

      // Yangi mijoz qo‘shish
      if (customerId == null && customerName != null && customerName.isNotEmpty) {
        final newCustomerResponse = await _suPaBase.from('customers').insert({
          'full_name': customerName,
          'phone': customerPhone,
          'address': customerAddress,
          'created_by': _getCurrentUserId(),
          'created_at': DateTime.now().toIso8601String(),
        }).select('id').single();
        customerId = newCustomerResponse['id'] as String;
        await _suPaBase.from('sales').update({'customer_id': customerId}).eq('id', saleId);
      }

      // Kredit qo‘shish
      if (isCredit && creditAmount != null && creditDueDate != null && customerId != null) {
        await _suPaBase.from('credits').insert({
          'sale_id': saleId,
          'customer_id': customerId,
          'credit_amount': creditAmount,
          'due_date': creditDueDate.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Stock yangilash
      await _suPaBase
          .from('stock')
          .update({'quantity': availableQuantity - quantity, 'last_updated': DateTime.now().toIso8601String()})
          .eq('product_id', productId);

      // Stock tranzaksiyasi
      await _suPaBase.from('stock_transactions').insert({
        'batch_id': batchId,
        'quantity': quantity,
        'transaction_date': DateTime.now().toIso8601String(),
        'notes': 'Sotuv (Chegirma: $discount)',
        'product_id': productId,
        'transaction_type': 'out',
        'source': 'Sotuv',
        'created_by': _getCurrentUserId(),
      });

      Get.snackbar('Muvaffaqiyat', 'Sotuv muvaffaqiyatli amalga oshirildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Sotuvda xato: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getCustomers() async {
    try {
      final response = await _suPaBase
          .from('customers')
          .select('id, full_name, phone, address')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      Get.snackbar('Xatolik', 'Mijozlarni olishda xato: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentSoldItem({int limit = 2}) async {
    try {
      final response = await _suPaBase
          .from('sold_items')
          .select('id, quantity, selling_price, sale_date, product_id, products(name)')
          .order('sale_date', ascending: false)
          .limit(limit);
      print('Sotilgan mahsulotlar: $response');
      return response;
    } catch (e) {
      print('Xatolik: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentSoldItems({int limit = 3}) async {
    try {
      final response = await _suPaBase
          .from('sold_items')
          .select('''
          id, 
          quantity, 
          selling_price, 
          sale_date, 
          product_id, 
          products(name, selling_price), 
          sales!inner(id, is_credit, credit_amount)
        ''')
          .order('sale_date', ascending: false)
          .limit(limit);
      print('Sotilgan mahsulotlar: $response');
      return response;
    } catch (e) {
      print('Xatolik: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAllSoldItems() async {
    try {
      final response = await _suPaBase
          .from('sold_items')
          .select('''
          id, 
          quantity, 
          selling_price, 
          sale_date, 
          product_id, 
          products(name, selling_price), 
          sales!inner(id, is_credit, credit_amount)
        ''')
          .order('sale_date', ascending: false);
      print('Barcha sotilgan mahsulotlar: $response');
      return response;
    } catch (e) {
      print('Xatolik: $e');
      rethrow;
    }
  }

  Future<double> getStockQuantity(String productId) async {
    try {
      final response = await _suPaBase
          .from('stock')
          .select('quantity')
          .eq('product_id', productId)
          .maybeSingle();
      if (response == null) return 0.0;
      return (response['quantity'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Xatolik: $e');
      return 0.0;
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