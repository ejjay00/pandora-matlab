function [times, peaks, n] = ...
      findFilteredSpikes(t, a_period, plotit)

% findFilteredSpikes - Runs a frequency filter over the data and then 
%			finds all peaks using findspikes.
%
% Usage:
% [times, peaks, n] = 
%	findFilteredSpikes(t, a_period, plotit)
%
% Description:
%   Runs a 50-300 Hz band-pass filter over the data and then calls findspikes.
%   The filter both removes low-frequency offset changes, such as 
%   cip period effects, and high-frequency noise that is detected 
%   as local peaks by findspikes. The spikes found are 
%   post-processed to make sure the rise and fall times are consistent.
%   Note: The filter employed only works with data sampled at 10kHz.
%
% 	Parameters: 
%		t: Trace object
%		a_period: Period of interest.
%		plotit: Plots the spikes found if 1.
%	Returns:
%		times: The times of spikes [dt].
%		peaks: The peaks corresponding to the times of spikes.
%		n: The number of spikes.
%
% See also: findspikes, period
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2004/03/08
% Modified:
% - Adapted to the trace object, CG 2004/07/30

s = load('spike_filter_50_300Hz_ChebII.mat');
fields = fieldnames(s);
fd = getfield(s, fields{1});	%# Assuming there's only one element
up_threshold = 10;
dn_threshold = -2;

%# Scale to mV for spike finder
mV_factor = 1e3 * t.dy;

%# Prepend some activity for filter distortion
prepend_size = floor(20e-3 / t.dt);
data = [t.data(a_period.start_time:(a_period.start_time + prepend_size - 1)); ...
	t.data(a_period.start_time:a_period.end_time) ] * mV_factor;

filtered = filtfilt(fd.tf.num, fd.tf.den, data);

%# ignore the prepended part
filtered = filtered(prepend_size:end);
data = data(prepend_size:end);
[times, peaks, n] = findspikes(filtered, up_threshold, plotit);

newtimes = [];
newpeaks = [];
newn = 0;
%# Eliminate non-spike bumps
lasttime = -3e-3 / t.dt;
for i=1:n

  if times(i) < (lasttime + 3e-3 / t.dt)
    if plotit ~= 0 & plotit ~= 2
      disp(sprintf('Skip %f', times(i)));
    end
    continue;
  end

  %# correct the peak by finding the absolute max within +/- 3ms
  pm = 3e-3 / t.dt;
  [m peak_time] = ...
      max(filtered(max(1, times(i) - pm) : min(times(i) + pm, length(filtered))));
  times(i) = max(1, times(i) - pm) + peak_time - 1;

  %# There should be a trough within 3ms before and within 5ms after the peak
  min1 = min(filtered(max(1, times(i) - 3e-3 / t.dt) : times(i)));
  min2 = min(filtered(times(i) : min(times(i) + 5e-3 / t.dt, length(filtered))));

  %# Spike shape criterion test
  if min1 <= up_threshold & min2 <= dn_threshold    

    %# Re-correct according to peaks in real data (filtered data is shifted)
    real_time = times(i);
    [real_peak peak_time] = ...
	max(data(max(1, real_time - pm) : min(real_time + pm, length(data))));
    real_time = max(1, real_time - pm) + peak_time - 1;

    %# Collect in new list
    newtimes = [newtimes, real_time];
    newpeaks = [newpeaks, real_peak];
    newn = newn + 1;
    lasttime = times(i);
  else
    if plotit ~= 0 & plotit ~= 2
      disp(sprintf('Failed criterion for %f', times(i)));
    end    
  end
end

%# correct the times
times = newtimes + a_period.start_time - 1;
peaks = newpeaks;
n = newn;
