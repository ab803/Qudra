import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';

class EmergencyContactsViewModel extends ChangeNotifier {
  EmergencyContactsViewModel({
    required EmergencyContactsService contactsService,
    required EmergencyDialerService dialerService,
  })  : _contactsService = contactsService,
        _dialerService = dialerService;

  final EmergencyContactsService _contactsService;
  final EmergencyDialerService _dialerService;

  bool isLoading = false;
  String? errorMessage;

  List<EmergencyContactModel> contacts = [];

  Future<void> loadContacts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      contacts = await _contactsService.getContacts();
    } catch (_) {
      errorMessage = 'تعذر تحميل جهات الاتصال.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContact(EmergencyContactModel contact) async {
    try {
      await _contactsService.addContact(contact);
      await loadContacts();
      return true;
    } catch (_) {
      errorMessage = 'تعذر إضافة جهة الاتصال.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContact(EmergencyContactModel contact) async {
    try {
      await _contactsService.updateContact(contact);
      await loadContacts();
      return true;
    } catch (_) {
      errorMessage = 'تعذر تعديل جهة الاتصال.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteContact(int localId) async {
    try {
      await _contactsService.deleteContact(localId);
      await loadContacts();
    } catch (_) {
      errorMessage = 'تعذر حذف جهة الاتصال.';
      notifyListeners();
    }
  }

  Future<void> setPrimaryContact(int localId) async {
    try {
      await _contactsService.setPrimaryContact(localId);
      await loadContacts();
    } catch (_) {
      errorMessage = 'تعذر تحديث جهة الاتصال الأساسية.';
      notifyListeners();
    }
  }

  Future<void> callContact(String phoneNumber) async {
    await _dialerService.callNumber(phoneNumber);
  }
}