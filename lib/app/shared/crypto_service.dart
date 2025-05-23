import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final _storage = const FlutterSecureStorage();
  final _algorithm = Ed25519();

  static const _privateKeyKey = 'kPriv@Unio2025';
static const _publicKeyKey = 'kPub@Unio2025';

  Future<KeyPair> getOrCreateKeyPair() async {
    final encodedPrivate = await _storage.read(key: _privateKeyKey);

    if (encodedPrivate != null) {
      final privateBytes = base64Decode(encodedPrivate);
      return _algorithm.newKeyPairFromSeed(privateBytes);
    } else {
      final keyPair = await _algorithm.newKeyPair();
      final private = await keyPair.extractPrivateKeyBytes();
      final public = await keyPair.extractPublicKey();

      await _storage.write(key: _privateKeyKey, value: base64Encode(private));
      await _storage.write(key: _publicKeyKey, value: base64Encode(public.bytes));

      return keyPair;
    }
  }

  Future<String?> getPublicKeyBase64() async {
    return await _storage.read(key: _publicKeyKey);
  }

  Future<String> signVoto(Map<String, dynamic> voto) async {
    final jsonBytes = utf8.encode(jsonEncode(voto));
    final keyPair = await getOrCreateKeyPair();
    final signature = await _algorithm.sign(jsonBytes, keyPair: keyPair);
    return base64Encode(signature.bytes);
  }
}