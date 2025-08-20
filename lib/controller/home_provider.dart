import 'package:flutter/material.dart';
import 'package:online_image_classification/model/upload_response.dart';
import 'package:online_image_classification/service/http_service.dart';
import 'package:online_image_classification/service/image_service.dart';
import 'package:online_image_classification/ui/camera_page.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  // todo-04: add property and constructor
  // there is error, but we will solve later
  final HttpService _httpService;
  HomeProvider(this._httpService);

  String? imagePath;

  XFile? imageFile;

  // todo-05: to handle upload state
  bool isUploading = false;
  String? message;
  UploadResponse? uploadResponse;

  void _setImage(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
    notifyListeners();
  }

  void openCamera() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      _setImage(pickedFile);
      // todo-15: reset all state after user pick image
      _resetUploadState();
    }
  }

  void openGallery() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _setImage(pickedFile);
      // todo-15: reset all state after user pick image
      _resetUploadState();
    }
  }

  void openCustomCamera(BuildContext context) async {
    final XFile? resultImageFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(),
      ),
    );

    if (resultImageFile != null) {
      _setImage(resultImageFile);
      // todo-15: reset all state after user pick image
      _resetUploadState();
    }
  }

  // todo-06: create a upload function
  void upload() async {
    // todo-07: check if image exist
    if (imagePath == null || imageFile == null) return;

    // todo-08: set upload state
    isUploading = true;
    message = null;
    _resetUploadState();

    // todo-09: prepare a document variabel to upload
    final bytes = await imageFile!.readAsBytes();
    final filename = imageFile!.name;

    // todo-21: resize or compress image
    final miniBytes = await ImageService.compressImage(bytes);

    // todo-10: set upload state after uploaded
    uploadResponse = await _httpService.uploadDocument(miniBytes, filename);
    message = uploadResponse?.message;
    isUploading = false;
    notifyListeners();
  }

  void _resetUploadState() {
    message = null;
    uploadResponse = null;
    notifyListeners();
  }
}
