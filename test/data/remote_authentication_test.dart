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

  Map mockValidData() => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name(),
      };

  PostExpectation mockRequest() => when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body')));

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    email = faker.internet.email();
    password = faker.internet.password();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    authenticationParams =
        AuthenticationParams(email: email, password: password);
    mockHttpData(mockValidData());
  });

  test('Should call HttClient with correct values', () async {
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
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpetedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpetedError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an AccountEntity if HttpClient returns 200', () async {
    final validData = mockValidData();
    mockHttpData(validData);

    final account = await sut.auth(authenticationParams);

    expect(account.token, validData['accessToken']);
  });

  test(
      'Should throw UnexpetedError if HttpClient returns 200 with invalid data',
      () async {
    mockHttpData({'invalid_key': 'invalid_value'});

    final future = sut.auth(authenticationParams);

    expect(future, throwsA(DomainError.unexpected));
  });
}
