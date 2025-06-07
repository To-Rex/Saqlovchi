// controllers/test_screen_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import '../companents/custom_toast.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:archive/archive.dart';
import 'dart:html' as html;

class TestScreenController extends GetxController {
  ApiService apiService = ApiService();
  var isLoading = false.obs;

  Future<void> clearAllData(BuildContext context) async {
    isLoading.value = true;
    try {
      await apiService.clearAllDataExceptUsersAndUnits();
      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'Ma\'lumotlar (users va units’dan tashqari) tozalandi',
        type: CustomToast.success,
      );
    } catch (e) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Ma\'lumotlarni tozalashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportCsv(BuildContext context) async {
    isLoading.value = true;
    try {
      // Jadvallar ro‘yxatini olish
      final tablesResponse = await apiService.getPublicTables();
      final tables = List<String>.from(tablesResponse.map((row) => row['table_name']));

      if (tables.isEmpty) {
        throw Exception('Eksport qilish uchun jadval topilmadi');
      }

      // Papka nomini shakllantirish: kun-oy-yil_soat
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy_HH-mm');
      final folderName = formatter.format(now);

      // ZIP arxivini yaratish
      final archive = Archive();

      // Har bir jadval uchun alohida CSV fayl
      for (var table in tables) {
        final csvResponse = await apiService.getTableCsv(table);
        final csvContent = csvResponse.join('\n');
        final bytes = utf8.encode(csvContent);

        // ZIP ichida papka tuzilmasiga CSV fayl qo‘shish
        final csvFile = ArchiveFile('$folderName/$table.csv', bytes.length, bytes);
        archive.addFile(csvFile);
      }

      // ZIP faylni kodlash
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null) {
        throw Exception('ZIP faylni yaratishda xato yuz berdi');
      }

      // ZIP faylni brauzerda yuklash
      final blob = html.Blob([zipBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = '$folderName.zip'
        ..click();
      html.Url.revokeObjectUrl(url);

      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: '${tables.length} ta jadval $folderName papkasida ZIP sifatida yuklandi',
        type: CustomToast.success,
      );
    } catch (e) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'CSV eksport qilishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}