import '../services/api_client.dart';
import '../config/env.dart';

class CloudinaryUtils {
  CloudinaryUtils._();

  static Future<String> uploadImageToCloudinary(String filePath) async {
    // Note: This is a placeholder for mobile file upload; integrate file picker as needed.
    final response = await ApiClient().post('/admin/upload', data: {
      'image': filePath,
    });
    final data = response.data as Map<String, dynamic>;
    return data['publicId'] as String;
  }

  static String getCloudinaryUrl(String publicId) {
    final cloudName = EnvConfig.cloudinaryCloudName;
    return 'https://res.cloudinary.com/$cloudName/image/upload/$publicId';
  }
}


