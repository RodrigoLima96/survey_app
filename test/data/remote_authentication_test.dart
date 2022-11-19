import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:survey_app/domain/usecases/usecases.dart';
import 'package:survey_app/domain/helpers/helpers.dart';

import 'package:survey_app/data/usecases/usecases.dart';
import 'package:survey_app/data/http/http.dart';

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

  test('Should throw UnexpetedError if HttpClient returns 400', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.badRequest);

    final authenticationParams =
        AuthenticationParams(email: email, password: password);
    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });
}
