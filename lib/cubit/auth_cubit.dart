import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:nb_utils/nb_utils.dart' show Fluttertoast;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import 'auth_state.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthIntialState());
  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String relation,
    required String age,
    required String gender,
    required BuildContext context,
  }) async {
    emit(RegisterLoadingState());

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || relation.isEmpty || age.isEmpty ) {
      emit(FailedRegisterState(message: "Please fill in all the fields."));
      return;
    }

    if (password != confirmPassword) {
      emit(FailedRegisterState(message: "Passwords do not match."));
      return;
    }
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      "name": name,
      'relation': relation,
      'age': age,
      "confirmPassword": password,
      "gender": gender,
    };
    try {
      http.Response response = await http.post(
        Uri.parse("http://192.168.100.3:3400/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      print("Response: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(RegisterSuccessState());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Registration successful!'),
            ),
          );
        }
      } else {
        emit(
          FailedRegisterState(
            message: data['message'] ?? 'Registration failed!',
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Something went wrong'),
              backgroundColor: Colors.red,
            ),
          );
          print(data['message'] ?? 'Something went wrong');


        }
      }
    } catch (e) {
      emit(FailedRegisterState(message: "Error: $e"));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

      }
    }
  }
  Future<void> verifyOtp(String otp,String email) async {
    if (otp.isEmpty || otp.length != 4) {
      emit(AuthErrorState("Please enter a valid 4-digit OTP"));
      return;
    }
    emit(AuthLoadingState());
    Map<String, dynamic> body = {
      'otp': otp,
      'email': email,
    };
    try {
      final Uri url = Uri.parse("http://192.168.100.3:3400/auth/confirm-email");
      final response = await http.patch(url,body:jsonEncode(body), headers: {"Content-Type": "application/json"},
    );
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        emit(AuthSuccessState());
      } else {
        emit(AuthErrorState(data['message'] ?? 'Verification failed'));

      }
    } catch (e) {
      emit(AuthErrorState("An error occurred: $e"));

    }
  }
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    emit(LoginLoadingState());
    Map<String, String> body = {'email': email, 'password': password};
    try {
      Response response = await http.post(
        Uri.parse("http://192.168.100.3:3400/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        String? token = data['data']['access_token'];
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          emit(LoginSuccessState());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login successful')),
          );

        }
      } else {
        emit(FailedLoginState(message: data['message'] ?? 'An error occurred'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );

      }
    } catch (error) {
      emit(FailedLoginState(message: error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUserData() async {
    emit(UserLoading());
    final prefs = await SharedPreferences.getInstance();
    final backendToken = prefs.getString('access_token');
    if (backendToken == null || backendToken.isEmpty) {
      emit(UserError('No token found. Please log in again.'));
      return;
    }
    const String apiUrl = 'http://192.168.100.3:3400/user/profile';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $backendToken',
        },
      );
      print("Response: ${response.body}");


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] == null) {
          emit(UserError('User data not found in the response'));
          return;
        }
        UserModel user = UserModel.fromJson(jsonData['data']);
        emit(UserLoaded(user));
      } else if (response.statusCode == 401) {
        emit(UserError('Unauthorized. Please log in again.'));
      } else {
        emit(UserError('Error: ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(UserError('Fetch error: $e'));
    }
  }

  Future<void> updateUserData({
    required String name,
    required String age,
    required String relation,
  }) async {
    emit(UserLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? backendToken = prefs.getString('access_token');

      if (backendToken == null || backendToken.isEmpty) {
        emit(UserError('No token found. Please log in again.'));
        return;
      }

      final url = Uri.parse('http://192.168.100.3:3400/user');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $backendToken',
        },
        body: json.encode({
          'name': name,
          'age': age,
          'relation': relation,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && jsonResponse['success'] == true) {
        try {
          final updatedUser = UserModel.fromJson(jsonResponse['data']);
          emit(UserUpdated(updatedUser));
        } catch (e) {
          emit(UserError("Failed to parse user data: $e"));
        }
      } else {
        final errorMessage = jsonResponse['message'] ?? 'Unknown error';
        emit(UserError("Update failed: $errorMessage"));
      }
    } catch (e) {
      emit(UserError("Failed to update profile: ${e.toString()}"));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    emit(AuthLoadingState());

    final Uri url = Uri.parse(
      "http://192.168.100.3:3400/auth/reset-password"
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email,"newPassword": password,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Password reset successfully!");
        emit(AuthSuccessState());

      } else {
        final errorMessage = json.decode(response.body)['message'];
        Fluttertoast.showToast(msg: "Error: $errorMessage");

        emit(AuthErrorState(errorMessage));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong. Please try again.");
      emit(AuthErrorState(e.toString()));
    }
  }
  Future<File> compressImage(File profilePicture) async {
    final compressed = await FlutterImageCompress.compressAndGetFile(
      profilePicture.absolute.path,
      '${profilePicture.path}_compressed.jpg',
      quality: 70,
    );

    return File(compressed!.path);
  }

  Future<File> convertHeicToJpg(File heicFile) async {
    final newPath = heicFile.path.replaceAll(RegExp(r'\.heic$'), '.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      heicFile.absolute.path,
      newPath,
      format: CompressFormat.jpeg,
      quality: 80,
    );

    return File(result!.path);
  }

  Future<File> removeExif(File profilePicture) async {
    final image = img.decodeImage(await profilePicture.readAsBytes());
    final stripped = File('${profilePicture.path}_stripped.jpg')
      ..writeAsBytesSync(img.encodeJpg(image!));

    return stripped;
  }

  Future<void> saveResult({
    required String diseaseName,
    File? profilePicture,
  }) async {
    emit(ResultLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? backendToken = prefs.getString('access_token');

      if (backendToken == null || backendToken.isEmpty) {
        emit(ResultError('No token found. Please log in again.'));
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.3:3400/result'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $backendToken',
      });

      request.fields['disease_name'] = diseaseName;

      if (profilePicture != null) {
        File processedImage = profilePicture;
        String originalExtension = path.extension(profilePicture.path).toLowerCase();

        if (originalExtension == '.heic') {
          processedImage = await convertHeicToJpg(profilePicture);
        }

        processedImage = await compressImage(processedImage);
        processedImage = await removeExif(processedImage);

        String finalExtension = path.extension(processedImage.path).toLowerCase();
        String mimeType = 'image/jpeg';
        if (finalExtension == '.png') mimeType = 'image/png';
        else if (finalExtension == '.webp') mimeType = 'image/webp';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            processedImage.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }


      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);

        emit(ResultCreated(ResultModel.fromJson(jsonResponse['data'])));
      } else {

        String errorMessage = "Something went wrong.";
        try {
          var errorJson = json.decode(responseBody);
          errorMessage = errorJson['message'] ;
        } catch (_) {
          errorMessage = responseBody;
        }

        emit(ResultError("Upload failed: $errorMessage"));
      }
    } catch (e) {
      emit(ResultError("An error occurred: ${e.toString()}"));
    }
  }
  Future<void> fetchAllResults() async {
    emit(ResultLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? backendToken = prefs.getString('access_token');

      if (backendToken == null || backendToken.isEmpty) {
        emit(ResultError('No token found. Please log in again.'));
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.100.3:3400/result/user'),
        headers: {
          'Authorization': 'Bearer $backendToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final List<dynamic> resultsList = jsonData['data']['result'];

        final results = resultsList
            .map((item) => ResultModel.fromJson(item))
            .toList();

        emit(ResultLoaded(results));
      } else {
        emit(ResultError('Failed to fetch results: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ResultError('Error fetching results: ${e.toString()}'));
    }
  }


}