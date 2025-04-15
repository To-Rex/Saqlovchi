import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'get_controller.dart';


class ApiService {
  // Supabase mijozini olish
  final SupabaseClient _supabase = Supabase.instance.client;
  GetController get controller => Get.find<GetController>();

  // Xatolarni boshqarish
  void _handleError(dynamic error) {
    throw Exception('Xato: $error');
  }

  // Kirish (Sign In)
  Future<void> signIn(context, String email, String password) async {
    try {
      final AuthResponse responses = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (responses.user != null) {
        final userId = responses.user!.id;
        final userData = await _supabase.from('users').select('full_name').eq('id', userId).maybeSingle();
        if (userData != null && userData['full_name'] != null) {
          controller.fullName.value = userData['full_name'] as String;
        } else {
          controller.fullName.value = 'Noma’lum';
        }
        controller.fetchInitialData();
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      throw Exception('Kirishda xato: $e');
    }
  }

  // Tizimdan chiqish
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String> checkUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (response != null && response['role'] != null) {
        print('Users jadvalidan olingan rol: ${response['role']}');
        return response['role'] as String;
      }
      print('Foydalanuvchi roli topilmadi, standart qiymat: seller');
      return 'seller';
    } catch (e) {
      print('Foydalanuvchi rolini tekshirishda xato: $e');
      return 'seller';
    }
  }

  // GET: Birliklarni olish
  Future<List<dynamic>> getUnits() async {
    try {
      final response = await _supabase.from('units').select('id, name, description, created_at, created_by');
      return response as List<dynamic>;
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }

  // GET: Kategoriyalarni olish
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // GET: Mahsulotlarni olish
  Future<List<dynamic>> getProduct() async {
    try {
      final response = await _supabase.from('products').select('*, categories(name), units(name)');
      print('Mahsulotlar: $response');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _supabase.from('products').select('''
        id, name, category_id, unit_id, description, created_by, created_at,
        categories!inner(name),
        units!inner(name),
        batches(id, batch_number, quantity, cost_price, selling_price)
      ''');
      print('Olingan mahsulotlar: ${response.length} ta');
      for (var product in response) {
        print('Mahsulot: id=${product['id']}, name=${product['name']}, '
            'batches=${product['batches']?.toString() ?? 'bo‘sh'}');
      }
      return response as List<dynamic>;
    } catch (e) {
      print('Mahsulotlarni olishda xato: $e');
      return [];
    }
  }

  // GET: Partiyalarni olish
  Future<List<dynamic>> getBatches() async {
    try {
      final response = await _supabase.from('batches').select('*, products(name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // GET: Mahsulot uchun partiyalarni olish
  Future<List<dynamic>> getBatchesForProduct(int productId) async {
    try {
      final response = await _supabase
          .from('batches')
          .select('id, batch_number, quantity, cost_price, selling_price')
          .eq('product_id', productId)
          .gt('quantity', 0)
          .order('received_date', ascending: false);
      print('Mahsulot uchun partiyalar (product_id=$productId): ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Mahsulot uchun partiyalarni olishda xato: $e');
      return [];
    }
  }

  // GET: Mijozlarni olish
  Future<List<dynamic>> getCustomers() async {
    try {
      final response = await _supabase.from('customers').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // GET: Sotuvlarni olish
  Future<List<dynamic>> getSales() async {
    try {
      final response = await _supabase
          .from('sales')
          .select('*, customers(full_name), users(full_name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // GET: Oxirgi sotuvlarni olish
  Future<List<dynamic>> getRecentSales({required int limit}) async {
    try {
      final response = await _supabase
          .from('sales')
          .select('''
      id, total_amount, discount_amount, paid_amount, sale_date, comments, sale_type,
      customers(full_name),
      sale_items(id, quantity, unit_price, batches(id, batch_number, product_id, products(name)))
    ''')
          .order('sale_date', ascending: false)
          .limit(limit);
      print('Oxirgi sotuvlar: ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Oxirgi sotuvlarni olishda xato: $e');
      return [];
    }
  }

  // GET: Sotuv elementlarini olish (saleId ixtiyoriy)
  Future<List<dynamic>> getSaleItems({int? saleId}) async {
    try {
      var query = _supabase
          .from('sale_items')
          .select('*, batches(batch_number, product_id, products(name))');

      if (saleId != null) {
        query = query.eq('sale_id', saleId);
      }

      final response = await query;
      print('Sotuv elementlari (sale_id=${saleId ?? 'barchasi'}): ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Sotuv elementlarini olishda xato: $e');
      return [];
    }
  }

  // GET: Tranzaksiyalarni olish
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _supabase.from('transactions').select('*, sales(id), customers(full_name), users(full_name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // GET: Foydalanuvchilarni olish
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _supabase.from('users').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<List<dynamic>> getDebtWithDiscountReport() async {
    try {
      final response = await _supabase
          .from('sales')
          .select('*, customers(full_name)')
          .eq('sale_type', 'debt_with_discount');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  Future<List<dynamic>> getPremiumSales() async {
    try {
      final response = await _supabase.rpc('get_premium_sales').select();
      print('Premium sotuvlar: ${response.length} ta');
      return response;
    } catch (e) {
      print('Premium sotuvlarni olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

  // POST: Birlik qo‘shish
  Future<Map<String, dynamic>> addUnit({required String name, String? description, required String createdBy}) async {
    try {
      final response = await _supabase.from('units').insert({
        'name': name,
        'description': description,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Kategoriya qo‘shish
  Future<Map<String, dynamic>> addCategory({required String name, String? description, required String createdBy}) async {
    try {
      final response = await _supabase.from('categories').insert({
        'name': name,
        'description': description,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Mahsulot qo‘shish
  Future<Map<String, dynamic>> addProduct({required String name, required int categoryId, required int unitId, String? description, required String createdBy}) async {
    print('Mahsulot qo‘shish boshlandi: name=$name, category_id=$categoryId, '
        'unit_id=$unitId, description=$description, created_by=$createdBy');
    try {
      if (name.isEmpty) {
        print('Xato: Mahsulot nomi bo‘sh');
        return {};
      }
      if (categoryId <= 0) {
        print('Xato: Noto‘g‘ri category_id: $categoryId');
        return {};
      }
      if (unitId <= 0) {
        print('Xato: Noto‘g‘ri unit_id: $unitId');
        return {};
      }
      if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false)
          .hasMatch(createdBy)) {
        print('Xato: Noto‘g‘ri UUID formati created_by: $createdBy');
        return {};
      }

      final categoryCheck = await _supabase.from('categories').select('id').eq('id', categoryId).maybeSingle();
      if (categoryCheck == null) {
        print('Xato: Kategoriya topilmadi: id=$categoryId');
        return {};
      }
      final unitCheck = await _supabase.from('units').select('id').eq('id', unitId).maybeSingle();
      if (unitCheck == null) {
        print('Xato: Birlik topilmadi: id=$unitId');
        return {};
      }

      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != createdBy) {
        print('Xato: created_by ($createdBy) joriy foydalanuvchi ID’siga ($currentUserId) mos kelmaydi');
        return {};
      }

      final response = await _supabase.from('products').insert({
        'name': name,
        'category_id': categoryId,
        'unit_id': unitId,
        'description': description,
        'created_by': createdBy,
      }).select('id, name, category_id, unit_id, description, created_by, created_at').single();

      print('Mahsulot muvaffaqiyatli qo‘shildi: $response');
      return response;
    } catch (e) {
      print('Mahsulot qo‘shishda xato yuz berdi: $e');
      return {};
    }
  }

  // POST: Partiya qo‘shish
  Future<Map<String, dynamic>> addBatch({
    required int productId,
    required String batchNumber,
    required int quantity,
    required double costPrice,
    required double sellingPrice,
    String? comments,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.from('batches').insert({
        'product_id': productId,
        'batch_number': batchNumber,
        'quantity': quantity,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'comments': comments,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Mijoz qo‘shish
  Future<Map<String, dynamic>> addCustomer({
    required String fullName,
    String? phoneNumber,
    String? address,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.from('customers').insert({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Sotuv qo‘shish
  Future<Map<String, dynamic>> addSale({
    required String saleType,
    int? customerId,
    required double totalAmount,
    double? discountAmount,
    double? paidAmount,
    String? comments,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.from('sales').insert({
        'sale_type': saleType,
        'customer_id': customerId,
        'total_amount': totalAmount,
        'discount_amount': discountAmount ?? 0,
        'paid_amount': paidAmount ?? 0,
        'comments': comments,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Sotuv elementi qo‘shish
  Future<Map<String, dynamic>> addSaleItem({
    required int saleId,
    required int batchId,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final response = await _supabase.from('sale_items').insert({
        'sale_id': saleId,
        'batch_id': batchId,
        'quantity': quantity,
        'unit_price': unitPrice,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // POST: Tranzaksiya qo‘shish
  Future<Map<String, dynamic>> addTransaction({
    required String transactionType,
    required double amount,
    int? saleId,
    int? customerId,
    String? comments,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.from('transactions').insert({
        'transaction_type': transactionType,
        'amount': amount,
        'sale_id': saleId,
        'customer_id': customerId,
        'comments': comments,
        'created_by': createdBy,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // PUT: Birlikni yangilash
  Future<Map<String, dynamic>> updateUnit({required int id, required String name, String? description}) async {
    try {
      final response = await _supabase.from('units').update({
        'name': name,
        'description': description,
      }).eq('id', id).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // PUT: Kategoriyani yangilash
  Future<Map<String, dynamic>> updateCategory({required int id, required String name, String? description}) async {
    try {
      final response = await _supabase.from('categories').update({
        'name': name,
        'description': description,
      }).eq('id', id).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // PUT: Mahsulotni yangilash
  Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required int unitId,
    String? description,
  }) async {
    try {
      final response = await _supabase.from('products').update({
        'name': name,
        'category_id': categoryId,
        'unit_id': unitId,
        'description': description,
      }).eq('id', id).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // PUT: Partiyani yangilash
  Future<Map<String, dynamic>> updateBatch({
    required int id,
    required int quantity,
    required double costPrice,
    required double sellingPrice,
    String? comments,
  }) async {
    try {
      final response = await _supabase.from('batches').update({
        'quantity': quantity,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'comments': comments,
      }).eq('id', id).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // PUT: Mijozni yangilash
  Future<Map<String, dynamic>> updateCustomer({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final response = await _supabase.from('customers').update({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
      }).eq('id', id).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // DELETE: Birlikni o‘chirish
  Future<void> deleteUnit(int id) async {
    try {
      await _supabase.from('units').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Kategoriyani o‘chirish
  Future<void> deleteCategory(int id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Mahsulotni o‘chirish
  Future<void> deleteProduct(int id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Partiyani o‘chirish
  Future<void> deleteBatch(int id) async {
    try {
      await _supabase.from('batches').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Mijozni o‘chirish
  Future<void> deleteCustomer(int id) async {
    try {
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Sotuvni o‘chirish
  Future<void> deleteSale(int id) async {
    try {
      await _supabase.from('sales').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Sotuv elementini o‘chirish
  Future<void> deleteSaleItem(int id) async {
    try {
      await _supabase.from('sale_items').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE: Tranzaksiyani o‘chirish
  Future<void> deleteTransaction(int id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Validatsiya: Partiya raqamini tekshirish
  Future<bool> checkBatchNumber(int productId, String batchNumber) async {
    try {
      final response = await _supabase
          .from('batches')
          .select('id')
          .eq('product_id', productId)
          .eq('batch_number', batchNumber);
      return response.isEmpty;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Hisobot: Qarzlar bo‘yicha
  Future<List<dynamic>> getDebtReport() async {
    try {
      final response = await _supabase
          .from('sales')
          .select('*, customers(full_name)')
          .eq('sale_type', 'debt');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Hisobot: Eng ko‘p sotilgan mahsulotlar
  Future<List<dynamic>> getTopProducts() async {
    try {
      final response = await _supabase
          .from('sale_items')
          .select('batches(product_id, products(name)), quantity')
          .order('quantity', ascending: false)
          .limit(10);
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }
}