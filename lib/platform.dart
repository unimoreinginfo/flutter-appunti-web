import 'package:http/browser_client.dart' as http;

import 'io.dart';
import 'webio.dart';


// Web
final httpClient = http.BrowserClient(); // unused atm while analyzing the cookies issue
final TokenStorage tokenStorage = LocalStorageTokenStorage();