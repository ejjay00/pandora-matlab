function b = subsref(a,index)

% subsref - Defines indexing for tests_db objects for () and . operations. 
%
% Usage:
% obj = obj(rows, tests)
% obj = obj.attribute
%
% Description:
% Returns attributes or selects the given test columns and rows
% and returns in a new tests_db object.
%
%   Parameters:
%	obj: A tests_db object.
%	rows: A logical or index vector of rows. If ':', all rows.
%	tests: Cell array of test names or column indices. If ':', all tests.
%	attribute: A tests_db class attribute.
%		
%   Returns:
%	obj: The new tests_db object.
%
% See also: subsref, tests_db
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2004/09/17

if size(index, 2) > 1
  first = subsref(a, index(1));
  %# recursive
  b = subsref(first, index(2:end));
else
  switch index.type
    case '()'
      if length(index.subs) == 1 %# Only rows
	b = onlyRowsTests(a, index.subs{1}, ':');
      elseif length(index.subs) == 2 %# Both rows and cols
	b = onlyRowsTests(a, index.subs{1:2});
      elseif length(index.subs) == 3 %# Rows, cols, and pages.
	b = onlyRowsTests(a, index.subs{1:3});
      else
	error('Only two indices are supported: db(rows, cols)');
      end
    case '.'
      b = eval(['a.' index.subs]);
    case '{}'
      b = a{index.subs{:}};
  end
end