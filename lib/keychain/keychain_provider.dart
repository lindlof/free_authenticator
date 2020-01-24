import 'dart:convert';

import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter/services.dart';

class KeychainProvider {
  static final _cryptor = new PlatformStringCryptor();

  String _key;
  Future<String> _getKey() async {
    if (_key != null) return _key;
    _key = await _initKey();
    return _key;
  }

  _initKey() async {
    String key = await FlutterKeychain.get(key: "key");
    if (key != null) return key;
    final String newKey = await _cryptor.generateRandomKey();
    await FlutterKeychain.put(key: "key", value: newKey);
    return newKey;
  }

  Future<String> encrypt(String data) async {
    String key = await this._getKey();
    return await _cryptor.encrypt(data, key);
  }

  Future<String> decrypt(String encrypted) async {
    try {
      String key = await this._getKey();
      return await _cryptor.decrypt(encrypted, key);
    } on MacMismatchException {
      print("Unable to decrypt data (wrong key or forged data)");
      return null;
    } on PlatformException {
      print("Unable to decrypt data (platform exception)");
      return null;
    }
  }

  Future<String> encryptJson(Map<String, dynamic> data) async {
    var jsonData = jsonEncode(data);
    return await this.encrypt(jsonData);
  }

  Future<Map<String, dynamic>> decryptJson(String encrypted) async {
    var decrypted = await this.decrypt(encrypted);
    return jsonDecode(decrypted);
  }
}
