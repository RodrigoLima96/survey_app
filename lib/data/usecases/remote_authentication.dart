import 'package:flutter/material.dart';

import '../../domain/usecases/usecases.dart';

import '../../data/http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({@required this.httpClient, @required this.url});

  Future<void> auth(AuthenticationParams authenticationParams) async {
    httpClient.request(
      url: url,
      method: "post",
      body: authenticationParams.toJson(),
    );
  }
}
