import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, email, full_name, role, is_blocked')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _users = response as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Foydalanuvchilarni yuklashda xatolik: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBlock(String userId, bool currentStatus) async {
    try {
      await _supabase
          .from('users')
          .update({'is_blocked': !currentStatus})
          .eq('id', userId);
      _fetchUsers(); // Ro‘yxatni yangilash
    } catch (e) {
      setState(() => _error = 'Bloklashda xatolik: $e');
    }
  }

  Future<void> _updateRole(String userId, String newRole) async {
    try {
      await _supabase.from('users').update({'role': newRole}).eq('id', userId);
      _fetchUsers();
    } catch (e) {
      setState(() => _error = 'Rolni yangilashda xatolik: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foydalanuvchilarni Boshqarish'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
          : _users.isEmpty
          ? const Center(child: Text('Foydalanuvchilar topilmadi'))
          : ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isBlocked = user['is_blocked'] ?? false;
          return Card(
            child: ListTile(
              title: Text(user['full_name'] ?? 'Noma\'lum'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user['email']}'),
                  Text('Rol: ${user['role']}'),
                  Text('Holati: ${isBlocked ? 'Bloklangan' : 'Faol'}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: user['role'],
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'manager', child: Text('Menejer')),
                      DropdownMenuItem(value: 'seller', child: Text('Sotuvchi')),
                    ],
                    onChanged: (value) => _updateRole(user['id'], value!),
                  ),
                  ElevatedButton(
                    onPressed: () => _toggleBlock(user['id'], user['is_blocked']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user['is_blocked'] ? Colors.green : Colors.red,
                    ),
                    child: Text(user['is_blocked'] ? 'Blokdan chiqarish' : 'Bloklash'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}