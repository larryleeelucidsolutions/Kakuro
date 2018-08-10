/++
  This module defines class that represent
  kakuro puzzles, elements, and sequences.

  These classes can be used to resolve
  kakuro puzzles, sequences, and elements.
++/

module kakuro.core;

import set;
import kakuro.cons;
import kakuro.seqs;

import std.perf;
import std.cstream;

/// sequence elements:
class Elem {
  Seq[] seqs; /// sequences.
  real[] vals; /// values.

  /// defines an element:
  this () {}

  /// defines an element:
  this (Seq[] seqs, real[] vals) {
    this.seqs = seqs;
    this.vals = vals;
  }

  /// initialize values set:
  void init () {
    this.vals = set.intersection (
      this.seqs [0].vals,
      this.seqs [1].vals
    );
  }
}

/// sequences:
class Seq {
  real sum;     /// sum.
  Elem[] elems; /// elements.
  real[] vals;  /// set of possible element values.

  /// defines a sequence:
  this (real sum, Elem[] elems, real[] vals) {
    this.sum = sum;
    this.elems = elems;

    foreach (ref elem; elems) {
      elem.seqs ~= this;
    }

    this.vals = vals;
  }

  /// defines a sequence:
  this (Elem[] elems) {
    this (0, elems, [9, 8, 7, 6, 5, 4, 3, 2, 1]);
  }

  /// defines a sequence:
  this (real sum, Elem[] elems) {
    this (sum, elems, kakuro.seqs.elems (sum, elems.length));
  }

  /// tries to resolve this sequence and returns true
  /// if it reduced the number of possible element values:
  bool resolve () {
    uint nvals;

    // I. get the array that represents this.elems:
    
    real[][] elems = new real [][this.elems.length];

    for (uint i; i < this.elems.length; i ++) {
      nvals += this.elems [i].vals.length;
      elems [i] = this.elems [i].vals;
      this.elems [i].vals = new real [0];
    }

    // II. resolve this sequence:

    real[][] res = kakuro.seqs.seqs (this.sum, elems);

    // III. update the element values:

    uint _nvals;

    for (uint i; i < res.length; i ++) {
      _nvals += res [i].length;

      for (uint j; j < res [i].length; j ++) {
        this.elems [j].vals = set.add (this.elems [j].vals, res [i][j]);
      }
    }

    // IV. return status:
    return _nvals < nvals;
  }
}

/// puzzle:
class Puzzle {
  Elem[] elems; /// elements.
  Seq[]  seqs;  /// sequences.

  /// defines a puzzle:
  this (Elem[] elems, Seq[] seqs) {
    this.elems = elems;
    this.seqs  = seqs;
    this.init ();
  }

  /// initialize:
  void init () {
    // initialize element values:
    foreach (Elem elem; this.elems) { elem.init (); }
  }

  /// tries to resolve the sequences and returns
  /// true if it resolved at least one of the sequences:
  bool resolve () {
    bool reduced;

    foreach (Seq seq; this.seqs) {
      if (seq.sum != 0 && seq.resolve ()) reduced = true;
    }

    return reduced;
  }

  /// tries to solve this puzzle:
  void solve () {
    while (this.resolve ()) {}
  }
}
