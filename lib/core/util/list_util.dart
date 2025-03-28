Future<List<R>> mapListAsync<T, R>(List<T> list, Future<R> Function(T) mapper) async {
  return await Future.wait(list.map(mapper));
}
