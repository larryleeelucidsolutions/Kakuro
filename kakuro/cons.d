/++
  This modules defines a set of functions that
  calculate kakuro sequence, element, and 
  index value constraints.

  Note:
  The following functions assume that sequences
  are in decreasing order unless otherwise stated.
++/

module kakuro.cons;

import math;
import std.conv;
import std.math;
import std.cstream;
import kakuro.seqs;

/// minimum index value:
const real MinIndex = 0;

/// maximum index value:
const real MaxIndex = 8;

/// maximum index value:
real maxIndex (real len) { return len - 1; }

/// minimum element value:
const real MinElem = 1;

/// minimum element value:
real minElemLen (real i, real len) { return len - i; }

/// minimum element value:
real minElem (real sum, real len) {
  const real ev = sum - maxSum (len - 1);
  return ev > 1 ? ev : 1;
}

/// minimum element value:
real minElem (real i, real sum, real len) {
  const real d = sum - minSum (len - i) - maxSum (i);
  const real m = minElemLen (i, len);
  return d > 0 ? m + std.math.ceil (d / m) : m;
}

/// maximum element value:
const real MaxElem = 9;

/// maximum element value:
real maxElem (real i) { return 9 - i; }

/// maximum element value:
real maxElem (real sum, real len) {
  const real so = sum - minSum (len);
  const real eo = 9 - len;
  return so > eo ? 9 : len + so;
}

/// maximum element value:
real maxElem (real i, real sum, real len) {
  real d = sum - minSum (len - i - 1) - maxSum (i + 1);
  real m = maxElem (i);
  return d < 0 ? m + std.math.floor (d / (i + 1)) : m;
}

/// returns the element value for the minimum delta sequence:
real minDeltaElem (real i, real sum, real len) {
  return std.math.ceil ((sum - minSum (len) - i) / len) + minElemLen (i, len);
}

/// minimum sequence sum:
const real MinSum = 1;

/// maximum sequence sum:
const real MaxSum = 45;

/// minumum sequence sum:
real minSum (real len) {
  return (len * (len + 1)) / 2;
}

/// maximum sequence sum:
real maxSum (real len) {
  return (len * 9) - ((len * (len - 1)) / 2);
}

/// minimum sequence length:
const real MinLen = 1;

/// maximum sequence length:
const real MaxLen = 9;

/// minimum sequence length:
real minLen (real sum) {
  return std.math.ceil (9.5 - std.math.sqrt (90.25 - (2 * sum)));
}

/// maximum sequence length:
real maxLen (real sum) {
  return std.math.floor (std.math.sqrt (.25 + (2 * sum)) - .5);
}

/// number of sequences:
const real Nseqs = 511;

/// number of sequences with the same sum:
real nseqsSum (real sum) {
  real nseqs = 0;
  for (
    real len = kakuro.cons.MinLen;
    len <= kakuro.cons.MaxLen;
    len ++
  ) {
    nseqs += kakuro.cons.nseqs (sum, len);
  }
  return nseqs;
}

/// returns the number of sequences that have the given length:
real nseqsLen (real len) {
  return math.product! (real, real) (
    len - 1, 0,
    delegate real (real x) {
      return ((10 - len) + x) / (len - x);
    }
  );
}

/// number of sequences with the same sum and length:
real nseqs (real sum, real len) {
  real nseqs = 0;
  kakuro.seqs.iterate (
    kakuro.cons.MaxLen, sum, len,
    delegate void (real rem, real elem) {
      if (rem == 1) nseqs ++;
    }
  );
  return nseqs;
}

/// returns the sum of the given sequence:
real sum (real[] seq) {
  real sum = 0;
  foreach (real elem; seq) { sum += elem; }
  return sum;
}

/// returns the sum of the sequence's delta vector:
real delta (real[] seq) {
  real d = 0;
  for (uint i = 1; i < seq.length; i ++) {
    d += seq [i - 1] - seq [i];
  }
  return d;
}

