import 'package:fluro/fluro.dart';
import 'package:dio/adapter_browser.dart';
import 'package:dio/browser_imp.dart';
import 'package:dio/dio.dart';

final baseUrl = "https://api.appunti.me";

const emailRegex =
    r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""";

const passwordRegex = r""".{8,}$""";

const allowedMimeTypes = [
  "text/plain",
  "application/pdf",
  "application/msword", // doc
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // docx
  "application/vnd.oasis.opendocument.text", // odt
  "image/jpeg",
  "image/png",
  "application/zip",
  "application/x-7z-compressed",
  "application/gzip",
  "application/x-xz",
  "application/x-bzip2"
];

// not constsnts but have to stay here for the time being

var adapter = BrowserHttpClientAdapter()..withCredentials = true;
var http = DioForBrowser(BaseOptions(
    validateStatus: (status) => true,
    contentType: Headers.formUrlEncodedContentType,
    responseType: ResponseType.plain))
  ..httpClientAdapter = adapter;

final router = Router();
