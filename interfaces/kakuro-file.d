/++
  This program solves kakuro puzzles.
++/

module kakuro_file;

import set;
import kakuro.cons;
import kakuro.core;
import kakuro.checks;

import std.algorithm;
import std.conv;
import std.cstream;
import std.file;
import std.getopt;
import std.regexp;
import std.stream;

void main (string[] args) {
  bool help;

  getopt (args, "h|help", &help);

  if (help) {
    std.cstream.dout.writeLine (
      "                                              \n" ~
      "Usage file [<options>] <input file>           \n" ~
      "                      [<output file>]       \n\n" ~

      "Synopsis:                                     \n" ~
      "  file solves kakuro puzzles. The             \n" ~
      "  input file contains a description of        \n" ~
      "  a kakuro puzzle. file tries to              \n" ~
      "  solve the puzzle and returns the            \n" ~
      "  result. If the output file parameter        \n" ~
      "       is included, the element values will   \n" ~
      "  also be written to the output file.       \n\n" ~

      "  file is the file interface for the          \n" ~
      "  kakuro module.                            \n\n" ~

      "Options:                                      \n" ~
      "  [-h|--help]                                 \n" ~
      "    display usage information.              \n\n" ~

      "The Input File:                               \n" ~
      "  The input file must comply with the         \n" ~
      "  following grammar:                        \n\n" ~

      "  file := <elements declaration> \'\\n\'      \n" ~
      "    <sequence declarations>                   \n" ~
      "  elements declaration := <integer>           \n" ~
      "  sequence declarations :=                    \n" ~
      "    \'sum:\' <integer>                        \n" ~
      "    \'elems:\' <integer list>                 \n" ~
      "    (\'vals:\' <integer list>)?               \n" ~
      "    \\n\'                                     \n" ~
      "  integer list := <integer>                   \n" ~
      "    (, <integer>)?                          \n\n" ~
 
      "  The element declaration consists of a  \n" ~
      "  single integer. This integer           \n" ~
      "  represents the number of squares in    \n" ~
      "  the puzzle grid. These squares are     \n" ~
      "  refered to as sequence elements.     \n\n" ~

      "  The sequence declarations have three   \n" ~
      "  parts; the sum, elements, and values   \n" ~
      "  statements. The sum represents the     \n" ~
      "  sequence\'s sum. The elements -        \n" ~
      "  the id numbers for the elements        \n" ~
      "  contained within the sequence. The     \n" ~
      "  values statement is optional and lists \n" ~
      "  the possible element values.         \n\n" ~

      "  If the values statement is omitted,    \n" ~
      "  this program assumes that the elements \n" ~
      "  can equal any value from 1 to 9.     \n\n" ~

      "  If the sum equals 0, this program will \n" ~
      "  assume that the sum is unknown. This   \n" ~
      "  is usefull when a file represents a    \n" ~
      "  part of a larger puzzle.             \n\n" ~

      "Example:                                 \n" ~
      "  4                                      \n" ~
      "  sum: 3 elems: 0, 2                     \n" ~
      "  sum: 4 elems: 1, 3                     \n" ~
      "  sum: 4 elems: 0, 1                     \n" ~
      "  sum: 3 elems: 2, 3                   \n\n" ~

      "  This input file would describe the     \n" ~
      "  following puzzle grid:               \n\n" ~

      "                       4 3               \n" ~
      "                      +-+-+              \n" ~
      "                    3 |0|2|              \n" ~
      "                      +-+-+              \n" ~
      "                    4 |1|3|              \n" ~
      "                      +-+-+            \n\n"

      "  6                                      \n" ~
      "  sum: 0  elems: 0 vals: 6, 8, 9         \n" ~
      "  sum: 9  elems: 1, 2                    \n" ~
      "  sum: 12 elems: 3, 4                    \n" ~
      "  sum: 0  elems: 5                       \n" ~
      "  sum: 20 elems: 1, 3, 5                 \n" ~
      "  sum: 14 elems: 0, 2, 4               \n\n" ~

      "  This input file represents:          \n\n" ~

      "                              14         \n" ~
      "                            +----+       \n" ~
      "                       20\? | 0  |       \n" ~
      "                       +----+----+       \n" ~
      "                    9  | 1  | 2  |       \n" ~
      "                       +----+----+       \n" ~
      "                    12 | 3  | 4  |       \n" ~
      "                       +----+----+       \n" ~
      "                     ? | 5  |            \n" ~
      "                       +----+          \n\n" ~

      "  Where element 0 can equal 6, 8, or 9.  \n" ~
      "  And the sum for sequence 0 and         \n" ~
      "  sequence 4 are unknown.              \n\n"
    );

    return;
  }

  if (args.length < 2) {
    throw new Exception ("invalid command line (missing input file name).");
  }

  Puzzle puzzle = parse (cast (string) std.file.read (args [1]));

  puzzle.solve ();

  if (args.length == 3) {
    std.stream.File file = new std.stream.File (args [2], FileMode.Out);

    writeElems (file, puzzle.elems);

    file.close ();
  }
  else {
    writeElems (std.cstream.dout, puzzle.elems);
  }
}

