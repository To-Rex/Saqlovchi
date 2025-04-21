import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'get_controller.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  GetController get controller => Get.find<GetController>();

  void _handleError(dynamic error) {
    throw Exception('Xato: $error');
  }

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

  Future<List<dynamic>> getAllSalesDetails({
    String searchQuery = '',
    String status = 'all',
    DateTime? startDate,
    DateTime? endDate,
    String sortOrder = 'newest',
  }) async {
    try {
      final response = await _supabase.rpc('get_all_sales_details', params: {
        'p_search_query': searchQuery,
        'p_status': status,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
        'p_sort_order': sortOrder,
      });
      print('Barcha sotuvlar detallari: ${response.length} ta');
      return response as List<dynamic>;
    } catch (e) {
      print('Sotuvlar detallarini olishda xato: $e');
      _handleError(e);
      return [];
    }
  }

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
      print('Tranzaksiya qo‘shildi: $transactionType, Miqdor: $amount, Mijoz ID: $customerId');
      return response;
    } catch (e) {
      print('Tranzaksiya qo‘shishda xato: $e');
      _handleError(e);
      return {};
    }
  }

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

  Future<void> deleteCustomer(int id) async {
    try {
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

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

  Future<List<dynamic>> getUnits() async {
    try {
      final response = await _supabase.from('units').select('id, name, description, created_at, created_by');
      return response as List<dynamic>;
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

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

  Future<List<dynamic>> getBatches() async {
    try {
      final response = await _supabase.from('batches').select('*, products(name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

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

  Future<List<dynamic>> getCustomers() async {
    try {
      final response = await _supabase.from('customers').select();
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

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

  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _supabase.from('transactions').select('*, sales(id), customers(full_name), users(full_name)');
      return response as List<dynamic>;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

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

  Future<Map<String, dynamic>> updateUnit({
    required int id,
    required String name,
    String? description,
  }) async {
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

  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
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

  Future<void> deleteUnit(int id) async {
    try {
      await _supabase.from('units').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteBatch(int id) async {
    try {
      await _supabase.from('batches').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteSale(int id) async {
    try {
      await _supabase.from('sales').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteSaleItem(int id) async {
    try {
      await _supabase.from('sale_items').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
    } catch (e) {
      _handleError(e);
    }
  }

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
}