function b = get(a, attr)
% get - Defines generic attribute retrieval for objects.
% Author: Cengiz Gunay <cgunay@emory.edu>, 2004/09/14
try
  b = getfield(struct(a), attr);
catch
  rethrow(lasterror);
end
