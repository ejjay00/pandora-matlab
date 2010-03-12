function a_p = plotSteadyIV(a_vc, step_num, title_str, props)

% plotSteadyIV - Plot of the I/V curve at the end of a voltage step.
%
% Usage:
% a_p = plotSteadyIV(a_vc, step_num, title_str, props)
%
% Parameters:
%   a_vc: A voltage clamp object.
%   step_num: 1 for prestep, 2 for the first step, 3 for next, etc.
%   title_str: (Optional) Text to appear in the plot title.
%   props: A structure with any optional properties.
%     quiet: If 1, only use given title_str.
%     label: add this as a line label to be used in superposed plots.
%		
% Returns:
%   a_p: A plot_abstract object.
%
% Description:
%   Can be superposed with other I/V plot objects (see plot_superpose).
%
% Example:
% >> a_vc = abf_voltage_clamp('data-dir/cell-A.abf')
% >> plotFigure(plotSteadyIV(a_vc, 2, 'I/V curve'))
%
% See also: voltage_clamp, plot_abstract, plotFigure, plot_superpose
%
% $Id: plotSteadyIV.m 1174 2009-03-31 03:14:21Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/03/10

% TODO: 

if ~ exist('props', 'var')
  props = struct;
end

if ~ exist('title_str', 'var')
  title_str = '';
end

if isfield(props, 'label')
  plot_label = props.label;
else
  plot_label = 'data';
end

dt = get(a_vc, 'dt');

data_i = get(a_vc.i, 'data');
data_v = get(a_vc.v, 'data');
cell_name = get(a_vc, 'id');
time = (0:(size(data_i, 1)-1))*dt;

if isfield(props, 'quiet')
  all_title = properTeXLabel(title_str);
else
  all_title = ...
      properTeXLabel([ 'I/V curve: ' cell_name title_str ]);
end

a_p = ...
    plot_abstract(...
      {a_vc.v_steps(step_num, :), a_vc.i_steps(step_num, :)}, ...
      {[ 'step ' num2str(step_num) ' voltage [mV]' ], 'current [nA]'}, ...
      all_title, {plot_label}, 'plot', ...
      mergeStructs(props, ...
                   struct('tightLimits', 1, ...
                          'plotProps', struct('LineWidth', 2))));
