import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Input Validator untuk semua form validation
/// Menggunakan pattern yang konsisten dan reusable
class InputValidator {
  // Validasi field tidak boleh kosong
  static String? notEmpty(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    return null;
  }

  // Validasi email format
  static String? isEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Validasi panjang minimal
  static String? minLength(
    String? value,
    int length, {
    String field = 'Field',
  }) {
    if (value == null || value.isEmpty) {
      return '$field wajib diisi';
    }

    if (value.length < length) {
      return '$field minimal $length karakter';
    }

    return null;
  }

  // Validasi panjang maksimal
  static String? maxLength(
    String? value,
    int length, {
    String field = 'Field',
  }) {
    if (value != null && value.length > length) {
      return '$field maksimal $length karakter';
    }

    return null;
  }

  // Validasi password (minimal 6 karakter)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // Validasi konfirmasi password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (value != password) {
      return 'Password tidak cocok';
    }

    return null;
  }

  // Validasi hanya angka
  static String? isNumeric(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }

    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value.trim())) {
      return '$field harus berupa angka';
    }

    return null;
  }

  // Validasi angka dengan desimal
  static String? isDecimal(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }

    final regex = RegExp(r'^\d+\.?\d*$');
    if (!regex.hasMatch(value.trim())) {
      return '$field harus berupa angka';
    }

    return null;
  }

  // Validasi harga (harus > 0)
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }

    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Harga harus berupa angka';
    }

    final price = int.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Harga harus lebih dari 0';
    }

    return null;
  }

  // Validasi nomor telepon Indonesia
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }

    // Hapus spasi dan karakter non-digit
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    // Format: 08xx atau 628xx (10-13 digit)
    final regex = RegExp(r'^(0|62)8\d{8,11}$');
    if (!regex.hasMatch(cleanValue)) {
      return 'Nomor telepon tidak valid (contoh: 08123456789)';
    }

    return null;
  }

  // Validasi rating (0-5)
  static String? rating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rating wajib diisi';
    }

    final regex = RegExp(r'^\d+\.?\d*$');
    if (!regex.hasMatch(value.trim())) {
      return 'Rating harus berupa angka';
    }

    final rating = double.tryParse(value.trim());
    if (rating == null || rating < 0 || rating > 5) {
      return 'Rating harus antara 0-5';
    }

    return null;
  }

  // Validasi URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL wajib diisi';
    }

    final regex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!regex.hasMatch(value.trim())) {
      return 'URL tidak valid';
    }

    return null;
  }

  // Validasi kombinasi (multiple validators)
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  // Extension untuk GetX validation
  static bool validateForm(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validasi Gagal',
        'Mohon lengkapi semua field dengan benar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }
}
