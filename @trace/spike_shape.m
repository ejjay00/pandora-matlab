function obj = spike_shape(t, s)

% spike_shape - Convert averaged spikes in the trace to a spike_shape object.
%
% Usage:
% obj = spike_shape(trace, spikes)
%
%   Parameters:
%	trace: A trace object.
%	spikes: A spikes object on trace.
%
% Description:
%   Creates a spike_shape object.
%		
% See also: spike_shape
%
% $Id$
% Author: 
%   Cengiz Gunay <cgunay@emory.edu>, 2004/08/04

if nargin < 2 %# Called with insufficient params
  error('Need parameters.');
end

left = 2e-3 / t.dt;		%# From left side of peak 
%#right = 20e-3 / t.dt;		%# From right side of peak 

%# Find minimal ISI value for maximal range that can be acquired with
%# single spikes
min_isi = min(getISIs(s));

right = min_isi - left;

if length(s.times) > 0
  [allspikes, avgspikes] = collectspikes(t.data, s.times, left, right, 0);
end

obj = spike_shape(avgspikes', t.dt, t.dy, t.id);
