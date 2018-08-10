/// defines standard mathmatical operations:

module math;
import std.cstream;

/// returns f (i) * f (i + 1) * ... * f (n):
U product (T, U) (T n, T i, U delegate (T) f) {
  return i <= n ? f (i) * product (n, i + 1, f) : 1;
}

/// returns f (i) + f (i + 1) + ... + f (n):
T sum (T, U) (T n, T i, U delegate (T) f) {
  return i <= n ? f (i) + sum (n, i + 1, f) : 0;
}

// Executes the unit tests.
unittest {
  std.cstream.derr.writeLine ("math.unittest");

  // test U product (T, U):
  assert (product (3, 1, delegate int (int x) { return x; }) == 6);

  // test U sum (T, U):
  assert (sum (3, 0, delegate int (int x) { return x; }) == 6);
}
