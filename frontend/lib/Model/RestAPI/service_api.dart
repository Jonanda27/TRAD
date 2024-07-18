import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:trad/Model/login_model.dart';

class RestAPI {
  String Endpoint = 'http://3.1.172.60:4444';

  //View Model Login
  LoginModel? loginmodel;

  Future<dynamic> login(String? username, String? password) async {
    var auth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final _dio = Dio();
    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));
    try {
      final response = await _dio.post('$Endpoint/users/login',
          data: {'username': username, 'password': password},
          options: Options(headers: <String, String>{'authorization': auth}));

      final login = LoginModel.fromJson(response.data);
      loginmodel = login;
      print(login);
      // ignore: avoid_print
      print('data : $loginmodel');
      return response.data;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
  }
}
