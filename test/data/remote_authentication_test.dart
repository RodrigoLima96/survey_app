import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

import 'package:survey_app/domain/usecases/usecases.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({@required this.httpClient, @required this.url});

  Future<void> auth(AuthenticationParams authenticationParam) async {
    final body = {
      'email': authenticationParam.email,
      'password': authenticationParam.password,
    };
    httpClient.request(url: url, method: "post", body: body);
  }
}

abstract class HttpClient {
  Future<void> request({
    @required String url,
    @required String method,
    Map body,
  }) async {}
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  String email;
  String password;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    email = faker.internet.email();
    password = faker.internet.password();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should call HttClient with correct values', () async {
    final authenticationParams =
        AuthenticationParams(email: email, password: password);
    await sut.auth(authenticationParams);

    verify(httpClient.request(
      url: url,
      method: "post",
      body: {
        "email": authenticationParams.email,
        "password": authenticationParams.password,
      },
    ));
  });
}
