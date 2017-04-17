/++
	Synopsis:
		This module defines a set of functions that
		calculate kakuro sequence values.
	Note:
		Sequences are either unordered or in
		decreasing order unless otherwise noded.
++/

module kakuro.seqs;

import set;
import array;
import kakuro.cons;
import kakuro.checks;

import std.conv;
import std.cstream;

/// min sum sequence:
real[] minSum (real len)
{
	real[] elems = new real [std.conv.to! (uint) (len)];

	for (uint i; i < elems.length; i ++)
	{
		elems [i] = len --;
	}

	return elems;
}

/// max sum sequence:
real[] maxSum (real len)
{
	real[] elems = new real [std.conv.to! (uint) (len)];

	for (uint i, m = 9; i < elems.length; i ++)
	{
		elems [i] = m --;
	}

	return elems;
}

/// min len sequence:
real[] minLen (real sum)
{
	return maxDelta (sum, kakuro.cons.minLen (sum));
}

/// max len sequence:
real[] maxLen (real sum)
{
	return maxDelta (sum, kakuro.cons.maxLen (sum));
}

/// returns the maximum delta sequence:
real[] maxDelta (real sum, real len)
{
	// get element offset:
	const real eo = kakuro.cons.MaxElem - len;

	// get sequence offset:
	const real so = sum - kakuro.cons.minSum (len);

	// get the number of maxed elements:
	const real nm = std.math.floor (so / eo);

	// get adjustment value:
	const real av = so - nm * eo;

	// allocate elements:
	real[] seq = new real [std.conv.to! (int) (len)];

	// set elements:
	for (uint i; i < len; i ++)
	{
		// min element:
		seq [i] = len - i;

		if (i < nm)
		{
			// max element:
			seq [i] += eo;
		}
		else if (i == nm)
		{
			// adjust element:
			seq [i] += av;
		}
	}

	// return elements:
	return seq;
}

/// returns the minimum delta sequence:
real[] minDelta (real sum, real len)
{
	// get the sequence offset:
	const real so = sum - kakuro.cons.minSum (len);

	// allocate the sequence elements:
	real[] seq = new real [std.conv.to! (uint) (len)];

	// set the element values:
	for (uint i; i < len; i ++)
	{
		seq [i] = std.math.ceil ((so - i) / len) + len - i;
	}

	// return the sequence:
	return seq;
}

/// returns the minimum delta sequence's delta sequence:
real[] minDeltasDelta (real sum, real len)
{
	// get the sequence offset:
	real so = sum - kakuro.cons.minSum (len);

	// allocate the sequence elements:
	real[] seq = new real [std.conv.to! (uint) (len)];

	// set element values:
	for (uint i; i < len; i ++, so ++)
	{
		seq [i] = std.math.floor ((so + 1) / len) - std.math.floor (so / len) + 1;
	}

	// return the sequence:
	return seq;
}

/// increments seq:
/// note: i should be set to 0.
real[] inc (uint i, real[] seq)
{
	const real max = 9 - i;

	if (i >= seq.length)
	{
		// extend sequence:
		return seq ~ cast (real []) [1];
	}
	else if (seq [i] < max)
	{
		// increment element:
		seq [i] ++;
	}
	else if (seq [i] == max)
	{
		// shift sequence:
		seq = inc (i + 1, seq);

		// set element:
		seq [i] = seq [i + 1] + 1;
	}

	// return sequence:
	return seq;
}

/// decrements seq:
/// note: i should be set to 0.
real[] dec (uint i, real[] seq)
{
	const real min = i < seq.length - 1 ? seq [i + 1] + 1 : 1;

	if (seq [i] > min)
	{
		// decrement element:
		seq [i] --;
	}
	else if (seq [i] == min)
	{
		if (i < seq.length - 1)
		{
			// shift sequence:
			seq = dec (i + 1, seq);

			// max element:
			seq [i] = 9 - i;
		}
		else if (i == seq.length - 1)
		{
			// contract sequence:
			seq = seq [0 .. $ - 1];
		}
	}

	return seq;
}

