/++
Synopsis:

	This module defines functions and data strutures
	for manipulating matricies.

Matrix Representation:

	Matricies are represented by multidimensional
	arrays:
		m.length       = number of rows
		m [row].length = number of columns
		m [row][column]

	Each array represents a matrix row. Hence:

		T[][] m = new T [][number of rows];

	Then for each row: 

		m [row] = new T [number of columns];
++/

module matrix;

// for testing:
import std.cstream;

/// returns true if matrix m is valid:
bool check (T) (T[][] m)
{
	if (m.length == 0) return false;

	for (uint i = 1; i < m.length; i ++)
	{
		if (m [i].length != m [0].length) return false;
	}

	return true;
}

/// returns true if matrix m is empty:
bool empty (T) (T[][] m)
{
	if (!matrix.check (m)) throw new Exception ("matrix.empty (T) (T[][]) failed: invalid matrix.");

	return m [0].length == 0;
}

/// returns an empty matrix:
T[][] empty (T) ()
{
	T[][] m = new T [][1];

	m [0] = new T [0];

	return m;
}

/// returns the transpose of matrix m:
T[][] transpose (T) (T[][] m)
{
	if (!matrix.check (m)) throw new Exception ("matrix.transpose (T) (T[][]) failed: invalid matrix.");

	if (matrix.empty (m)) return matrix.empty! (T) ();

	T[][] t = new T [][m [0].length];

	for (uint i; i < t.length; i ++)
	{
		t [i] = new T [m.length];

		for (uint j; j < m.length; j ++)
		{
			t [i][j] = m [j][i];
		}
	}

	return t;
}

/// returns res [i,j] = f (m [i][j], n [i][j])
T[][] apply (T) (T[][] m, T[][] n, T delegate (T, T) f)
{
	T[][] res = new T [][m.length];

	for (uint i; i < m.length; i ++)
	{
		res [i] = new T [m [i].length];

		for (uint j; j < m [i].length; j ++)
		{
			res [i][j] = f (m [i][j], n [i][j]);
		}
	}

	return res;
}

/// returns the sum of matrix m and n:
T[][] add (T) (T[][] m, T[][] n)
{
	return apply (m, n, delegate (T x, T y) { return x + y; });
}

/// returns the difference between m and n:
T[][] difference (T) (T[][] m, T[][] n)
{
	return apply (m, n, delegate (T x, T y) { return x - y; });
}

/// returns the scalar product of x and m:
T[][] product (T) (T x, T[][] m)
{
	T[][] res = new T [][m.length];

	for (uint i; i < m.length; i ++)
	{
		res [i] = new T [m [i].length];

		for (uint j; j < m [i].length; j ++)
		{
			res [i][j] = x * m [i][j];
		}
	}

	return res;
}

/// returns the product of m and n:
T[][] product (T) (T[][] m, T[][] n)
{
	T[][] res = new T [][m.length];

	for (uint r; r < m.length; r ++)
	{
		res [r] = new T [n [r].length];

		for (uint c; c < n [r].length; c ++)
		{
			for (uint k; k < m [r].length; k ++)
			{
				res [r][c] += m [r][k] * n [k][c];
			}
		}
	}

	return res;
}

unittest
{
	// test bool check (T) (T[][]):

	assert (check ([[1, 2], [3, 4]]));

	assert (!check ([[1, 2], [3]]));

	assert (check ([[1]]));

	assert (check ([[]]));

	// test T[][] transpose (T) (T[][]):

	assert (transpose ([[1, 2], [3, 4]]) == [[1, 3], [2, 4]]);

	assert (transpose ([[1, 2, 3], [4, 5, 6], [7, 8, 9]]) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]);

	assert (transpose ([[1]]) == [[1]]);

	assert (transpose (cast (int [][]) [[]]) == cast (int [][]) [[]]);

	// test T[][] add (T) (T[][], T[][]):

	assert (add ([[1, -2, 3], [2, -1, 4]], [[0, 2, 1], [1, 3, -4]]) == [[1, 0, 4], [3, 2, 0]]);

	// test T[][] difference (T) (T[][], T[][]):

	assert (difference ([[2, 3, -5], [4, 2, 1]], [[2, -1, 3], [3, 5, -2]]) == [[0, 4, -8], [1, -3, 3]]);

	// test T[][] product (T) (T, T[][]):

	assert (product (-2, [[4, -2, -3], [7, -3, 2]]) == [[-8, 4, 6], [-14, 6, -4]]);

	// test T[][] product (T) (T[][], T[][]):

	assert (product ([[1, 2, -1], [3, 1,  4]], [[-2,  5], [ 4, -3], [ 2,  1]]) == [[4, -2], [6, 16]]);

	assert (product ([[1, 2], [-1, 3]], [[2, 1], [0, 1]]) == [[2, 3], [-2, 2]]);

	assert (product ([[2, 1], [0, 1]], [[1, 2], [-1, 3]]) == [[1, 7], [-1, 3]]);

}
