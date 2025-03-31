import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/main/main_screen.dart';

class ApiService {
  final _supabase = Supabase.instance.client;


  // Kategoriyalarni olish
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _supabase
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
      final response = await _supabase.from('units').select('id, name').order('name', ascending: true);
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
      await _supabase.from('categories').insert({
        'name': name,
        'created_by': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      throw Exception('Kategoriya qo‘shishda xato: $e');
    }
  }

  // Kategoriyani tahrirlash
  Future<void> editCategory(String id, String newName) async {
    try {
      print('Kategoriya tahrirlanmoqda: id=$id, yangi nom=$newName');
      await _supabase.from('categories').update({'name': newName}).eq('id', id);
    } catch (e) {
      throw Exception('Kategoriyani tahrirlashda xato: $e');
    }
  }

  // Kategoriyani o‘chirish
  Future<void> deleteCategory(String id) async {
    try {
      print('Kategoriya o‘chirilmoqda: id=$id');
      await _supabase.from('categories').delete().eq('id', id);
      print('Kategoriya muvaffaqiyatli o‘chirildi: id=$id');
    } catch (e) {
      throw Exception('Kategoriyani o‘chirishda xato: $e');
    }
  }

  // Mahsulotlarni olish
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _supabase.from('products').select(
          'id, name, category_id, cost_price, selling_price, quantity, unit_id, units(name), created_by, users!products_created_by_fkey(full_name), batches(id, batch_number, cost_price, quantity)')
          .order('created_at', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Mahsulotlarni olishda xato: $e');
    }
  }

  // Mahsulot qo‘shish
  Future<void> addProduct(String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    try {
      print('AddProduct: quantity=$quantity');
      await _supabase.from('products').insert({
        'name': name,
        'category_id': categoryId,
        'cost_price': costPrice,
        'selling_price': sellingPrice ?? 0.0,
        'quantity': quantity ?? 0.0, // Trigger batches ga qo‘shadi
        'unit_id': unitId,
        'created_by': _supabase.auth.currentUser?.id,
      });
      print('Mahsulot qo‘shildi, trigger batches ga qo‘shdi');
    } catch (e) {
      print('Xato yuz berdi: $e');
      throw Exception('Mahsulot qo‘shishda xato: $e');
    }
  }

  Future<void> editProduct(String id, String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    try {
      print('EditProduct: id=$id, quantity=$quantity');
      final updateData = {
        'name': name,
        'category_id': categoryId,
        'cost_price': costPrice,
        'unit_id': unitId,
      };
      if (sellingPrice != null) {
        updateData['selling_price'] = sellingPrice;
      }
      if (quantity != null) {
        updateData['quantity'] = quantity;
        print('Quantity added to updateData: ${updateData['quantity']}');
      }
      print('UpdateData before sending: $updateData');
      final response = await _supabase.from('products').update(updateData).eq('id', id);
      print('Update response: $response');
      print('Mahsulot yangilandi, trigger batches miqdorini yangiladi');
    } catch (e) {
      throw Exception('Mahsulotni tahrirlashda xato: $e');
    }
  }

  // Mahsulotni o‘chirish
  Future<void> deleteProduct(String id) async {
    try {
      print('Mahsulot o‘chirilmoqda: id=$id');
      await _supabase.from('products').delete().eq('id', id); // ON DELETE CASCADE ishlaydi
      print('Mahsulot muvaffaqiyatli o‘chirildi: id=$id');
    } catch (e) {
      print('Xato yuz berdi: $e');
      throw Exception('Mahsulotni o‘chirishda xato: $e');
    }
  }

  // Sotilgan tovarlarni olish
  Future<List<dynamic>> getSoldItems() async {
    try {
      final response = await _supabase
          .from('sold_items')
          .select('id, quantity, selling_price, sale_date, product_id, products(name), seller_id, users!seller_id(full_name)')
          .order('sale_date', ascending: false);
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Sotilgan tovarlarni olishda xato: $e');
    }
  }

  // Kirish (Sign In)
  Future<void> signIn(context,String email, String password) async {
    try {
      final AuthResponse responses = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (responses.user != null) {
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
}