/// returns every sequence:
real[][] all ()
{
	real[][] res;

	for (real[] seq = [1]; seq != cast (real []) [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]; seq = inc (0, seq))
	{
		res ~= seq.dup;
	}

	return res;
}

/// returns every sequence that has the given sum:
/// note: min should be set to 0.
real[][] sameSum (real min, real sum)
{
	real[][] res;

	for (real i = min + 1; i < sum / 2; i ++)
	{
		res ~= array.append (sameSum (i, sum - i), i);
	}

	if (sum <= 9) res ~= [sum];

	return res;
}


/// returns every sequence that has the given length:
/// note: min should be set to 0.
real[][] sameLen (real min, real len)
{
	if (len == 0) return [[]];

	real[][] res;

	for (real i = min + 1; i <= 10 - len; i ++)
	{
		res ~= array.append (sameLen (i, len - 1), i);
	}

	return res;
}

/++
	Summary:
		Iterates through a search tree that represents
		the set of possible sequence values that match
		the given sum and length constraints, and
		executes the given function f for each node.

	Details:
		Every path in the search tree represents a
		possible sequence value. Every node corresponds
	       	to a possible element value. The depth of the
		node corresponds the element's index.

		For example the sequences: [1, 2] and [1, 3]
		would be represented by the following tree:
		                   [1]
		                   / \
		                 [2] [3]
		The function performs a depth first search
		through the tree. Hence the given function f
		would be called with elem=1, then elem=2, and
		finally elem=3.

	Note:
		len represents the remaining sequence length.
		max is a recursive index and should be set to 9.
++/
void iterate (real max, real sum, real len, void delegate (real len, real elem) f)
{
	if (len == 1) return f (len, sum);

	const real maxElem = kakuro.cons.maxElem (sum, len);

	if (maxElem < max) max = maxElem;

	for (real i = kakuro.cons.minElem (0, sum, len); i <= max; i ++)
	{
		f (len, i);

		iterate (i - 1, sum - i, len - 1, f);
	}
}

/// returns the set of possible element values for the sequences that have the given sum and length:
real[] elems (real sum, real len)
{
	real[] res;

	kakuro.seqs.iterate
	(
	 	kakuro.cons.MaxLen, sum, len,
		delegate void (real rem, real elem)
		{
			res = set.add (res, elem);
		}
	);

	return res;
}

/// returns every sequence that has the given sum and length:
real[][] seqs (real sum, real len)
{
	real[][] res;

	real[] seq = new real [std.conv.to! (uint) (len)];

	kakuro.seqs.iterate
	(
		kakuro.cons.MaxLen, sum, len,
		delegate void (real rem, real elem)
		{
			seq [std.conv.to! (uint) (len - rem)] = elem; 

			if (rem == 1) res ~= seq.dup; 
		}
	);

	return res;
}

/++
	Summary:
 		returns every sequence that has the given sum (sum), 
		and elements (elems).

	Parameters:
		elems is a two dimensional array that represents the
		set of possible element values. The first element in
		this array cooresponds to the first sequence element,
		the second element cooresponds to the second sequence
		element, and so on.

		Each element value is an array that represents the
		set of possible values for the corresponding sequence
		element. Hence elems = [[1,2], [2]], indicates that
		the first sequence element can be either 1, or 2, and
		the second sequence element must be 2.

	Results:
		The result is a two dimensional array. Each array
		represents a possible sequence value. The first
		element in the array represents the value of the
		first sequence element, the second array element
		represents the second sequence element, and so on.

	Performance:
		The number of recursive functions calls is given by: 
			Sigma (i = 0, len - 1, vals(i) ^ i)
		Where Sigma represents summation, and vals (i) is the
		number of possible element values for the ith square.

	Example:
		seqs (10, [[1,2],[2,3,4],[5,6,7]])
		returns: [[1,2,7],[1,3,6],[1,4,5],[2,3,5]].
