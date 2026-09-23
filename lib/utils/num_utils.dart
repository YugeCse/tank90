extension IntExtension on int {
  /// 对一个数字进行切割，返回组成的集合
  List<int> spiltToList() {
    var n = this;
    List<int> result = [];
    while (n > 0) {
      result.add(n % 10);
      n ~/= 10;
    }
    return result.reversed.toList();
  }

  int atMost(int maxmum) => this > maxmum ? maxmum : this;

  int atLeast(int minimum) => this < minimum ? minimum : this;
}

extension DoubleExtension on double {
  double atMost(double maxmum) => this > maxmum ? maxmum : this;

  double atLeast(double minimum) => this < minimum ? minimum : this;
}
