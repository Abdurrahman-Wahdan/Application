import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<String>> postData(
    final File? imageFile,
    final String? readableLocation,
  ) async {
    // Replace the URL below with your API endpoint.
    final apiUrl =
        'http://172.20.10.3:5008/postData'; // Replace with your actual endpoint

    try {
      // Create a MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the image file to the request
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Replace with the field name expected by your API
            imageFile.path,
            filename: fileName,
          ),
        );
      }

      // Add the readableLocation to the request
      if (readableLocation != null) {
        request.fields['location'] = readableLocation;
      }

      // Send the request
      var response = await request.send();

      // Handle the response as needed.
      if (response.statusCode == 200) {
        // Successful request (201 Created in this example)
        final Map<String, dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        String info = responseData["info"];
        String title = responseData["title"];
        return [
          title,
          info,
        ];
      } else if (response.statusCode == 404) {
        // Successful request (201 Created in this example)
        final Map<String, dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        String info = responseData["info"];
        String title = responseData["title"];
        return [
          title,
          info,
        ];
      } else {
        // Handle error cases.
        print('Error. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        return ['Error. Status code: ${response.statusCode}'];
      }
    } catch (e) {
      print('Error posting data: $e');
      return ['Error posting data: $e'];
    }
  }
}
