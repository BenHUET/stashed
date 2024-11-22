import 'package:auth_repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:servers_repository/servers_repository.dart';

class AppDioInterceptor extends Interceptor {
  final Logger logger;
  final AuthRepository authRepository;
  final ServersRepository serversRepository;

  const AppDioInterceptor({required this.logger, required this.authRepository, required this.serversRepository});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final serverAddress = Uri(scheme: options.uri.scheme, host: options.uri.host, port: options.uri.port);
    final manifest = serversRepository.getServerByAddress(serverAddress).manifest;

    if (manifest != null && manifest.authEnabled) {
      try {
        final token = await authRepository.getAccessToken(options.uri.host);
        options.headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        logger.log(Level.FINEST, 'Failed to get access token for ${options.uri.host} (${e.toString()})');
      }
    }

    logger.log(Level.FINEST, '${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.log(Level.FINE, '${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.log(Level.WARNING, '${err.response?.statusCode} ${err.requestOptions.path} (${err.message})');
    super.onError(err, handler);
  }
}
