import 'package:servers_repository/servers_repository.dart';

extension ModelServerExtensions on Server {
  bool get isLocalhost => address.host == 'localhost';
}
