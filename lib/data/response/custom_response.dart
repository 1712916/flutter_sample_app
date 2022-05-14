//json format
// {
//   'message': 'message',
//   'data': [],
// }
class CustomResponse<T> {
  final int? statusCode;
  final T? data;
  final String? message;

  CustomResponse({this.statusCode, this.data, this.message});
}