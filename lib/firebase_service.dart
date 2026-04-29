import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Central Firebase service — auth, Firestore, Storage in one place.
class FirebaseService {
  FirebaseService._();

  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // ── AUTH ─────────────────────────────────────────────────────────────────

  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    // Create user profile doc
    await _db.collection('users').doc(cred.user!.uid).set({
      'displayName': displayName,
      'email': email,
      'plan': 'free',
      'importsUsed': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ── USER PROFILE ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update(data);
  }

  static Future<String> getUserPlan() async {
    final profile = await getUserProfile();
    return profile?['plan'] ?? 'free';
  }

  // ── ICON PACKS ───────────────────────────────────────────────────────────

  static CollectionReference get _packs => _db.collection('packs');

  static Future<DocumentReference> createPack({
    required String name,
    required String description,
    bool isPublic = false,
  }) async {
    return _packs.add({
      'ownerId': uid,
      'ownerName': currentUser?.displayName ?? 'Anonymous',
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'iconCount': 0,
      'price': 0.0,
      'downloads': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getUserPacks() {
    return _packs
        .where('ownerId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMarketplacePacks() {
    return _packs
        .where('isPublic', isEqualTo: true)
        .where('price', isGreaterThan: 0)
        .orderBy('price')
        .orderBy('downloads', descending: true)
        .snapshots();
  }

  static Future<void> updatePack(String packId, Map<String, dynamic> data) async {
    await _packs.doc(packId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deletePack(String packId) async {
    // Delete all icons in the pack first
    final icons = await _packs.doc(packId).collection('icons').get();
    for (final doc in icons.docs) {
      await doc.reference.delete();
    }
    await _packs.doc(packId).delete();
  }

  // ── ICONS ────────────────────────────────────────────────────────────────

  static Future<void> updateIcon({
    required String packId,
    required String iconId,
    required String name,
    required Map<String, dynamic> editorSettings,
  }) async {
    await _packs
        .doc(packId)
        .collection('icons')
        .doc(iconId)
        .update({'name': name, 'editorSettings': editorSettings});
  }

  static Future<DocumentReference> addIconToPack({
    required String packId,
    required String name,
    required Map<String, dynamic> editorSettings,
    String? storageUrl,
  }) async {
    final ref = await _packs.doc(packId).collection('icons').add({
      'name': name,
      'editorSettings': editorSettings,
      'storageUrl': storageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Increment icon count
    await _packs.doc(packId).update({
      'iconCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref;
  }

  static Stream<QuerySnapshot> getPackIcons(String packId) {
    return _packs
        .doc(packId)
        .collection('icons')
        .orderBy('createdAt')
        .snapshots();
  }

  static Future<void> deleteIcon(String packId, String iconId) async {
    await _packs.doc(packId).collection('icons').doc(iconId).delete();
    await _packs.doc(packId).update({
      'iconCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── STORAGE ──────────────────────────────────────────────────────────────

  static Future<String> uploadIconImage({
    required String packId,
    required String iconId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('icons/$uid/$packId/$iconId.png');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    return ref.getDownloadURL();
  }

  static Future<String> uploadPackThumbnail({
    required String packId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('thumbnails/$uid/$packId/thumb.png');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    return ref.getDownloadURL();
  }

  // ── IMPORT COUNTER ────────────────────────────────────────────────────────

  static Future<int> getImportsUsed() async {
    final profile = await getUserProfile();
    return profile?['importsUsed'] ?? 0;
  }

  static Future<void> incrementImports() async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'importsUsed': FieldValue.increment(1),
    });
  }

  // ── MARKETPLACE ──────────────────────────────────────────────────────────

  static Future<void> publishPack({
    required String packId,
    required double price,
  }) async {
    await _packs.doc(packId).update({
      'isPublic': true,
      'price': price,
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> recordDownload(String packId) async {
    await _packs.doc(packId).update({
      'downloads': FieldValue.increment(1),
    });
  }
}
