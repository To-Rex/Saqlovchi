import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';

class TransactionsScreenController extends GetxController {
  final ApiService apiService = ApiService();

  var transactionsFuture = Rxn<Future<List<dynamic>>>();
  var statsFuture = Rxn<Future<Map<String, dynamic>>>();
  var typeStatsFuture = Rxn<Future<Map<String, Map<String, dynamic>>>>();
  var searchQuery = ''.obs;
  var selectedType = 'all'.obs;
  var sortOrder = 'newest'.obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var financialStatsFuture = Rxn<Future<Map<String, dynamic>>>();

  @override
  void onInit() {
    super.onInit();
    _updateTransactions();
    _updateStats();
    _updateTypeStats();
  }

  void upDateData() {
    updateFinancialStats();
    _updateTransactions();
    _updateStats();
    _updateTypeStats();
  }


  void updateFinancialStats() {
    print('====================================================================================');
    print('startDate: ${startDate.value}, endDate: ${endDate.value}');
    print('====================================================================================');
    financialStatsFuture.value = apiService.getFinancialSummary(
      startDate: startDate.value,
      endDate: endDate.value,
    );
  }



  void _updateTransactions() {
    transactionsFuture.value = apiService.getAllTransactions(
      searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      transactionType: selectedType.value == 'all' ? null : selectedType.value,
      startDate: startDate.value,
      endDate: endDate.value,
    );
  }

  void _updateStats() {
    statsFuture.value = apiService.getTransactionStats(
      startDate: startDate.value,
      endDate: endDate.value,
    );
  }

  void _updateTypeStats() {
    typeStatsFuture.value = apiService.getTransactionTypeStats(
      startDate: startDate.value,
      endDate: endDate.value,
    );
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _updateTransactions();
  }

  void setType(String? type) {
    if (type != null) {
      selectedType.value = type;
      _updateTransactions();
    }
  }

  void setSortOrder(String? order) {
    if (order != null) {
      sortOrder.value = order;
      _updateTransactions();
    }
  }

  void setStartDate(DateTime? date) {
    startDate.value = date;
    upDateData();
  }

  void setEndDate(DateTime? date) {
    endDate.value = date;
    upDateData();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'all';
    sortOrder.value = 'newest';
    startDate.value = null;
    endDate.value = null;
    upDateData();
  }
}