function b = subsref(a,index)
% subsref - Defines generic indexing for objects.
if size(index, 2) > 1
  first = subsref(a, index(1));
  %# recursive
  b = subsref(first, index(2:end));
else
  switch index.type
    case '()'
      %# Re-adjust the number of params if some are gone
      if length(index.subs) > 1
	cols = sort(tests2cols(a, index.subs{2}));
	a = set(a, 'num_params', sum(cols <= a.num_params));
      end
      b = onlyRowsTests(a, index.subs{:});
    case '.'
      b = get(a, index.subs); 
    case '{}'
      b = a{index.subs{:}};
  end
end
