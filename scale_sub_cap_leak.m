function params = ...
      scale_cap_leak_Ca_sub_cap_leak(filename, title_str, props)

% scale_cap_leak_Ca_sub_cap_leak - Scale capacitance and leak artifacts to subtract them.
%
% Usage:
% params = 
%   scale_cap_leak_Ca_sub_cap_leak(filename, props)
%
% Parameters:
%   filename: Full path to filename.
%   props: A structure with any optional properties.
%     fitRange: Start and end times of range to apply the optimization [ms].
%     fitRangeRel: Start and end times of range relative to first voltage step [ms].
%     fitLevels: Indices of voltage/current levels to use from clamp data.
%     saveData: If 1, save subtracted data into a new text file (default=0).
%     quiet: If 1, do not include cell name on title.
% 
% Returns:
%   params: Structure with tuned parameters.
%
% Description:
%
% Example:
% >> [time, dt, data_i, data_v, cell_name] = ...
%    scale_cap_leak_Ca_sub_cap_leak('data-dir/cell-A.abf')
% >> plotVclampStack(time, data_i, data_v, cell_name);
%
% See also: param_I_v, param_func
%
% $Id: scale_cap_leak_Ca_sub_cap_leak.m 1174 2009-03-31 03:14:21Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/01/17

% TODO: 
% - process 2nd step and write a 2nd data file for prepulse step
% - prepare a doc_multi from this. Find a way to label figures but print later.
% - also plot IClCa m_infty curve?
% - have option to show no plots, to create database of params

props = defaultValue('props', struct);
title_str = defaultValue('title_str', '');

% load data from ABF file
a_vc = abf2voltage_clamp(filename, props);

dt = get(a_vc, 'dt');
cell_name = get(a_vc, 'id');

time = (0:(size(a_vc.v.data, 1) - 1)) * dt;

% select the initial part before v-dep currents get activated
range_rel = getFieldDefault(props, 'fitRangeRel', [-.2, +1]); % [ms]
range_maxima = ...
    getFieldDefault(props, 'fitRange', ...
                           [a_vc.time_steps(1) + ...
                    floor(range_rel / dt + .49)]);
range_cap_resp = round(range_maxima(1)):round(range_maxima(2));

% use all voltage levels by default
use_levels = getFieldDefault(props, 'fitLevels', 1:size(a_vc.v.data, 2));

extra_text = ...
    [ '; fit to [' sprintf('%.2f ', range_maxima * dt) ']' ...
      '; levels: [' sprintf('%d ', use_levels) ']' ];

if isfield(props, 'quiet')
  all_title = properTeXLabel(title_str);
else
  all_title = ...
      properTeXLabel([ cell_name ': Raw data' extra_text title_str ]);
end

% nicely plot current and voltage trace in separate axes  
plotFigure(...
  plot_stack({...
    plot_abstract({time(range_cap_resp), ...
                   a_vc.i.data(range_cap_resp, :)}, {'time [ms]', 'I [nA]'}, ...
                  'all currents', {}, 'plot', struct), ...
    plot_abstract({time(range_cap_resp), ...
                   a_vc.v.data(range_cap_resp, :)}, {'time [ms]', 'V_m [mV]'}, ...
                  'all currents', {}, 'plot', struct)}, ...
             [min(range_cap_resp) * dt, max(range_cap_resp) * dt NaN NaN], ...
             'y', all_title, ...
             struct('titlesPos', 'none', 'xLabelsPos', 'bottom', ...
                    'fixedSize', [4 3], 'noTitle', 1)));

% func
f_capleak = ...
      param_cap_leak2_int_t(...
        struct('gL', 0.7, 'EL', -75, 'Cm', .2, 'delay', 0.1), ...
        ['cap leak']);

disp('Fitting...');
  %select_params = {'Ri', 'Cm', 'delay'}
  %select_params = {'gL', 'EL'}
  %f_capleak = setProp(f_capleak, 'selectParams', select_params); 

  % optimize
  f_capleak = ...
      optimize(f_capleak, ...
               {a_vc.v.data(range_cap_resp, use_levels), dt}, ...
               a_vc.i.data(range_cap_resp, use_levels), ...
               struct('optimset', optimset('OutputFcn', @disp_out)));

  function stop = disp_out(x, optimValues, state)
  %disp(x);
    stop = false;
  end
  
  % show all parameters
  params = getParamsStruct(f_capleak)

  v_steps = a_vc.v_steps(2, :);
  v_legend = ...
      cellfun(@(x)([ sprintf('%.0f', x) ' mV']), num2cell(v_steps'), ...
              'UniformOutput', false);

  % choose the range
  range_steps = (a_vc.time_steps(1) - 1 / dt) : (a_vc.time_steps(2) + 5 / dt);

  Im = f(f_capleak, { a_vc.v.data(range_steps, :), dt});

  % subtract the cap+leak part
  data_sub_capleak = a_vc.i.data;
  data_sub_capleak(range_steps, :) = data_sub_capleak(range_steps, :) - Im;
  
  % superpose over data
  line_colors = lines(length(v_steps)); %hsv(length(v_steps));
  
  if isfield(props, 'quiet')
    all_title = properTeXLabel(title_str);
  else
    all_title = ...
        properTeXLabel([ cell_name ': Sim + sub data' extra_text title_str ]);
  end

  plotFigure(...
    plot_stack({...
      plot_superpose({...
        plot_abstract({time, a_vc.i.data}, {'time [ms]', 'I [nA]'}, ...
                      'data', v_legend, 'plot', ...
                      struct('ColorOrder', line_colors)), ...
        plot_abstract({time(range_steps), Im}, ...
                      {'time [ms]', 'I [nA]'}, ...
                      'est. I_{cap+leak}', {}, 'plot', ...
                      struct('plotProps', struct('LineWidth', 2), ...
                             'ColorOrder', line_colors))}, ...
                     {}, '', struct('noCombine', 1)), ...
      plot_abstract({time, data_sub_capleak}, ...
                    {'time [ms]', 'I [nA]'}, ...
                    'data - I_{cap+leak}', {}, 'plot', ...
                    struct('ColorOrder', line_colors, ...
                           'plotProps', struct('LineWidth', 1)))}, ...
               [min(range_steps) * dt, max(range_steps) * dt NaN NaN], ...
               'y', all_title, ...
               struct('titlesPos', 'none', 'xLabelsPos', 'bottom', ...
                      'fixedSize', [4 3], 'noTitle', 1)));

if isfield(props, 'saveData')
  %%
  % write to text file for NeuroFit
  dlmwrite([ cell_name ' sub cap leak.txt' ], [time, data_sub_capleak], ' ' );
end

end
