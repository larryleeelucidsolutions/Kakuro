/++
  Displays information concerning the kakuro
  sequences that fullfill the given constraints.
++/

module kakuro_cmd;

import set;
import matrix;
import kakuro.cons;
import kakuro.seqs;
import kakuro.checks;

import std.conv;
import std.regexp;
import std.getopt;
import std.cstream;

void main (string[] args) {
  real   sum;
  real   len;
  string exp;
  bool   setSum;
  bool   setLen;
  bool   setElems;
  bool   help;

  // set parameter value:
  void setParams (string option, string value) {
    if (!value.length) throw new Exception ("missing " ~ option ~ " value.");

    switch (option) {
      case "s|sum":
        setSum = true;
        sum = std.conv.to! (uint) (value);
        break;
      case "l|len":
        setLen = true;
        len = std.conv.to! (uint) (value);
        break;
      case "e|elems":
        setElems = true;
        exp = value;
        break;
      default:
        throw new Exception ("invalid option string.");
    }
  }

  // get command line options:
  getopt (
    args,
    "s|sum", &setParams,
    "l|len", &setParams, 
    "h|help" , &help,
    "e|elems", &setParams
  );

  if (help) {
    std.cstream.dout.writeLine (
      "                                                 \n" ~
      "Usage: kakuro-cmd [<options>] <constraints>    \n\n" ~

      "Synopsis:                                        \n" ~
      "  kakuro-cmd will display the set of             \n" ~
      "       kakuro sequences that fulfill the given   \n" ~
      "  constraints.                                 \n\n" ~

      "  kakuro-cmd is the command line interface       \n" ~
      "  for the kakuro module.                       \n\n" ~

      "Options:                                         \n" ~
      "  [-h|--help]                                    \n" ~
      "    display usage information.                 \n\n" ~

      "Constraints:                                     \n" ~
      "  [-s|--sum] <sum>                               \n" ~
      "    instructs kakuro-cmd to only                 \n" ~
      "    display sequences that have the              \n" ~
      "    given sum.                                 \n\n" ~    

      "  [-l|--len] <length>                           \n" ~
      "    instructs kakuro-cmd to only                \n" ~
      "    display sequences that have the             \n" ~
      "    given length.                             \n\n" ~

      "  [-e|--elems] <integer sets>                   \n" ~
      "    each set represents an element              \n" ~
      "    within the sequence. kakuro-cmd             \n" ~
      "    will only display sequences that            \n" ~
      "    contain at least one of the                 \n" ~
      "    values from each set.                     \n\n" ~

      "Examples:                                       \n" ~
      "  kakuro-cmd --sum=10 --len=4                   \n" ~
      "    instructs kakuro-cmd to display             \n" ~
      "  every kakuro sequence that has a sum          \n" ~
      "  equal to 10, and a length equal to 4.       \n\n" ~

      "  kakuro-cmd -s=10 -l=3 -e=\"[[1],[2,3]]\"      \n" ~
      "    instructs kakuro-cmd to display             \n" ~
      "  every kakuro sequence that has a sum          \n" ~
      "  equal to 10, and three elements. It           \n" ~
      "  will only display those sequences where       \n" ~
      "  the first element equals 1, and the           \n" ~
      "  second element is either 2 or 3.            \n\n" ~

      "  kakuro-cmd -s=13 -l=2 -e\"[[5]]\"             \n" ~
      "    instructs kakuro-cmd to display             \n" ~
      "  every kakuro sequence that has a sum          \n" ~
      "  equal to 13, and 2 elements. It will          \n" ~
      "  only display those sequences that have        \n" ~
      "  a 5. The only solution is [8, 5]. It          \n" ~
      "  will return [[5, 8]].                       \n\n"
    );

    return;
  }

  real[][] seqs;

  if (!setElems) {
    if (setSum && setLen && kakuro.checks.check (sum, len)) {
      seqs = kakuro.seqs.seqs (sum, len);
    }
    else if (setSum && !setLen && kakuro.checks.checkSum (sum)) {
      seqs = kakuro.seqs.sameSum (0, sum);
    }
    else if (!setSum && setLen && kakuro.checks.checkLen (len)) {
      seqs = kakuro.seqs.sameLen (0, len);
    }
    else if (!setSum && !setLen) {
      seqs = kakuro.seqs.all ();
    }
  }
  else { // setElems:
    seqs = kakuro.seqs.seqs (sum, len, getElems (exp));

    std.cstream.dout.writeLine ("squares:");
    foreach (real[] sqr; matrix.transpose (seqs)) {
      std.cstream.dout.writeLine (array.display (0, set.toSet (sqr).sort));
    }
  }

  std.cstream.dout.writeLine ("elems:");
  std.cstream.dout.writef (array.display! (real) (0, set._union (seqs).sort));

  std.cstream.dout.writeLine ("seqs:");
  std.cstream.dout.writef (array.display! (real) (0, seqs));

  std.cstream.dout.writefln ("number of seqs: %s", seqs.length);
}

/// get element values:
real[][] getElems (string exp) {
  const string valsRegExp = "(\\[\\d(,\\d)*\\])";

  const string elemsRegExp = "(\\[" ~ valsRegExp ~ "(," ~ valsRegExp ~ ")*\\])";

  if (!RegExp ("^" ~ elemsRegExp ~ "$").test (exp)) {
    throw new Exception ("invalid expression. ");
  }

  real[][] elems;

  foreach (uint i, string valsExp; RegExp (valsRegExp, "g").match (exp)) {
    real[] vals;

    foreach (string valExp; RegExp ("\\d", "g").match (valsExp)) {
      vals ~= to! (real) (valExp);
    }

    elems ~= vals;
  }

  return elems;
}
