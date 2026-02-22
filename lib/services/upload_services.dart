import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String> uploadImageBytes(Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref(
      'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }
}
