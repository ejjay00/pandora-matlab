function a_cip_trace = ctFromRows(m_fileset, m_dball, a_db, cip_levels, props)

% ctFromRows - Loads a cip_trace object from raw data files in the fileset.
%
% Usage:
% a_cip_trace = ctFromRows(m_fileset, m_dball, a_db|itemIndices, cip_levels, props)
%
% Description:
%
%   Parameters:
%	m_fileset: A physiol_cip_traceset_fileset object.
%	m_dball: A DB created by this fileset that contains the trial, pAcip, and ItemIndex cols.
%	a_db: A DB that has one trial for each cip_trace to be loaded.
%	itemIndices: A column vector with ItemIndex numbers.
%	cip_levels: A column vector of CIP-levels to be loaded.
%	props: A structure with any optional properties.
%	  (passed to params_cip_trace_fileset/cip_trace)
%		
%   Returns:
%	a_cip_trace: One or more cip_trace objects that hold the raw data.
%
% See also: loadItemProfile, physiol_cip_traceset/cip_trace
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2005/07/13

if ~exist('props')
  props = struct;
end

if isa(a_db, 'tests_db')
  if ismember(getColNames(a_db), 'ItemIndex')
    index_vals = transpose(get(onlyRowsTests(a_db, ':', 'ItemIndex'), 'data'));
  else
    %# if no ItemIndex, we need to match parameter values
    param_names = getColNames(a_db(1, 1:get(a_db, 'num_params')));
    index_vals = ...
	transpose(get(onlyRowsTests(m_dball, ...
				    m_dball(:, param_names) == a_db(:, param_names) & ...
				    m_dball(:, 'pAcip') == cip_levels, ...
				    'ItemIndex'), 'data'));
  end
else
  index_vals = a_db;
end

a_cip_trace = cip_trace(m_fileset, index_vals);
