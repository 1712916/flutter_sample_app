import 'dart:async';

/// Đo thời gian thực thi của một hàm đồng bộ (sync function)
void measureExecutionTimeSync(Function function) {
  final stopwatch = Stopwatch()..start();
  function();
  stopwatch.stop();
  print('Thời gian thực thi (sync): ${stopwatch.elapsedMilliseconds} ms');
}

/// Đo thời gian thực thi của một hàm bất đồng bộ (async function)
Future<void> measureExecutionTime(Future<void> Function() function) async {
  final stopwatch = Stopwatch()..start();
  await function();
  stopwatch.stop();
  print('Thời gian thực thi (async): ${stopwatch.elapsedMilliseconds} ms');
}

/// Ví dụ: Hàm sync cần đo thời gian
void calculateSum() {
  int sum = 0;
  for (int i = 0; i < 1000000; i++) {
    sum += i;
  }
}

/// Ví dụ: Hàm async cần đo thời gian
Future<void> fetchData() async {
  await Future.delayed(Duration(seconds: 2)); // Giả lập API call
  print("Dữ liệu đã tải xong!");
}

/// Hàm main để test
void main() async {
  print("🔹 Đo thời gian thực thi hàm đồng bộ:");
  measureExecutionTimeSync(calculateSum);

  print("\n🔹 Đo thời gian thực thi hàm bất đồng bộ:");
  await measureExecutionTime(fetchData);
}
