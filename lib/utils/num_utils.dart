extension IntExtension on int {
  int atMost(int maxmum) => this > maxmum ? maxmum : this;

  int atLeast(int minimum) => this < minimum ? minimum : this;
}

extension DoubleExtension on double {
  double atMost(double maxmum) => this > maxmum ? maxmum : this;

  double atLeast(double minimum) => this < minimum ? minimum : this;
}
