import 'package:flutter/material.dart';

import '../../domain/usecases/usecases.dart';

import '../../data/http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({@required this.httpClient, @required this.url});

  Future<void> auth(AuthenticationParams authenticationParams) async {
    final body =
        RemoteAuthenticationParams.fromModel(authenticationParams).toJson();
    httpClient.request(
      url: url,
      method: "post",
      body: body,
    );
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({@required this.email, @required this.password});

  factory RemoteAuthenticationParams.fromModel(AuthenticationParams params) =>
      RemoteAuthenticationParams(
          email: params.email, password: params.password);

  Map toJson() => {'email': email, 'password': password};
}
