Kakuro Readme:
==============

Overview:
---------

Kakuro is a utility for analyzing and solving kakuro puzzles. The package is organized around the kakuro library and front end. The kakuro library is a d module that defines classes for generating checking and filtering kakuro sequences. The kakuro front end provides a user interface for kakuro library and was designed to help users solve kakuro puzzles. The project is currently under development, and several key features are still pending. Detailed information concerning the kakuro library can be found in kakuro.html. Up to date information concerning the kakuro front end can be found in it's help page.

Background:
-----------

Originally started as a utility for generating kakuro sequence tables, Kakuro has evolved into a powerfull package for analyzing and solving kakuro puzzles. The project is still under development.

Procedure:
----------

The algorithms used by the kakuro package are still under active development. At this point, kakuro uses a brute force method for identifying solutions. While efficient algorithms have been implemented for identifying sequences that conform to sum and length constraints work still needs to be done to find efficient algorithms for integrating constraints emerging from individual squares.

The following is an outline of the resolution procedure:

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
