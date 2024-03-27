import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel/widgets/post_app_bar.dart';
import 'package:travel/widgets/post_bottom_bar.dart';
import 'package:travel/widgets/api_service.dart';

class PostScreen extends StatelessWidget {
  final File? imageFile;
  final String? readableLocation;
  PostScreen({required this.imageFile, this.readableLocation});

  @override
  Widget build(BuildContext context) {
    Future<List<String>> response =
        ApiService.postData(imageFile, readableLocation);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: imageFile != null
                ? FileImage(imageFile!)
                : AssetImage('assets/default_image.jpg') as ImageProvider,
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            opacity: 0.9),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: PostAppBar(),
        ),
        bottomNavigationBar: PostBottomBar(
          readableLocation: readableLocation ?? "",
          response: response,
        ),
      ),
    );
  }
}
