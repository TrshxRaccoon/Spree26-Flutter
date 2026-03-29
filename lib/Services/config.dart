import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class Config {
  static final Config _instance = Config._internal();
  static const _secureStorage = FlutterSecureStorage();
  String? apiUrl;
  String? passPortalUrl;

  /// If true, show Events page/card; from Firestore config/api_config.events.
  bool showEvents = true;

  /// If true, show Sponsors page/card; from Firestore config/api_config.sponsors.
  bool showSponsors = true;

  factory Config() {
    return _instance;
  }

  Config._internal();

  Future<void> initialize() async {
    apiUrl = await _secureStorage.read(key: 'api_url');
    passPortalUrl = await _secureStorage.read(key: 'pass_portal_url');
    if (passPortalUrl == null) {
      await fetchPassPortalUrl();
    }
    await _fetchFeatureFlags();
  }

  Future<void> _fetchFeatureFlags() async {
    try {
      // final firestore = FirebaseFirestore.instance;
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );
      final doc = await firestore.collection('config').doc('api_config').get();
      if (doc.exists) {
        final events = doc.get('events');
        final sponsors = doc.get('sponsors');
        showEvents = events is bool ? events : true;
        showSponsors = sponsors is bool ? sponsors : true;
      }
    } catch (e) {
      // Keep defaults (true) on error
    }
  }

  Future<void> fetchAndStoreApiUrl() async {
    try {
      await Firebase.initializeApp();
      // final firestore = FirebaseFirestore.instance;
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );
      final apiUrlDoc = await firestore
          .collection('config')
          .doc('api_config')
          .get();
      apiUrl = apiUrlDoc.get('paymentapi');

      // Check if the key already exists before writing
      final existingValue = await _secureStorage.read(key: 'api_url');
      if (existingValue != apiUrl) {
        await _secureStorage.write(key: 'api_url', value: apiUrl);
      }
    } catch (e) {
      // Handle keychain errors gracefully
      // Try to read existing value if write fails
      apiUrl = await _secureStorage.read(key: 'api_url');
    }
  }

  Future<void> fetchPassPortalUrl() async {
    try {
      // await Firebase.initializeApp();
      // final firestore = FirebaseFirestore.instance;
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );
      final passPortalDoc = await firestore
          .collection('config')
          .doc('api_config')
          .get();
      passPortalUrl = passPortalDoc.get('pass_portal_url');

      // Check if the key already exists before writing
      final existingValue = await _secureStorage.read(key: 'pass_portal_url');
      if (existingValue != passPortalUrl) {
        await _secureStorage.write(
          key: 'pass_portal_url',
          value: passPortalUrl,
        );
      }
    } catch (e) {
      // Handle keychain errors gracefully
      // Try to read existing value if write fails
      passPortalUrl = await _secureStorage.read(key: 'pass_portal_url');
    }
  }

  Future<void> clearData() async {
    await _secureStorage.delete(key: 'api_url');
    apiUrl = null;
    //passPortalUrl = null;
  }

  Future<bool> isAppleAuthEnabled() async {
    try {
      // final firestore = FirebaseFirestore.instance;
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );
      final passPortalDoc = await firestore
          .collection('config')
          .doc('api_config')
          .get();
      bool isAppleAuthEnabled = passPortalDoc.get('apple_auth');

      // Check if the key already exists before writing
      final existingValue = await _secureStorage.read(key: 'apple_auth');
      if (existingValue != isAppleAuthEnabled.toString()) {
        await _secureStorage.write(
          key: 'apple_auth',
          value: isAppleAuthEnabled.toString(),
        );
      }
      return isAppleAuthEnabled;
    } catch (e) {
      // Handle keychain errors gracefully
      // Try to read existing value if write fails
      final existingValue = await _secureStorage.read(key: 'apple_auth');
      return existingValue == 'true';
    }
  }
}
