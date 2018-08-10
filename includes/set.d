/// This module defines functions for manipulating sets:

module set;

import std.conv;
import std.math;

/// returns {x | f(x) and x elementOf set}:
T[] filter (T) (T[] set, bool function (T) f) {
  T[] res;
  foreach (T elem; set) {
    if (f (elem)) res ~= elem;
  }
  return res;
}

/// returns {x | f(x, param) and x elementOf set}:
T[] filter (T, U) (T[] set, U param, bool function (T, U) f) {
  T[] res;
  foreach (T elem; set) {
    if (f (elem, param)) res ~= elem;
  }
  return res;
}

/// returns true if the set contains duplicate values:
bool redundant (T) (T[] set) {
  for (uint i; i < set.length; i ++) {
    for (uint j = i + 1; j < set.length; j ++) {
      if (set [i] == set [j]) return true;
    }
  }
  return false;
}

/// returns true if the given set (s) is empty:
bool empty (T) (T[] set) {
  return set.length == 0;
}

/// returns true if the given element is a member of the given set:
bool member (T) (T[] set, T elem) {
  foreach (T _elem; set) { if (elem == _elem) return true; }
  return false;
}

/// adds the given element e to the set s:
T[] add (T) (T[] set, T elem) {
  return member (set, elem) ? set : set ~ [elem];
}

/// returns true if set a is a subset of set b:
bool subset (T) (T[] a, T[] b) {
  if (a.length >= b.length) return false;
  foreach (T elem; a) { if (!member (b, elem)) return false; }
  return true;
}

/// returns true if set a is a proper subset of set b:
bool properSubset (T) (T[] a, T[] b) {
  if (a.length > b.length) return false;
  foreach (T elem; a) { if (!member (b, elem)) return false; }
  return true;
}

/// returns true if set a and set b are disjoint:
bool disjoint (T) (T[] a, T[] b) {
  foreach (T elem; a) { if (member (b, elem)) return false; }
  return true;
}

/// returns the union of set a and b:
T[] _union (T) (T[] a, T[] b) {
  T[] res = a.dup;
  foreach (T elem; b) { if (!member (res, elem)) res ~= elem; }
  return res;
}

/// returns the union of sets:
T[] _union (T) (T[][] sets) {
  T[] res;
  foreach (T[] set; sets) { res = _union (res, set); }
  return res;
}

/// returns the intersection of set a and b:
T[] intersection (T) (T[] a, T[] b) {
  T[] res;
  foreach (T elem; a) { if (member (b, elem)) res ~= elem; }
  return res;
}

/// returns the intersection of sets:
T[] intersection (T) (T[][] sets) {
  T[] res;

  if (sets.length) res = sets [0].dup;
  if (sets.length > 1) {
    foreach (T[] set; sets [1 .. length]) {
      res = intersection (res, set);
    }
  }

  return res;
}

/// returns the difference between set a and b:
T[] difference (T) (T[] a, T[] b) {
  T[] res;
  foreach (T elem; a) { if (!member (b, elem)) res ~= elem; }
  return res;
}

/// removes any repeated elements:
T[] toSet (T) (T[] array) {
  T[] res;
  foreach (T elem; array) { res = add (res, elem); }
  return res;
}

unittest {
  // test filter (T) (T[]):

  // assert (filter! (uint) ([4, 5, 6, 7], function bool (uint x) { return (x > 5); }) == cast (uint []) [6, 7]);

  // test empty (T) (T[]):

  assert (empty ([]));

  assert (!empty ([1]));

  // test member (T) (T[], T):

  assert (member! (int) ([0, 1, 2], 2));

  assert (!member! (int) ([0, 1, 2], 3));

  assert (!member! (int) (cast (int []) [], 0));

  // test add (T) (T[], T):

  assert (add! (int) ([], 1) == [1]);

  assert (add! (int) ([1], 1) == [1]);

  assert (add! (int) ([2, 6, 71], 12) == [2, 6, 71, 12]);

  assert (add! (int) ([31, 23, 6], 31) == [31, 23, 6]);

  // test subset (T) (T[], T[]):

  assert (subset ([0, 1, 2], [0, 1, 2, 3]));

  assert (!subset ([0, 1], [0, 1]));

  assert (subset (cast (int []) [], [0, 1]));

  // TODO: check subset definition.
  // assert (subset (cast (int []) [], cast (int []) []));

  // test properSubset (T) (T[], T[]):

  assert (properSubset ([0], [0, 1, 2]));

  assert (properSubset ([0, 1], [0, 1]));

  assert (properSubset (cast (int []) [], cast (int []) []));

  // test disjoint (T) (T[], T[]):

  assert (disjoint ([0, 1, 2], [3, 4, 5]));

  // TODO: check disjoint definition:
  // assert (!disjoint (cast (int []) [], cast (int []) []));

  // test _union (T) (T[], T[]):

  assert (_union ([0, 1], [2]) == [0, 1, 2]);

  assert (_union ([0, 1, 2], [0, 1, 2, 3]) == [0, 1, 2, 3]);

  assert (_union (cast (int []) [], [0, 1, 2]) == [0, 1, 2]);

  assert (_union (cast (int []) [], cast (int []) []) == cast (int []) []);

  // test intersection (T) (T[], T[]):

  assert (intersection ([0, 1, 2], [2, 3, 4]) == [2]);

  assert (intersection (cast (int []) [], cast (int []) []) == cast (int []) []);

  // test difference (T) (T[], T[]):

  assert (difference ([0, 1, 2], [0, 1]) == [2]);
}