++/
real[][] seqs (real sum, real[][] elems)
{
	std.cstream.dout.writefln ("seqs (%s, %s)", sum, elems);
	real[][] res;

	if (elems.length)
	{
		foreach (real elem; elems [0])
		{
			if (elems.length > 1)
			{
				foreach (real[] seq; seqs (sum - elem, elems [1 .. $ - 1]))
				{
					if (!set.member (seq, elem)) res ~= [elem] ~ seq;
				} 
			}
			else if (elem == sum) // and elems.length == 1
			{
				res ~= [elem];
				break;
			}
		}
	}

	return res;
}

/++
	Summary:
		returns every sequence that has the given sum (sum),
		length (len), and elements (elem).

	Parameters:
		elems represents the possible element values. Each 
		array represents a possible square in the sequence.
		Each element in the array represents a possible
		square value.

		The result is an array of arrays. Each array
		represents a possible sequence value. The first
		element in the array represents the first square,
		the second element represents the second, and so
		on.

	Notes:
		If len > elems.length this function will assume that
		the remaining elements are unconstrained. If
		elems.length > len this function will ignore the
		remaining element constraints.

	Performance:
		The number of recursive functions calls is given by: 
			Sigma (i = 0, len - 1, vals(i) ^ i)
		Where Sigma represents summation, and vals (i) is the
		number of possible element values for the ith square.

	Example:
		seqs (10, 3, [[1,2],[2,3,4],[5,6,7]])
		will return every sequence where; the first element
		is either 1, or 2; the second element is either 2, 3,
		or 4; the third element is either 5, 6, or 7; the sum
		is 10, and the number of elements is 3.
++/
real[][] seqs (real sum, real len, real[][] elems)
{
	if (len > elems.length)
	{
		while (len > elems.length) { elems ~= [1,2,3,4,5,6,7,8,9]; }
	}
	else if (len < elems.length)
	{
		elems = elems [0 .. std.conv.to! (uint) (len)];
	}

	return seqs (sum, elems);
}

