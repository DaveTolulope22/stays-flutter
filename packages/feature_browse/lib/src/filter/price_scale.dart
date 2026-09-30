/// The positions a price slider can rest on, built from the facet bounds.
///
/// A slider over 51 to 694 with a plain step would show values such as 137.42
/// or miss the exact bounds. Instead the positions are the two exact bounds and
/// every whole multiple of a step between them (60, 70, ... 690), so the
/// slider only ever shows tidy prices and both ends are still exactly the
/// cheapest and dearest listing. The gap next to a bound may be smaller than
/// the step (51 to 60); that is the price of keeping the bounds reachable.
///
/// The slider itself works on the position INDEX (0 to [divisions]), and this
/// class translates to and from prices.
class PriceScale {
  factory PriceScale({required num min, required num max}) {
    final step = stepFor(min, max);
    final points = <num>[min];
    if (max > min) {
      for (
        var next = ((min / step).floor() + 1) * step;
        next < max;
        next += step
      ) {
        points.add(next);
      }
      points.add(max);
    }
    return PriceScale._(List.unmodifiable(points));
  }

  const PriceScale._(this._points);

  final List<num> _points;

  /// The step between interior positions: 10 for a wide range, finer for a
  /// narrow one, so a small catalogue still has several positions.
  static num stepFor(num min, num max) {
    final range = max - min;
    if (range > 200) return 10;
    if (range > 50) return 5;
    return 1;
  }

  num get min => _points.first;
  num get max => _points.last;

  /// The number of intervals, which is what `RangeSlider.divisions` wants.
  /// Zero when the bounds are equal: there is nothing to choose.
  int get divisions => _points.length - 1;

  bool get isAdjustable => divisions >= 1;

  num valueAt(int index) => _points[index.clamp(0, divisions)];

  /// The position closest to [price], for a price that is between positions.
  int indexOf(num price) {
    var best = 0;
    for (var i = 1; i < _points.length; i++) {
      if ((_points[i] - price).abs() < (_points[best] - price).abs()) best = i;
    }
    return best;
  }
}
