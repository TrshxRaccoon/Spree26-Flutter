import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:spree/models/merch_order.dart';

class MerchService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? paymentapi;

  Future<void> initialize() async {
    var doc = await firestore.FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'spree-26',
    ).collection('config').doc('api_config').get();
    paymentapi = doc.get('paymentapi');
  }

  Future<MerchOrder?> getOrder() async {
    if (paymentapi == null) await initialize();
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('$paymentapi/merch/customer/orders'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['order'] == null) return null;
        return MerchOrder.fromJson(data['order'] as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log out and log in again.');
      } else {
        throw Exception('Failed to fetch merch order.');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> book() async {
    if (paymentapi == null) await initialize();
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('$paymentapi/merch/customer/book'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('No merch order found for your account.');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log out and log in again.');
      } else {
        throw Exception('Failed to book for collection.');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      rethrow;
    }
  }
}