unittest
{
	// test minSum (real):
	assert (minSum (4) == cast (real []) [4, 3, 2, 1]);

	// test maxSum (real):
	assert (maxSum (4) == cast (real []) [9, 8, 7, 6]);

	// test minLen (real):
	assert (minLen (19) == cast (real []) [9, 8, 2]);

	// test maxLen (real):
	assert (maxLen (19) == cast (real []) [9, 4, 3, 2, 1]);

	// test maxDelta (real, real): 
	assert (maxDelta (6, 1)  == cast (real []) [6]);
	assert (maxDelta (45, 9) == cast (real []) [9, 8, 7, 6, 5, 4, 3, 2, 1]);
	assert (maxDelta (16, 3) == cast (real []) [9, 6, 1]);
	assert (maxDelta (25, 5) == cast (real []) [9, 8, 5, 2, 1]);

	// test minDelta (real, real):
	assert (minDelta (1, 1) == cast (real []) [1]);
	assert (minDelta (9, 1) == cast (real []) [9]);
	assert (minDelta (45, 9) == cast (real []) [9, 8, 7, 6, 5, 4, 3, 2, 1]);
	assert (minDelta (13, 3) == cast (real []) [6, 4, 3]);
	assert (minDelta (25, 4) == cast (real []) [8, 7, 6, 4]);
	assert (minDelta (28, 6) == cast (real []) [8, 6, 5, 4, 3, 2]);

	// test increment (uint, real[]):
	assert (inc (0, [1])    == cast (real []) [2]);
	assert (inc (0, [9])    == cast (real []) [2, 1]);
	assert (inc (0, [9, 8]) == cast (real []) [3, 2, 1]);
	assert (inc (0, [9, 8, 7, 6, 5, 4, 3, 2]) == cast (real []) [9, 8, 7, 6, 5, 4, 3, 2, 1]);

	// test decrement iuint, real[]):
	assert (dec (0, [2])    == cast (real []) [1]);
	assert (dec (0, [2, 1]) == cast (real []) [9]);
	assert (dec (0, [3, 2, 1]) == cast (real []) [9, 8]);
	assert (dec (0, [6, 5, 2]) == cast (real []) [9, 4, 2]);

	// test sameSum (real, real):
	assert (sameSum (0, 1)  == cast (real [][]) [[1]]);
	assert (sameSum (0, 45) == cast (real [][]) [[9, 8, 7, 6, 5, 4, 3, 2, 1]]);
	assert
	(
		sameSum (0, 10) == cast (real [][])
		[
			[4, 3, 2, 1], [7, 2, 1], [6, 3, 1], [5, 4, 1], [9, 1], [5, 3, 2], [8, 2], [7, 3], [6, 4]
		]
	);

	// test sameLen (real, real):
	assert (sameLen (0, 1) == cast (real [][]) [[1], [2], [3], [4], [5], [6], [7], [8], [9]]);
	assert (sameLen (0, 9) == cast (real [][]) [[9, 8, 7, 6, 5, 4, 3, 2, 1]]);
	assert
	(
		sameLen (0, 2) == cast (real [][])
		[
			[2, 1], [3, 1], [4, 1], [5, 1], [6, 1], [7, 1], [8, 1], [9, 1],
			[3, 2], [4, 2], [5, 2], [6, 2], [7, 2], [8, 2], [9, 2],
			[4, 3], [5, 3], [6, 3], [7, 3], [8, 3], [9, 3],
			[5, 4], [6, 4], [7, 4], [8, 4], [9, 4],
			[6, 5], [7, 5], [8, 5], [9, 5],
			[7, 6], [8, 6], [9, 6],
			[8, 7], [9, 7],
			[9, 8]
		]
	);

	// test elems (real, real):
	assert (elems (1, 1)  == cast (real []) [1]);
	assert (elems (9, 1)  == cast (real []) [9]);
	assert (elems (45, 9) == cast (real []) [9, 8, 7, 6, 5, 4, 3, 2, 1]);
	assert (elems (15, 3) == cast (real []) [6, 5, 4, 7, 3, 2, 8, 1, 9]);
	assert (elems (24, 4) == cast (real []) [8, 7, 5, 4, 6, 3, 9, 2, 1]);

	// test seqs (real, real):
	assert (seqs (1, 1)  == cast (real [][]) [[1]]);
	assert (seqs (9, 1)  == cast (real [][]) [[9]]);
	assert (seqs (45, 9) == cast (real [][]) [[9, 8, 7, 6, 5, 4, 3, 2, 1]]);
	assert (seqs (5, 2)  == cast (real [][]) [[3, 2], [4, 1]]);
	assert (seqs (10, 3) == cast (real [][]) [[5, 3, 2], [5, 4, 1], [6, 3, 1], [7, 2, 1]]);

	// test seqs (real, real[][]):
	assert (seqs (1, [[0]]) == cast (real [][]) []);
	assert (seqs (1, [[1]]) == cast (real [][]) [[1]]);
	assert (seqs (9, [[9]]) == cast (real [][]) [[9]]);

	std.cstream.dout.writefln ("seqs: %s", seqs (45, [[1],[2],[3],[4],[5],[6],[7],[8],[9]]));

	assert (seqs (45, [[1],[2],[3],[4],[5],[6],[7],[8],[9]]) == cast (real [][]) [[1,2,3,4,5,6,7,8,9]]);
	assert (seqs (45, [[1,2],[2,1],[3],[4],[5],[6],[7],[8],[9]]) == cast (real [][]) [[1,2,3,4,5,6,7,8,9],[2,1,3,4,5,6,7,8,9]]);
	assert (seqs (9, [[1,2,3],[6,7]]) == cast (real [][]) [[2,7],[3,6]]);
	assert (seqs (17, [[1,2],[3,4],[4,5],[8,9]]) == cast (real [][]) [[1,3,4,9],[1,3,5,8],[2,3,4,8]]);
	assert (seqs (34, [[1,2],[3,4],[5],[7,6],[8,9],[9,3]]) == cast (real [][]) [[1,4,5,7,8,9],[2,3,5,7,8,9],[2,4,5,6,8,9]]);
	assert (seqs (36, [[1],[2],[3,4],[4,3],[5,7],[6],[7,5],[8,1]]) == cast (real [][]) [[1,2,3,4,5,6,7,8],[1,2,3,4,7,6,5,8],[1,2,4,3,5,6,7,8],[1,2,4,3,7,6,5,8]]);
}
