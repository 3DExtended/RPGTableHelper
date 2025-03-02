import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/auth/rsa_key_helper.dart';

abstract class IEncryptionService {
  final bool isMock;
  String? _cachedEncryptedPublicKey;

  IEncryptionService({required this.isMock});

  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> getKeyPair();

  Future<(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>, String)>
      getKeysAndPublicPem() async {
    var keys = await getKeyPair();

    if (_cachedEncryptedPublicKey != null) {
      return (keys, _cachedEncryptedPublicKey!);
    }

    var appPubKeyPem = RsaKeyHelper.encodePublicKeyToPem(keys.publicKey);
    var serPubKey =
        RsaKeyHelper.parsePublicKeyFromPem(rpgtablehelperPublicCertificate);

    _cachedEncryptedPublicKey = RsaKeyHelper.encrypt(appPubKeyPem, serPubKey);
    return (keys, _cachedEncryptedPublicKey!);
  }

  String calculateUserSecretForEncryptionChallenge(
      Map<String, dynamic> challenge, String password) {
    var ri = challenge['ri'] as int;
    var bytes = utf8.encode(challenge['pp'] +
        ri.toString() +
        password +
        ri.toString()); // data being hashed

    var digest = sha256.convert(bytes);
    var userSecret = base64Encode(digest.bytes);
    return userSecret;
  }
}

class EncryptionService extends IEncryptionService {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? _cachedKeys;

  EncryptionService() : super(isMock: false) {
    // Don't await here, just schedule key pair generation
    // getKeyPair();
  }

  @override
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> getKeyPair() async {
    if (_cachedKeys != null) {
      return _cachedKeys!;
    }

    _cachedKeys =
        await RsaKeyHelper.computeRSAKeyPair(RsaKeyHelper.getSecureRandom());
    return _cachedKeys!;
  }
}

class MockEncryptionService extends IEncryptionService {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? keyPairOverride;
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? _cachedKeys;

  MockEncryptionService({
    this.keyPairOverride,
  }) : super(isMock: true);

  @override
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> getKeyPair() async {
    if (keyPairOverride != null) return keyPairOverride!;

    if (_cachedKeys != null) {
      return _cachedKeys!;
    }

    _cachedKeys =
        await RsaKeyHelper.computeRSAKeyPair(RsaKeyHelper.getSecureRandom());
    return _cachedKeys!;
  }
}
