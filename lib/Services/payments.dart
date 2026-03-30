import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:waves24/constants/secrets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';

import 'package:spree/models/transactions.dart';
import 'package:firebase_core/firebase_core.dart';

class Services {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  String? paymentapi;

  String? token;
  String? refreshToken;

  Future<void> initialize() async {
    var doc = await firestore.FirebaseFirestore.instanceFor(
            app: Firebase.app(), 
            databaseId: 'spree-26'
        )
        .collection('config')
        .doc('api_config')
        .get();
    paymentapi = doc.get('paymentapi');
  }

  Future<String> auth(String token) async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      final response = await http.post(
        Uri.parse('$paymentapi/login/student'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'token': token}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String? returnedToken = responseBody['accessToken'];

        if (returnedToken != null) {
          try {
            await _storage.write(key: 'access_token', value: returnedToken);
            await _storage.write(key: 'user_type', value: 'normal');
          } catch (e) {
            // Handle secure storage errors gracefully
          }
          // await _storage.write(
          //     key: 'refresh_token', value: responseBody['refreshToken']);
          return returnedToken;
        } else {
          try {
            await _storage.write(key: 'user_type', value: 'guest');
          } catch (e) {
            // Handle secure storage errors gracefully
          }
          return 'guest';
        }
      } else if (response.statusCode == 403) {
        try {
          await _storage.write(key: 'user_type', value: 'guest');
        } catch (e) {
          // Handle secure storage errors gracefully
        }
        return 'guest';
      } else {
        throw Exception('Failed to authenticate');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to authenticate.');
    }
  }

  Future<bool> checkPin() async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      String? token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('$paymentapi/student/has-pin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.body == jsonEncode({"hasPin": true});
      } else if (response.statusCode == 401) {
        // await getRefreshToken();
        return checkPin();
      } else {
        throw Exception(
          'Failed to check if user has set pin: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to check if user has set pin: $e');
    }
  }

  // Future<void> getRefreshToken() async {
  //   try {
  //     String? refreshToken = await _storage.read(key: 'refresh_token');

  //     final response = await http.post(
  //       Uri.parse('$paymentapi/auth/refresh'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({'refreshToken': refreshToken}),
  //     );

  //     if (response.statusCode == 200) {
  //       token = jsonDecode(response.body)['accessToken'];
  //       await _storage.write(key: 'access_token', value: token);
  //     } else {
  //       throw Exception(
  //           'Session Expired. Kindly logout and login again with your BITSMail.');
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('Kindly check your network connection.');
  //   } catch (e) {
  //     throw Exception('Please try again. $e');
  //   }
  // }

  Future<bool> setPin(String pin) async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('$paymentapi/student/set-pin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{'pin': pin}),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to set PIN');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to set PIN: $e');
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      return const AndroidId().getId();
    }
    return 'unknown';
  }

  Future<String> makePayment(String vendorId, int amount, String pin) async {

    try {
      if (paymentapi == null) {
        await initialize();
      }

      token = await _storage.read(key: 'access_token');
      String deviceId = await _getId() ?? 'unknown';


      final response = await http.post(
        Uri.parse('$paymentapi/transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "vendorId": vendorId,
          "amount": amount,
          "pin": pin,
          "deviceId": deviceId,
        }),
      );

      if (response.statusCode == 201) {
        return response.body;
        //todo: mahir pls check this this is the payment timestamp and dont use datetime.now
      } else if (response.statusCode == 403) {
        throw Exception(jsonDecode(response.body)['message']);
      } else {
        throw Exception('Failed to make payment');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to make payment: $e');
    }
  }

  Future<String> blockaccount() async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('$paymentapi/student/block-account'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to block account');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to block account: $e');
    }
  }

  Future<void> logout() async {
    if (paymentapi == null) {
      await initialize();
    }

    try {
      final token = await _storage.read(key: 'access_token');
      final endpoints = <String>[
        '$paymentapi/logout/student',
        '$paymentapi/student/logout',
      ];

      Object? lastError;
      for (final endpoint in endpoints) {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204) {
          return;
        }

        // Try fallback route if first route is not present.
        if (response.statusCode == 404) continue;
        lastError = Exception('Logout failed with status ${response.statusCode}');
        break;
      }

      if (lastError != null) throw lastError;
      throw Exception('Failed to logout');
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<Map<String, dynamic>> transactions() async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('$paymentapi/student/transactions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final balance = data['balance'];
        final transactionsJson = data['transactions'] as List;

        final transactions = transactionsJson
            .map((transactionJson) => Transaction.fromJson(transactionJson))
            .toList();

        return {'balance': balance, 'transactions': transactions};
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      throw Exception('Failed to fetch transactions');
    }
  }
  // Future<List<Transaction>> transactions() async {
  //   token = await _storage.read(key: 'access_token');
  //   final response = await http.get(
  //     Uri.parse('$paymentapi/student/transactions'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // List<dynamic> jsonData = json.decode(response.body);
  //     // return jsonData.map((json) => Transaction.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to fetch transactions');
  //   }
  // }

  Future<String> requestOTP() async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('$paymentapi/student/reset-pin/request-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to request OTP');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to request OTP: $e');
    }
  }

  Future<bool> verifyOTP(String otp, String pin) async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      token = await _storage.read(key: 'access_token');
      final response = await http.post(
        Uri.parse('$paymentapi/student/reset-pin/verify-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{'otp': otp, 'newPin': pin}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to verify OTP');
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Failed to verify OTP.');
    }
  }

  Future<String?> validateVendor(String vendorId) async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse('$paymentapi/vendor?vendorId=$vendorId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['shopName'];
      } else {
        return null;
      }
    } on SocketException {
      throw Exception('Kindly check your network connection.');
    } catch (e) {
      throw Exception('Session expired. Kindly logout and try again.');
    }
  }

  Future<Map<String, String>> getDeviceInfo() async {
    if (paymentapi == null) {
      await initialize();
    }
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'deviceId': androidInfo.id,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'osVersion': iosInfo.systemVersion,
        };
      } else {
        return {
          'deviceId': 'unknown',
          'model': 'unknown',
          'manufacturer': 'unknown',
          'osVersion': 'unknown',
        };
      }
    } catch (e) {
      throw Exception('Failed to get device information: $e');
    }
  }
}