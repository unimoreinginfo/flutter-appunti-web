// remote errors

const USER_EXISTS = 409;
const NOT_FOUND = 404;
const INVALID_CREDENTIALS = 401;
const EXPIRED_CREDENTIALS = 401;
const MALFORMED_CREDENTIALS = 400;
const GENERIC_ERROR = 500;
const SERVER_DOWN = 502;

// client errors

class BackendError implements Exception {
  BackendError(this.code);

  int code;
}

class NotFoundError implements Exception {

}

class ServerError implements Exception {
  
}

class NetworkError implements Exception {
  
}
