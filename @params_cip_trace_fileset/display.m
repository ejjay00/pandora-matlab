function s = display(t)

% Generic object display method.
% Author: Cengiz Gunay <cgunay@emory.edu>, 2004/08/04

disp(sprintf('%s, %s', class(t), get(t, 'id')));
struct(t)
struct(t.params_tests_fileset)