/// parse sequence definitions:
Puzzle parse (string file) {
  // [1] remove comments:

  RegExp comment = new RegExp ("#[^\n]*\n", "g");

  file = comment.replace (file, "\n");

  // [2] remove empty lines:

  RegExp empty = new RegExp ("\n\\s*\n", "g");

  file = empty.replace (file, "\n");

  // [3] get lines:

  string[] lns = std.string.splitlines (file);

  // [4] get elements declaration:

  if (lns.length < 1) throw new Exception ("syntax error: missing elements declaration line.");

  RegExp decl = new RegExp ("^\\s*(\\d+)\\s*$");

  if (!decl.test (lns [0])) throw new Exception ("syntax error: invalid elements declaration line.");

  Elem[] elems = new Elem [std.conv.to! (uint) (decl [1])];

  foreach (ref Elem elem; elems)
  {
    elem = new Elem ();
  }

  // [5] get sequence definitions:

  if (lns.length < 2) throw new Exception ("syntax error: missing sequence declaration line(s).");

  kakuro.core.Seq[] seqs;

  RegExp def = new RegExp ("^\\s*sum:\\s*(\\d+)\\s*elems:\\s*(\\d+\\s*(,\\s*\\d+)*)\\s*(vals:\\s*(\\d+\\s*(,\\s*\\d+)*))?");

  RegExp digits = new RegExp ("\\d+", "g");

  foreach (string ln; lns [1 .. $ - 1]) {
    if (!def.test (ln)) throw new Exception ("syntax error: (invalid seq definition: " ~ ln ~ ")." );

    kakuro.core.Elem[] seqElems;

    foreach (string m; digits.match (def [2])) {
      uint i = std.conv.to! (uint) (m);

      if (i > elems.length) throw new Exception ("invalid element index: " ~ ln ~ ".");

      seqElems ~= elems [i];
    }

    real sum = std.conv.to! (real) (def [1]);

    if (def [4]) {
      real[] vals;

      foreach (string m; digits.match (def [5])) {
        vals ~= std.conv.to! (real) (m);
      }

      seqs ~= new kakuro.core.Seq (sum, seqElems, vals);
    }
    else {
      if (sum) {
        seqs ~= new kakuro.core.Seq (sum, seqElems);
      }
      else {
        seqs ~= new kakuro.core.Seq (seqElems);
      }
    }
  }

  // [6] return puzzle:

  return new Puzzle (elems, seqs);
}

/// writes the element values to the given stream:
void writeElems (std.stream.Stream stream, Elem[] elems) {
  foreach (uint i, Elem elem; elems) {
    std.algorithm.sort (elem.vals);
    stream.writefln ("%s: %s", i, elem.vals);
  }
}
