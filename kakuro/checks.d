/++
  This module defines a set of functions that
  check kakauro sequence, element, and index
  values.
++/

module kakuro.checks;

import kakuro.cons;

/// check sequence sum:
static bool checkSum (real sum) {
  return sum >= 1 && sum <= 45;
}

/// check sequence sum:
static bool checkSum (real sum, real len) {
  return sum >= kakuro.cons.minSum (len) &&
         sum <= kakuro.cons.maxSum (len);
}

/// check sequence length:
static bool checkLen (real len) {
  return len >= 1 && len <= 9;
}

/// check sequence length:
static bool checkLen (real sum, real len) {
  return len >= kakuro.cons.minLen (sum) &&
         len <= kakuro.cons.maxLen (sum);
}

/// check sequence sum and length:
static bool check (real sum, real len) {
  return  checkSum (sum)      &&
          checkLen (len)      &&
          checkSum (sum, len) &&
          checkLen (sum, len);
}
