function a_crit_bundle = matchingRow(a_bundle, traceset_index, props)

% matchingRow - Creates a criterion database for matching the neuron at traceset_index.
%
% Usage:
% a_crit_bundle = matchingRow(a_bundle, traceset_index, props)
%
% Description:
%   Copies selected test values from row as the first row into the 
% criterion db. Adds a second row for the STD of each column in the db.
%
%   Parameters:
%	a_bundle: A physiol_bundle object.
%	traceset_index: A TracesetIndex of the neuron and treatments to match.
%	props: A structure with any optional properties.
%		
%   Returns:
%	a_crit_bundle: A dataset_db_bundle with two rows for values and STDs.
%
%   Example:
%	physiol_bundle has an overloaded matchingRow method that
%	takes the TracesetIndex as argument:
%	>> a_crit_bundle = matchingRow(pbundle, 61)
%	>> a_ranked_bundle = rankMatching(mbundle, a_crit_bundle);
%	>> printTeXFile(comparisonReport(a_ranked_bundle), 'my_report.tex')
%
% See also: rankMatching, tests_db/matchingRow
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2005/12/21

if ~ exist('props')
  props = struct;
end

num_tracesets = length(traceset_index);
if num_tracesets > 1
  %# If called with vectorized indices
  [ a_crit_bundle(1:num_tracesets) ] = deal(physiol_bundle);
  for traceset_num = 1:num_tracesets
    a_crit_bundle(traceset_num) = matchingRow(a_bundle, traceset_index(traceset_num), props);
  end
else
  %# Called with one index
  j_db = get(a_bundle, 'joined_db');

  row_num = find(j_db(:, 'TracesetIndex') == traceset_index);

  if isempty(row_num)
    error(['Cannot find TracesetIndex ' num2str(traceset_index) ]);
  end

  %# Get crit_db and rename to a more human-readable form
  crit_db = set(matchingRow(j_db, row_num, ...
			    struct('std_db', a_bundle.joined_control_db)), 'id', ...
		[ 'Matching traceset ' ...
		 num2str(traceset_index) ' of neuron ' ...
		 get(getItem(get(a_bundle, 'dataset'), traceset_index), 'id') ...
		 ' of ' j_db.id ]);
  clear j_db
  
  %# Warning: doesn't call parent function, directly calls tests_db/matchingRow
  a_crit_bundle = set(a_bundle, 'joined_db', crit_db );
end