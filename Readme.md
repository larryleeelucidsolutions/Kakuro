Kakuro Readme:
==============

Overview:
---------

Kakuro is a command line utility for analyzing and solving kakuro puzzles. 

The package is organized around the Kakuro library and front-end. The Kakuro library is a D module that defines classes for generating, checking, and filtering Kakuro sequences. The Kakuro front-end provides a command line user interface for the Kakuro library and was designed to help users solve kakuro puzzles. The project is currently under development, and several key features are still pending.

Using Kakuro
------------

The Kakuro package provides two command line programs that can be used to solve Kakuro puzzles. Both programs can be found under, interfaces.

The first program, kakuro-file accepts a text file that represents a Kakuro puzzle. It uses the resolution procedure described below to solve the puzzle and then outputs the solution as a text file. Kakuro-file can be used as the back-end for a graphical client.

The second program, kakuro-cmd accepts a constraint string that describes the sum, length, and value constraints that apply to a kakuro sequence and returns a list of possible sequence values. This program can be used when manually solving puzzles and provides clues anaogous to the way crossword puzzle dictionaries aid in solving crossword puzzles.

Both of these programs use the Kakuro library, libkakuro.a, that is defined in the kakuro directory.


Resolution Procedure:
---------------------

The algorithms used by the Kakuro package are still under active development. Efficient algorithms have been implemented for identifying sequences that conform to sum and length constraints. When solving puzzles, Kakuro uses an iterative resolution procedure, which it applies iteratively to the squares within a given puzzle. The following is an outline of the resolution procedure used by Kakuro:

each square has two associated sequences A, and B.
each sequence is a family of sets.
1. get the sequences that match the given sum and length constraints for A.
2. get the union set for each of these sequences.
3. denote this union set as set UA.
4. get the sequences that match the given sum and length constraints for B.
5. get the union set for each of these sequences.
6. denote this union set as set UB.
7. get the intersection between UA and UB.
8. denote this intersection set as IUAUB.
9. repeat this operation for each square in A and B.
10. This should produce a family of intersection sets for both A and B.
11. denote these families of intersection sets as FIA and FIB.
12. get the cartesian product of FIA.
13. This cartesian product represents the possible solutions for A.
14. get the cartesian product of FIB.
15. This cartesian product represents the possible solutions for B.

Author:
------
* Larry D. Lee jr. <email: llee454@gmail.com>
