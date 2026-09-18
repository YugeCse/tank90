/// List的扩展类
extension ListExtensions<T> on List<T> {
  /// 替换所有元素
  /// + [inputs] - 输入的内容
  List<T> replaceAll(List<T> inputs) {
    clear();
    addAll(inputs);
    return this;
  }
}
