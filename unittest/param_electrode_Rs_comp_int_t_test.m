function param_electrode_Rs_comp_int_t_test(ifplot)
  
% param_electrode_Rs_comp_int_t_test - Unit test.
%
% Usage:
%   param_electrode_Rs_comp_int_t_test(ifplot)
%
% Parameters:
%   ifplot: If 1, produce plots.
%
% Returns:
%
% Description:  
%   Uses the xunit framework by Steve Eddins downloaded from Mathworks
% File Exchange.
%
% See also: xunit
%
% $Id: param_Re_Ce_cap_leak_act_int_t_test.m 168 2010-10-04 19:02:23Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2015/05/12

ifplot = defaultValue('ifplot', 0);

% compare ReCe and Rs comp
capleakReCe_f = ...
    param_Re_Ce_cap_leak_act_int_t(...
      struct('Re', 28, 'Ce', 2e-4, 'gL', 3.2e-3, ... % Ce=2e-4 OR 4e-3
             'EL', -88, 'Cm', .018, 'delay', 0, 'offset', 0), ... % EL=-70
      ['cap, leak, Re and Ce']);

ampReCe_f = ...
    param_electrode_Rs_comp_int_t(...
      struct('Re', 28, 'Ce', 2e-4, 'Ccomp', 0, 'gL', 3.2e-3, ... % Ce=2e-4 OR 4e-3
             'EL', -88, 'Cm', .018, 'delay', 0, 'offset', 0), ... % EL=-70
      ['amp']);


% make a perfect voltage clamp data (could have used makeIdealClampV)
pre_v = -70;
pulse_v = -90:10:-50;
post_v = -70;
dt = 0.025; % [ms]
pre_t = round(10/dt) + 1; % +1 for neuron
pulse_t = round(100/dt);
post_t = round(10/dt);

a_p_clamp = ...
    voltage_clamp([ repmat(0, pre_t + pulse_t + post_t, length(pulse_v))], ...
                  [ repmat(pre_v, pre_t, length(pulse_v)); ...
                    repmat(pulse_v, pulse_t, 1); ...
                    repmat(post_v, post_t, length(pulse_v)) ], ...
                  dt*1e-3, 1e-9, 1e-3, 'Ideal voltage clamp');

% simulate
sim_old_vc = ...
    simModel(a_p_clamp, capleakReCe_f, struct('levels', 1:5));
sim_new_vc = ...
    simModel(a_p_clamp, ampReCe_f, struct('levels', 1:5));

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(sim_old_vc, '', struct('onlyPlot', 'i', 'label', 'old Re')), ...
    plot_abstract(sim_new_vc, '', struct('onlyPlot', 'i', 'label', 'new Re'))}));
end

% init & steady tests
% $$$ assertElementsAlmostEqual(sim_old_vc.i.data, ...
% $$$                           sim_new_vc.i.data, 'absolute', 1e-2);

% load neuron files
tr_m90 = ...
    trace('Ic_dt_0.025000ms_dy_1e-9nA_vclamp_-70_to_-90_mV.bin', ...
          0.025e-3,  1e-9, 'neuron sim Ic', ...
          struct('file_type', 'neuron', ...
                 'unit_y', 'A'));

tr_m50 = ...
    trace('Ic_dt_0.025000ms_dy_1e-9nA_vclamp_-70_to_-50_mV.bin', ...
          0.025e-3,  1e-9, 'neuron sim Ic', ...
          struct('file_type', 'neuron', ...
                 'unit_y', 'A'));

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(tr_m90, '', struct('label', 'Neuron sim', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(setLevels(sim_new_vc, 1), '', struct('onlyPlot', 'i', ...
                                                    'label', 'new Re'))}));
  plotFigure(plot_superpose({...
    plot_abstract(tr_m50, '', struct('label', 'Neuron sim', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(setLevels(sim_new_vc, 5), '', struct('onlyPlot', 'i', ...
                                                    'label', 'new Re'))}));
end

if ifplot
  plotFigure(plot_superpose({...
    plot_abstract(tr_m90 - get(setLevels(sim_new_vc, 1), 'i'), '', ...
                  struct('label', '\Delta @ -90 mV', 'ColorOrder', [0 0 1; 1 0 0])), ...
    plot_abstract(tr_m50 - get(setLevels(sim_new_vc, 5), 'i'), '', ...
                  struct('onlyPlot', 'i', 'label', '\Delta @ -50 mV'))}));
end

% test if matches
skip_dt = 3/dt; % skip settlement artifact at beginning
assertElementsAlmostEqual(tr_m90.data(skip_dt:end), ...
                          sim_new_vc.i.data(skip_dt:end, 1), 'absolute', 1e-1);

assertElementsAlmostEqual(tr_m50.data(skip_dt:end), ...
                          sim_new_vc.i.data(skip_dt:end, 5), 'absolute', 1e-1);

