/// This module defines functions for manipulating arrays:

module array;

import std.string;

/// executes the given function once for each element in the given array:
T[] map (T) (T delegate (T elem) f, T[] array) {
  T[] res = new T [array.length];
  for (uint i; i < res.length; i ++) {
    res [i] = f (array [i]);
  }
  return res;
}

/++
  executes the given function once for each
  element in the given array and removes any
  elements for which the given function
  returns false:
++/
T[] filter (T) (T delegate (T elem) f, T[] array) {
  T[] res;
  foreach (T elem; array) {
    if (f (elem)) res ~= elem;
  }
  return res;
}

/// appends elem onto the end of every array in arrays:
T[][] append (T) (T[][] arrays, T elem) {
  T[][] res = new T [][arrays.length];
  for (uint i; i < res.length; i ++) {
    res [i] = arrays [i] ~ [elem];
  }
  return res;
}

/// prepends elem onto every array in arrays:
T[][] prepend (T) (T elem, T[][] arrays) {
  T[][] res = new T [][arrays.length];
  for (uint i; i < res.length; i ++) {
    res [i] = [elem] ~ arrays [i];
  }
  return res;
}

/// returns a string that represents the given array:
string display (T) (uint ntabs, T[] array) {
  string res = std.string.repeat ("\t", ntabs) ~ "[";

  foreach (uint i, T elem; array) {
    res ~= std.conv.to! (string) (elem);
    if (i < array.length - 1) res ~= ", ";
  }

  return res ~ "]";
}

/// returns a string that represents the given arrays:
string display (T) (uint ntabs, T[][] arrays) {
  string tabs = std.string.repeat ("\t", ntabs);

  string res = tabs ~ "[\n";
  foreach (uint i, T[] array; arrays) {
    res ~= display (ntabs + 1, array);
    res ~= (i < arrays.length - 1) ? ",\n" : "\n"; 
  }

  return res ~ tabs ~ "]\n";
}
