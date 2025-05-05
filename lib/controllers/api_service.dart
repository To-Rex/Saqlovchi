import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'get_controller.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  GetController get controller => Get.find<GetController>();

  void _handleError(dynamic error) {
    throw Exception('Xato: $error');
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Noma’lum';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
        'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
      ];
      return '${date.year} yil ${date.day} ${months[date.month - 1]}';
    } catch (e) {
      print('Sana formatlashda xato: $e');
      return 'Noma’lum';
    }
  }

  // Foydalanuvchi kirishi
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

  // Foydalanuvchi chiqishi
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Foydalanuvchi rolini tekshirish
  Future<String> checkUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role, full_name')
          .eq('id', userId)
          .maybeSingle();
      if (response != null && response['role'] != null) {
        print('Users jadvalidan olingan rol: ${response['role']}');
        controller.role.value = response['role'] as String;
        controller.fullName.value = response['full_name'] as String;
        return response['role'] as String;
      }
      print('Foydalanuvchi roli topilmadi, standart qiymat: seller');
      return 'seller';
    } catch (e) {
      print('Foydalanuvchi rolini tekshirishda xato: $e');
      return 'seller';
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('email') // Yoki 'name', agar jadvalda ism saqlansa
          .eq('id', userId)
          .single();
      return response['email']?.toString() ?? 'Noma’lum';
    } catch (e) {
      print('Foydalanuvchi ismini olishda xato: $e');
      return 'Noma’lum';
    }
  }

  Future<Map<String, dynamic>> getCategoryDetails(int categoryId) async {
    try {
      final response = await _supabase.rpc('get_category_details', params: {'p_category_id': categoryId}).select();
      final Map<String, dynamic> result = {
        'category': null,
        'products': [],
      };

      if (response.isEmpty) {
        return result;
      }

      // Birinchi qator umumiy statistikani olish uchun ishlatiladi
      final categoryData = response.first;
      final userName = await getUserName(categoryData['created_by_uuid']?.toString() ?? '');

      result['category'] = {
        'id': categoryData['category_id']?.toInt() ?? 0,
        'name': categoryData['category_name']?.toString() ?? 'Noma’lum',
        'created_by': userName,
        'created_at': formatDate(categoryData['created_at']),
        'product_count': categoryData['product_count']?.toInt() ?? 0,
        'total_quantity': categoryData['total_quantity']?.toDouble() ?? 0.0,
      };

      // Barcha mahsulotlar ro‘yxati
      final products = response.where((p) => p['product_id'] != null).map((p) => {
        'id': p['product_id']?.toInt() ?? 0,
        'name': p['product_name']?.toString() ?? 'Noma’lum',
        'quantity': p['product_quantity']?.toDouble() ?? 0.0,
        'cost_price': p['cost_price']?.toDouble() ?? 0.0,
        'selling_price': p['selling_price']?.toDouble() ?? 0.0,
        'created_at': formatDate(p['product_created_at']),
      }).toList();

      result['products'] = products;
      print('Kategoriya detallari: $result');
      return result;
    } catch (e) {
      print('Kategoriya detallarini olishda xato: $e');
      return {'category': null, 'products': []};
    }
  }


  // Barcha foydalanuvchilarni olish
  Future<List<dynamic>> getAllUsers({String? searchQuery, String? sortOrder = 'newest'}) async {
    try {
      var query = _supabase.from('users').select('id, full_name, email, role, is_blocked, created_at');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }
      final response = await query.order('created_at', ascending: sortOrder == 'oldest');
      print('Foydalanuvchilar: ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Foydalanuvchilarni olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

  // Barcha mijozlarni olish
  Future<List<dynamic>> getAllCustomers({String? searchQuery, String? sortOrder = 'newest'}) async {
    try {
      var query = _supabase.from('customers').select('id, full_name, address, created_by, created_at, phone_number');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,address.ilike.%$searchQuery%');
      }
      final customers = await query.order('created_at', ascending: sortOrder == 'oldest');
      final customersWithDebt = [];
      for (var customer in customers) {
        final debt = await _calculateCustomerDebt(customer['id']);
        customersWithDebt.add({
          ...customer,
          'debt_amount': debt,
        });
      }
      print('Mijozlar: ${customersWithDebt.length} ta');
      return customersWithDebt;
    } catch (e) {
      print('Mijozlarni olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

  // Mijoz qarzini hisoblash
  Future<double> _calculateCustomerDebt(int customerId) async {
    try {
      final transactions = await _supabase
          .from('transactions')
          .select('transaction_type, amount')
          .eq('customer_id', customerId)
          .inFilter('transaction_type', ['debt_sale', 'debt_payment']);
      double debt = 0.0;
      for (var transaction in transactions) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        print('Tranzaksiya: ${transaction['transaction_type']}, Miqdor: $amount, Mijoz ID: $customerId');
        if (transaction['transaction_type'] == 'debt_sale') {
          debt += amount;
        } else if (transaction['transaction_type'] == 'debt_payment') {
          debt -= amount;
        }
      }
      print('Umumiy qarz (Mijoz ID: $customerId): $debt');
      return debt;
    } catch (e) {
      print('Qarzni hisoblashda xato: $e');
      return 0.0;
    }
  }

  // Mijozning qarz sotuvlarini olish
  Future<List<dynamic>> getCustomerDebtSales(int customerId) async {
    try {
      final debtSales = await _supabase
          .rpc('get_unpaid_debt_sales', params: {'p_customer_id': customerId});
      print('Qarzga sotilgan tranzaksiyalar (Mijoz ID: $customerId): ${debtSales.length} ta');
      return debtSales as List<dynamic>;
    } catch (e) {
      print('Qarzga sotilgan tranzaksiyalarni olishda xato: $e');
      return [];
    }
  }

// Barcha sotuvlar detallarini olish
  Future<List<dynamic>> getAllSalesDetails({String searchQuery = '', String status = 'all', DateTime? startDate, DateTime? endDate, String sortOrder = 'newest'}) async {
    try {
      final response = await _supabase.rpc('get_all_sales_details', params: {
        'p_search_query': searchQuery,
        'p_status': status,
        'p_start_date': startDate?.toIso8601String().replaceAll('Z', ''),
        'p_end_date': endDate?.toIso8601String().replaceAll('Z', ''),
        'p_sort_order': sortOrder,
      }).select();

      print('Sotuvlar detallari olingan: ${response.length} ta');
      return response;
    } catch (e) {
      print('Sotuvlar detallarini olishda xato: $e');
      rethrow;
    }
  }


  // Tranzaksiya qo‘shish
  Future<Map<String, dynamic>> addTransaction({required String transactionType, required double amount, int? saleId, int? customerId, String? comments, required String createdBy}) async {
    try {
      final response = await _supabase.from('transactions').insert({
        'transaction_type': transactionType,
        'amount': amount,
        'sale_id': saleId,
        'customer_id': customerId,
        'comments': comments,
        'created_by': createdBy,
      }).select().single();
      print('Tranzaksiya qo‘shildi: $transactionType, Miqdor: $amount, Mijoz ID: $customerId');
      return response;
    } catch (e) {
      print('Tranzaksiya qo‘shishda xato: $e');
      _handleError(e);
      return {};
    }
  }


  // Sotuvdagi to‘langan summarni yangilash
  Future<void> updateSalePaidAmount(int saleId, double paymentAmount) async {
    try {
      final sale = await _supabase
          .from('sales')
          .select('paid_amount')
          .eq('id', saleId)
          .single();
      final currentPaidAmount = (sale['paid_amount'] as num?)?.toDouble() ?? 0.0;
      final newPaidAmount = currentPaidAmount + paymentAmount;
      await _supabase
          .from('sales')
          .update({'paid_amount': newPaidAmount})
          .eq('id', saleId);
      print('Sales paid_amount yangilandi: Sale ID: $saleId, Yangi paid_amount: $newPaidAmount');
    } catch (e) {
      print('Sales paid_amount yangilashda xato: $e');
      _handleError(e);
    }
  }

// Mijoz qo‘shish
  Future<Map<String, dynamic>> addCustomer({required String fullName, String? phoneNumber, String? address, required String createdBy}) async {
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

  // Mijozni yangilash
  Future<Map<String, dynamic>> updateCustomer({required int id, required String fullName, String? phoneNumber, String? address}) async {
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

  // Mijozni o‘chirish
  Future<void> deleteCustomer(int id) async {
    try {
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Foydalanuvchi blok holatini o‘zgartirish
  Future<void> toggleUserBlock(String userId, bool isBlocked) async {
    try {
      await _supabase.from('users').update({'is_blocked': isBlocked}).eq('id', userId);
      print('Foydalanuvchi blok holati o‘zgartirildi: $userId, is_blocked: $isBlocked');
    } catch (e) {
      print('Foydalanuvchi blok holatini o‘zgartirishda xato: $e');
      _handleError(e);
      rethrow;
    }
  }

  // Admin rolini tekshirish
  Future<bool> isAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();
      final role = response['role'] as String?;
      return role != null && role == 'admin';
    } catch (e) {
      print('isAdmin xatosi: $e');
      return false;
    }
  }

  // Birliklarni olish
  Future<List<dynamic>> getUnits() async {
    try {
      final response = await _supabase.from('units').select('id, name, description, created_at, created_by');
      return response as List<dynamic>;
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addProductAndBatch({
    required String name,
    required int categoryId,
    required int unitId,
    required double batchQuantity,
    required double batchCostPrice,
    required double batchSellingPrice,
    required String createdBy,
    String? code,
  }) async {
    try {
      final response = await _supabase.rpc('add_product_and_batch', params: {
        'p_name': name,
        'p_category_id': categoryId,
        'p_unit_id': unitId,
        'p_quantity': batchQuantity,
        'p_cost_price': batchCostPrice,
        'p_selling_price': batchSellingPrice,
        'p_batch_number': null,
        'p_received_date': DateTime.now().toIso8601String(),
        'p_user_id': createdBy, // TEXT sifatida yuboriladi, RPC da CAST qilinadi
        'p_code': code,
      }).select().single();

      print('Mahsulot va partiya qo‘shildi: product_id=${response['product_id']}, batch_id=${response['batch_id']}');
      await _preloadStockQuantities();
      return response;
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Mahsulot/partiya qo‘shishda xato: $errorMessage');
      throw Exception(errorMessage);
    }
  }

// Mavjud mahsulotga partiya qo‘shish
  Future<Map<String, dynamic>> addBatchToExistingProduct({required int productId, required double batchQuantity, required double batchCostPrice, required double batchSellingPrice, required String createdBy}) async {
    try {
      final response = await _supabase.rpc('add_batch_to_existing_product', params: {
        'p_product_id': productId,
        'p_quantity': batchQuantity,
        'p_cost_price': batchCostPrice,
        'p_selling_price': batchSellingPrice,
        'p_batch_number': null,
        'p_received_date': DateTime.now().toIso8601String(),
        'p_user_id': createdBy,
      }).select().single();

      print('Partiya qo‘shildi: batch_id=${response['batch_id']}, product_id=$productId, quantity=$batchQuantity');
      await _preloadStockQuantities();
      return response;
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Partiya qo‘shishda xato: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  // Kategoriyalarni olish
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Mahsulotlarni olish
  Future<List<dynamic>> getProduct() async {
    try {
      final response = await _supabase.from('products').select('id, name, code, categories(name), units(name)');
      print('Mahsulotlar: $response');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }



  Future<List<dynamic>> getProductsWithStock() async {
    try {
      final productResponse = await _supabase.rpc('get_products_with_stock').select();
      final batchResponse = await _supabase
          .from('batches')
          .select('id, product_id, batch_number, quantity, cost_price, selling_price, received_date');

      final batchMap = <String, List<Map<String, dynamic>>>{};
      for (var batch in batchResponse) {
        final productId = batch['product_id'].toString();
        if (!batchMap.containsKey(productId)) {
          batchMap[productId] = [];
        }
        batchMap[productId]!.add({
          'id': batch['id'],
          'batch_number': batch['batch_number'],
          'quantity': batch['quantity'],
          'cost_price': batch['cost_price'],
          'selling_price': batch['selling_price'],
          'received_date': batch['received_date'],
        });
      }

      final productsWithStock = productResponse.map((product) {
        final productId = product['id'].toString();
        return {
          'id': product['id'],
          'name': product['name'],
          'code': product['code'],
          'category_id': product['category_id'],
          'unit_id': product['unit_id'],
          'description': product['description'],
          'created_by': product['created_by']?.toString(),
          'created_at': product['created_at'],
          'categories': {'name': product['category_name']},
          'units': {'name': product['unit_name']},
          'stock_quantity': product['stock_quantity']?.toDouble() ?? 0.0,
          'initial_quantity': product['initial_quantity']?.toDouble() ?? 0.0,
          'batches': batchMap[productId] ?? [],
        };
      }).toList();

      print('Olingan mahsulotlar (qoldiq bilan): ${productsWithStock.length} ta, mahsulotlar: ${productsWithStock.map((p) => {'id': p['id'], 'name': p['name'], 'code': p['code'], 'stock_quantity': p['stock_quantity'], 'initial_quantity': p['initial_quantity'], 'batches': p['batches']}).toList()}');
      return productsWithStock;
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Mahsulotlarni olishda xato: $errorMessage');
      return [];
    }
  }

// Partiyalarni olish (products bilan aniq bog‘lanish)
  Future<List<dynamic>> getBatches() async {
    try {
      final response = await _supabase
          .from('batches')
          .select('id, product_id, quantity, cost_price, selling_price, received_date, products!batches_product_id_fkey(id, name)')
          .order('received_date', ascending: true);
      print('Partiyalar olingan: ${response.length} ta');
      return response;
    } catch (e) {
      print('Partiyalarni olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

  // Mahsulot uchun partiyalarni olish
  Future<List<dynamic>> getBatchesForProduct(int productId) async {
    try {
      final response = await _supabase
          .from('batches')
          .select('id, batch_number, quantity, cost_price, selling_price, received_date')
          .eq('product_id', productId)
          .gt('quantity', 0)
          .order('received_date', ascending: true); // FIFO uchun eng eski birinchi
      print('Mahsulot uchun partiyalar (product_id=$productId): ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Mahsulot uchun partiyalarni olishda xato: $e');
      Get.snackbar('Xatolik', 'Partiyalarni olishda xato: $e');
      return [];
    }
  }

  // Mijozlarni olish
  Future<List<dynamic>> getCustomers() async {
    try {
      final response = await _supabase.from('customers').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Sotuvlarni olish
  Future<List<dynamic>> getSales() async {
    try {
      final response = await _supabase
          .from('sales')
          .select('''
          id, total_amount, discount_amount, paid_amount, sale_date, comments, sale_type,
          customers(full_name),
          sale_items(id, quantity, unit_price, batches(id, batch_number, product_id, cost_price, selling_price, products!inner(id, name)))
        ''')
          .order('sale_date', ascending: false);
      print('Barcha sotuvlar: ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Sotuvlarni olishda xato: $e');
      return [];
    }
  }

// Oxirgi sotuvlarni olish
  Future<List<dynamic>> getRecentSales({required int limit}) async {
    try {
      final response = await _supabase.from('sales').select('''
      id, sale_type, total_amount, discount_amount, paid_amount, sale_date, customer_id,
      customers(full_name),
      sale_items(*, batches(batch_number, products!batches_product_id_fkey(name)))
    ''').order('sale_date', ascending: false).limit(limit);
      print('Oxirgi sotuvlar: ${response.length} ta');
      return response;
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Oxirgi sotuvlarni olishda xato: $errorMessage');
      return [];
    }
  }

// Sotuv elementlarini olish
  Future<List<dynamic>> getSaleItems({int? saleId}) async {
    try {
      var query = _supabase
          .from('sale_items')
          .select('*, batches(batch_number, product_id, products!batches_product_id_fkey(name))');
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

  // Ombor statistikasini olish
  Future<Map<String, dynamic>> getWarehouseStats() async {
    try {
      final products = await _supabase.from('products').select('id').count();
      final outOfStock = await _supabase
          .from('stock')
          .select('product_id')
          .eq('quantity', 0)
          .count();
      final debtSales = await _supabase
          .from('sales')
          .select('id')
          .eq('sale_type', 'debt')
          .count();
      final discountSales = await _supabase
          .from('sales')
          .select('id')
          .eq('sale_type', 'discount')
          .count();
      final debtWithDiscountSales = await _supabase
          .from('sales')
          .select('id')
          .eq('sale_type', 'debt_with_discount')
          .count();

      return {
        'total_products': products.count,
        'out_of_stock': outOfStock.count,
        'debt_sales': debtSales.count,
        'discount_sales': discountSales.count,
        'debt_with_discount_sales': debtWithDiscountSales.count,
      };
    } catch (e) {
      print('Statistikani olishda xato: $e');
      Get.snackbar('Xatolik', 'Statistikani olishda xato: $e');
      return {
        'total_products': 0,
        'out_of_stock': 0,
        'debt_sales': 0,
        'discount_sales': 0,
        'debt_with_discount_sales': 0,
      };
    }
  }

  Future<Map<String, Map<String, dynamic>>> getCategoryStats() async {
    try {
      final response = await _supabase.rpc('get_category_stats').select();
      final Map<String, Map<String, dynamic>> stats = {};
      for (var category in response) {
        final userName = await getUserName(category['created_by_uuid']?.toString() ?? '');
        stats[category['category_id'].toString()] = {
          'name': category['category_name']?.toString() ?? 'Noma’lum',
          'created_by': userName,
          'created_at': formatDate(category['created_at']),
          'product_count': category['product_count']?.toInt() ?? 0,
          'total_quantity': category['total_quantity']?.toDouble() ?? 0.0,
        };
      }
      print('Statistika: $stats');
      return stats;
    } catch (e) {
      print('Kategoriya statistikasini olishda xato: $e');
      return {};
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _supabase.from('categories').delete().eq('id', categoryId);
    } catch (e) {
      throw Exception('Kategoriyani o‘chirishda xato: $e');
    }
  }


  // Tranzaksiyalarni olish
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _supabase.from('transactions').select('*, sales(id), customers(full_name), users(full_name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Foydalanuvchilarni olish
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _supabase.from('users').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Qarz hisoboti
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

  // Chegirmali qarz hisoboti
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

  // Premium sotuvlarni olish
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

  // Eng ko‘p sotilgan mahsulotlar
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

  // Barcha tranzaksiyalarni olish
  Future<List<dynamic>> getAllTransactions({String? searchQuery, String? transactionType, DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabase.from('transactions').select('''
        id, transaction_type, amount, sale_id, customer_id, comments, created_by, created_at,
        sales(sale_type, total_amount, paid_amount, discount_amount),
        customers(full_name)
      ''');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'comments.ilike.%$searchQuery%,and(customers.full_name.ilike.%$searchQuery%)',
          referencedTable: 'customers',
        );
      }
      if (transactionType != null && transactionType != 'all') {
        query = query.eq('transaction_type', transactionType);
      }
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      final response = await query.order('created_at', ascending: false, nullsFirst: false);
      print('Tranzaksiyalar: ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Tranzaksiyalarni olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

  // Tranzaksiya statistikasi
  Future<Map<String, dynamic>> getTransactionStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabase.from('transactions').select('transaction_type, amount');
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      final response = await query;
      double income = 0.0;
      double expense = 0.0;
      for (var transaction in response) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final type = transaction['transaction_type'] as String;
        if (['payment', 'debt_payment', 'income'].contains(type)) {
          income += amount;
        } else if (['debt_sale', 'return', 'expense'].contains(type)) {
          expense += amount;
        }
      }
      final profit = income - expense;
      return {
        'income': income,
        'expense': expense,
        'profit': profit,
      };
    } catch (e) {
      print('Statistikani olishda xato: $e');
      _handleError(e);
      return {'income': 0.0, 'expense': 0.0, 'profit': 0.0};
    }
  }

  // Tranzaksiya turlari statistikasi
  Future<Map<String, Map<String, dynamic>>> getTransactionTypeStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabase.from('transactions').select('transaction_type, amount');
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      final response = await query;
      Map<String, Map<String, dynamic>> typeStats = {
        'debt_sale': {'total': 0.0, 'count': 0},
        'payment': {'total': 0.0, 'count': 0},
        'debt_payment': {'total': 0.0, 'count': 0},
        'return': {'total': 0.0, 'count': 0},
        'income': {'total': 0.0, 'count': 0},
        'expense': {'total': 0.0, 'count': 0},
      };
      for (var transaction in response) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final type = transaction['transaction_type'] as String;
        if (typeStats.containsKey(type)) {
          typeStats[type]!['total'] = typeStats[type]!['total'] + amount;
          typeStats[type]!['count'] = typeStats[type]!['count'] + 1;
        }
      }
      return typeStats;
    } catch (e) {
      print('Tranzaksiya turlari statistikasini olishda xato: $e');
      _handleError(e);
      return {
        'debt_sale': {'total': 0.0, 'count': 0},
        'payment': {'total': 0.0, 'count': 0},
        'debt_payment': {'total': 0.0, 'count': 0},
        'return': {'total': 0.0, 'count': 0},
        'income': {'total': 0.0, 'count': 0},
        'expense': {'total': 0.0, 'count': 0},
      };
    }
  }

  // Birlik qo‘shish
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

  // Kategoriya qo‘shish
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

  // Yangilangan addProductWithBatch funksiyasi
  Future<Map<String, dynamic>> addProductWithBatch({required String name, String? categoryId, double? costPrice, String? unit, required double batchQuantity, required double batchCostPrice, required double batchSellingPrice, String? supplier, String? userId, String? code }) async {
    try {
      final response = await _supabase.rpc('add_product_with_batch', params: {
        'p_name': name,
        'p_category_id': categoryId,
        'p_cost_price': costPrice ?? batchCostPrice,
        'p_unit': unit,
        'p_batch_number': null, // SQL avtomatik generatsiya qiladi
        'p_batch_quantity': batchQuantity,
        'p_batch_cost_price': batchCostPrice,
        'p_batch_selling_price': batchSellingPrice,
        'p_received_date': DateTime.now().toIso8601String(),
        'p_expiry_date': null,
        'p_supplier': supplier,
        'p_user_id': userId,
        'p_code': code, // code parametri qo‘shildi
      }).select().single();

      print('Mahsulot va partiya qo‘shildi: product_id=${response['product_id']}, batch_id=${response['batch_id']}');
      await _preloadStockQuantities();
      return response;
    } catch (e) {
      print('Mahsulot/partiya qo‘shishda xato: $e');
      rethrow;
    }
  }


  // Mahsulot qo‘shish (avtomatik partiya bilan)
  Future<Map<String, dynamic>> addProduct({required String name, required int categoryId, required int unitId, String? description, String? code, required String createdBy, required String batchNumber, required double batchQuantity, required double batchCostPrice, required double batchSellingPrice, String? supplier}) async {
    print('Mahsulot qo‘shish boshlandi: name=$name, category_id=$categoryId, '
        'unit_id=$unitId, batch_number=$batchNumber, batch_quantity=$batchQuantity, code=$code');
    try {
      if (name.isEmpty) {
        print('Xato: Mahsulot nomi bo‘sh');
        throw Exception('Mahsulot nomi bo‘sh bo‘lishi mumkin emas');
      }
      if (categoryId <= 0) {
        print('Xato: Noto‘g‘ri category_id: $categoryId');
        throw Exception('Noto‘g‘ri category_id');
      }
      if (unitId <= 0) {
        print('Xato: Noto‘g‘ri unit_id: $unitId');
        throw Exception('Noto‘g‘ri unit_id');
      }
      if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false)
          .hasMatch(createdBy)) {
        print('Xato: Noto‘g‘ri UUID formati created_by: $createdBy');
        throw Exception('Noto‘g‘ri UUID formati created_by');
      }

      final categoryCheck = await _supabase.from('categories').select('id').eq('id', categoryId).maybeSingle();
      if (categoryCheck == null) {
        print('Xato: Kategoriya topilmadi: id=$categoryId');
        throw Exception('Kategoriya topilmadi');
      }
      final unitCheck = await _supabase.from('units').select('id').eq('id', unitId).maybeSingle();
      if (unitCheck == null) {
        print('Xato: Birlik topilmadi: id=$unitId');
        throw Exception('Birlik topilmadi');
      }

      final response = await addProductWithBatch(
        name: name,
        categoryId: categoryId.toString(),
        costPrice: batchCostPrice,
        unit: null,
        batchQuantity: batchQuantity,
        batchCostPrice: batchCostPrice,
        batchSellingPrice: batchSellingPrice,
        supplier: supplier,
        userId: createdBy,
        code: code, // code parametri qo‘shildi
      );

      print('Mahsulot muvaffaqiyatli qo‘shildi: $response');
      return response;
    } catch (e) {
      print('Mahsulot qo‘shishda xato yuz berdi: $e');
      rethrow;
    }
  }


  // Partiya qo‘shish
  Future<Map<String, dynamic>> addBatch({required int productId, required String batchNumber, required double quantity, required double costPrice, required double sellingPrice, String? comments, required String createdBy}) async {
    try {
      final response = await _supabase.from('batches').insert({
        'product_id': productId,
        'batch_number': batchNumber,
        'quantity': quantity,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'received_date': DateTime.now().toIso8601String(),
        'comments': comments,
        'created_by': createdBy,
      }).select().single();

      await _supabase.from('stock').insert({
        'product_id': productId,
        'batch_id': response['id'],
        'quantity': quantity,
      });

      print('Partiya qo‘shildi: batch_id=${response['id']}, product_id=$productId, quantity=$quantity');
      await _preloadStockQuantities();
      return response;
    } catch (e) {
      print('Partiya qo‘shishda xato: $e');
      Get.snackbar('Xatolik', 'Partiya qo‘shishda xato: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addSale({required String saleType, required int? customerId, required double totalAmount, required double discountAmount, required double paidAmount, required String comments, required String createdBy, required List<Map<String, dynamic>> items}) async {
    try {
      print('addSale: items=$items'); // Log qo‘shish
      final saleResponse = await _supabase.from('sales').insert({
        'sale_type': saleType,
        'customer_id': customerId,
        'total_amount': totalAmount,
        'discount_amount': discountAmount,
        'paid_amount': paidAmount,
        'comments': comments,
        'created_by': createdBy,
      }).select().single();

      final saleId = saleResponse['id'];
      print('Yangi sotuv qo‘shildi: sale_id=$saleId');

      // sale_items ga ma'lumot kiritish, total_price olib tashlanadi
      final saleItems = items.map((item) => {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'batch_id': item['batch_id'],
        'quantity': item['quantity'],
        'unit_price': item['unit_price'],
      }).toList();

      print('saleItems: $saleItems'); // Log qo‘shish
      await _supabase.from('sale_items').insert(saleItems);

      return saleResponse;
    } catch (e) {
      print('Sotuv qo‘shishda xato: $e');
      rethrow;
    }
  }

  // Sotuv elementi qo‘shish
  Future<Map<String, dynamic>> addSaleItem({required int saleId, required int batchId, required int quantity, required double unitPrice, required int productId, required String sellerId}) async {
    try {
      final response = await _supabase.from('sale_items').insert({
        'sale_id': saleId,
        'batch_id': batchId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': quantity * unitPrice,
        'product_id': productId,
        'seller_id': sellerId,
      }).select().single();
      return response;
    } catch (e) {
      _handleError(e);
      return {};
    }
  }

  // Birlikni yangilash
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

  // Kategoriyani yangilash
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

  Future<void> updateProduct({
    required int productId,
    required String name,
    String? code,
    required int categoryId,
    required int unitId,
    String? description,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .update({
        'name': name,
        'code': code,
        'category_id': categoryId,
        'unit_id': unitId,
        'description': description ?? '',
      })
          .eq('id', productId)
          .select()
          .single();
      print('Mahsulot yangilandi: productId=$productId, name=$name, code=$code');
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Mahsulot yangilashda xato: productId=$productId, xato=$errorMessage');
      throw Exception('Mahsulot yangilashda xato: $errorMessage');
    }
  }

  // Partiyani yangilash
  Future<Map<String, dynamic>> updateBatch({required int id, required double quantity, required double costPrice, required double sellingPrice, String? comments}) async {
    try {
      final response = await _supabase.from('batches').update({
        'quantity': quantity,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'comments': comments,
      }).eq('id', id).select().single();

      await _supabase
          .from('stock')
          .update({'quantity': quantity})
          .eq('batch_id', id);

      print('Partiya yangilandi: batch_id=$id, quantity=$quantity');
      await _preloadStockQuantities();
      return response;
    } catch (e) {
      print('Partiya yangilashda xato: $e');
      _handleError(e);
      return {};
    }
  }

  // Birlikni o‘chirish
  Future<void> deleteUnit(int id) async {
    try {
      await _supabase.from('units').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _supabase.rpc('delete_product_with_relations', params: {'p_product_id': productId});
      print('Mahsulot o‘chirildi: productId=$productId');
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      print('Mahsulot o‘chirishda xato: productId=$productId, xato=$errorMessage');
      throw Exception('Mahsulot o‘chirishda xato: $errorMessage');
    }
  }

  // Partiyani o‘chirish
  Future<void> deleteBatch(int id) async {
    try {
      await _supabase.from('batches').delete().eq('id', id);
      await _supabase.from('stock').delete().eq('batch_id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Sotuvni o‘chirish
  Future<void> deleteSale(int id) async {
    try {
      await _supabase.from('sales').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Sotuv elementini o‘chirish
  Future<void> deleteSaleItem(int id) async {
    try {
      await _supabase.from('sale_items').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Tranzaksiyani o‘chirish
  Future<void> deleteTransaction(int id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  // Partiya raqamini tekshirish
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

  // Qoldiqni olish
  Future<double> getStockQuantity(String productId) async {
    try {
      final response = await _supabase
          .from('stock')
          .select('quantity')
          .eq('product_id', productId);
      print('Qoldiq so‘rovi: product_id=$productId, response=$response');
      if (response.isEmpty) return 0.0;
      return response.fold<double>(
        0.0,
            (sum, item) => sum + ((item['quantity'] as num?)?.toDouble() ?? 0.0),
      );
    } catch (e) {
      print('Qoldiq olishda xato: product_id=$productId, error=$e');
      return 0.0;
    }
  }

  // Barcha ma'lumotlarni tozalash (users va units’dan tashqari)
  Future<void> clearAllDataExceptUsersAndUnits() async {
    try {
      final response = await _supabase.rpc('clear_all_data_except_users_and_units');
      if (response != null && response is String && response.contains('error')) {
        throw Exception(response);
      }
      print('Ma\'lumotlar muvaffaqiyatli tozalandi');
    } catch (e) {
      print('Ma\'lumotlarni tozalashda xato: $e');
      _handleError(e);
    }
  }

  // Qoldiqlarni qayta yuklash (GetController uchun)
  Future<void> _preloadStockQuantities() async {
    try {
      final products = await getProductsWithStock();
      controller.updateStockQuantities(products);
    } catch (e) {
      print('Qoldiqlarni qayta yuklashda xato: $e');
    }
  }
}