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
  AuthenticationParams authenticationParams;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    email = faker.internet.email();
    password = faker.internet.password();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    authenticationParams =
        AuthenticationParams(email: email, password: password);
  });

  test('Should call HttClient with correct values', () async {
    when(httpClient.request(
            url: anyNamed('url'),
            method: anyNamed('method'),
            body: anyNamed('body')))
        .thenAnswer((_) async => {
              'accessToken': faker.guid.guid(),
              'name': faker.person.name(),
            });

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

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpetedError if HttpClient returns 404', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.notFound);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpetedError if HttpClient returns 500', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.serverError);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.unauthorized);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an AccountEntity if HttpClient returns 200', () async {
    final accessToken = faker.guid.guid();
    when(httpClient.request(
            url: anyNamed('url'),
            method: anyNamed('method'),
            body: anyNamed('body')))
        .thenAnswer((_) async => {
              'accessToken': accessToken,
              'name': faker.person.name(),
            });

    final account = await sut.auth(authenticationParams);

    expect(account.token, accessToken);
  });

  test(
      'Should throw UnexpetedError if HttpClient returns 200 with invalid data',
      () async {
    when(httpClient.request(
            url: anyNamed('url'),
            method: anyNamed('method'),
            body: anyNamed('body')))
        .thenAnswer((_) async => {
              'invalid_key': 'invalid_value',
            });

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });
}
