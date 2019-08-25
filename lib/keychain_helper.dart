import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter/services.dart';

class KeychainHelper {

  KeychainHelper._privateConstructor();
  static final KeychainHelper instance = KeychainHelper._privateConstructor();
  static final cryptor = new PlatformStringCryptor();

  static String _key;
  Future<String> _getKey() async {
    if (_key != null) return _key;
    _key = await _initKey();
    return _key;
  }

  _initKey() async {
    String key = await FlutterKeychain.get(key: "key");
    if (key != null) return key;
    final String newKey = await cryptor.generateRandomKey();
    await FlutterKeychain.put(key: "key", value: newKey);
    return newKey;
  }

  static encrypt(String data) async {
    String key = await KeychainHelper.instance._getKey();
    return await cryptor.encrypt(data, key);
  }

  static decrypt(String encrypted) async {
    try {
      String key = await KeychainHelper.instance._getKey();
      return await cryptor.decrypt(encrypted, key);
    } on MacMismatchException {
      print("Unable to decrypt data (wrong key or forged data)");
      return null;
    } on PlatformException {
      print("Unable to decrypt data (platform exception)");
      return null;
    }
  }

}