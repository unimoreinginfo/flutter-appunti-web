import 'package:dio/adapter_browser.dart';
import 'package:dio/browser_imp.dart';

final baseUrl = "https://beta.emilianomaccaferri.com";

// not a constant but has to stay here for the time being
var adapter = BrowserHttpClientAdapter()..withCredentials = true;
var http = DioForBrowser()..httpClientAdapter = adapter;