/// returns the number of sums that can be represented by sequences that have the given length.
real nsumsLen (real len) {
  return len * (9 - len) + 1;
}

/++
  returns the sum that has the maximum number of possible sequences for the given length.
  note: for most lengths, this value is not unique.
++/
real sumMaxSeqs (real len) {
  return 5 * len;
}

unittest {
  std.cstream.derr.writeLine ("kakuro.cons.unittest");

  // test maxIndex (real):
  assert (maxIndex (1) == 0);

  // test minElemLen (real, real):
  assert (minElemLen (0, 1) == 1);
  assert (minElemLen (3, 4) == 1);

  // test minElem (real, real):
  assert (minElem (1, 1)  == 1);
  assert (minElem (9, 1)  == 9);
  assert (minElem (10, 2) == 1);
  assert (minElem (17, 2) == 8);
  assert (minElem (45, 9) == 1);
  assert (minElem (7, 3)  == 1);
  assert (minElem (19, 3) == 2);

  // test minElem (real, real, real):
  assert (minElem (0, 5, 1)  == 5);
  assert (minElem (1, 15, 4) == 3);
  assert (minElem (0, 15, 4) == 6);
  assert (minElem (1, 28, 4) == 8);
  assert (minElem (3, 45, 9) == 6);

  // test maxElemLen (real):
  assert (maxElem (0) == 9);
  assert (maxElem (4) == 5);
  assert (maxElem (8) == 1);

  // test maxElem (real, real):
  assert (maxElem (1, 1)  == 1);
  assert (maxElem (9, 1)  == 9);
  assert (maxElem (45, 9) == 9);
  assert (maxElem (10, 4) == 4);
  assert (maxElem (23, 6) == 8);

  // test maxElem (real, real, real):
  assert (maxElem (0, 3, 1) == 3);
  assert (maxElem (1, 12, 3) == 5);
  assert (maxElem (2, 21, 4) == 5);
  assert (maxElem (1, 21, 4) == 8);
  assert (maxElem (2, 27, 6) == 6);

  // test minDeltaElem (real, real, real):
  assert (minDeltaElem (0, 1, 1) == 1);
  assert (minDeltaElem (0, 9, 1) == 9);
  assert (minDeltaElem (0, 45, 9) == 9);
  assert (minDeltaElem (2, 15, 3) == 4);
  assert (minDeltaElem (1, 17, 4) == 5);
  assert (minDeltaElem (3, 34, 6) == 5);

  // test minSum (real):
  assert (minSum (1) == 1);
  assert (minSum (9) == 45);
  assert (minSum (4) == 10);
  assert (minSum (6) == 21);

  // test maxSum (real):
  assert (maxSum (1) == 9);
  assert (maxSum (9) == 45);
  assert (maxSum (4) == 30);
  assert (maxSum (7) == 42);

  // test minLen (real):
  assert (minLen (1)  == 1);
  assert (minLen (45) == 9);
  assert (minLen (10) == 2);
  assert (minLen (30) == 4);

  // test maxLen (real):
  assert (maxLen (1)  == 1);
  assert (maxLen (45) == 9);
  assert (maxLen (10) == 4);
  assert (maxLen (22) == 6);

  // test nseqsLen (real):
  assert (nseqsLen (1) == 9);
  assert (nseqsLen (9) == 1);
  assert (nseqsLen (2) == 36);

  // test delta (real[]):
  assert (delta ([9]) == 0);
  assert (delta ([9, 8]) == 1);
  assert (delta ([6, 5]) == 1);
  assert (delta ([9, 8, 7]) == 2);

  // test nsumsLen (real):
  assert (nsumsLen (1) == 9);
  assert (nsumsLen (9) == 1);
  assert (nsumsLen (8) == 9);
  assert (nsumsLen (3) == 19);
  assert (nsumsLen (5) == 21);
}
