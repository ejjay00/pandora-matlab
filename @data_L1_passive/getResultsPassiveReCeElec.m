function [results a_doc] = getResultsPassiveReCeElec(pas, props)

% getResultsPassiveReCeElec - Estimates passive cell params based on Re Ce electrode model.
%
% Usage:
% results = getResultsPassiveReCeElec(pas, props)
%
% Parameters:
%   pas: A data_L1_passive object.
%   props: Structure with optional properties.
%     stepNum: Voltage pulse to be considered (default=1).
%     traceNum: Trace number to be analyzed (default=1).
%     delay: Current response delay from voltage step (default=calculated).
%     gL: Leak conductance (default=calculated).
%     EL: Leak reversal (default=calculated).
%     minResnorm: Lowest resnorm to accept (default=0.04).
%     minRe: Lowest Re value accepted.
%     compCap: Emulate compensation of this much capacitance [pF].
%
% Returns:
%   Re: Series resistance [MOhm].
%   Cm: Cell capacitance [nF].
%
% Description:
%   Integrates current response and divides by voltage difference to get
% capacitance. Membrane charge time constant is series resistance times
% capacitance. I=Cm*dV/dt+(V-EL)*gL
%
% See also: 
%
% $Id: getResultsPassiveReCeElec.m 896 2007-12-17 18:48:55Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2011/01/06

% Copyright (c) 2011 Cengiz Gunay <cengique@users.sf.net>.
% This work is licensed under the Academic Free License ("AFL")
% v. 3.0. To view a copy of this license, please look at the COPYING
% file distributed with this software or visit
% http://opensource.org/licenses/afl-3.0.php.

  vs = warning('query', 'verbose');
  verbose = strcmp(vs.state, 'on');

  
props = defaultValue('props', struct);
min_resnorm = getFieldDefault(props, 'minResnorm', 0.04);
min_Re = getFieldDefault(props, 'minRe', 50);
trace_num = getFieldDefault(props, 'traceNum', 1);
step_num = getFieldDefault(props, 'stepNum', 1);

results = struct;

if nargin == 0 % Called with no params or empty object
  results.Re = NaN;
  results.Cm = NaN;
  results.delay = NaN;
  results = mergeStructs(results, getParamsStruct(param_Re_Ce_cap_leak_act_int_t(nan(7,1))));
  results.resnorm=NaN;
  return;
end

% first find levels < -55 mV
pas_vsteps_idx = find(pas.data_vc.v_steps(step_num, :) < -55 & pas.data_vc.v_steps(step_num + 1, :) < -55);
% discretize to 1 mV steps 
quant_steps = ...
    quant(pas.data_vc.v_steps([step_num step_num+1], pas_vsteps_idx)', ...
          1);
% eliminate no-change steps
diff_steps = diff(quant_steps, 1, 2);
yes_change_idx = abs(diff_steps) > 0;
quant_steps = quant_steps(yes_change_idx, :);
pas_vsteps_idx = pas_vsteps_idx(yes_change_idx);
% find distinct values (do not process multiple steps of same values)
[pas_vsteps pas_vsteps_uidx] = ...
    unique(quant_steps, 'rows', 'first');
[largest_step, largest_step_idx] = ...
    max(abs(diff(pas_vsteps, 1, 2)));
pas_vsteps_idx = pas_vsteps_idx(pas_vsteps_uidx);

pas_res = calcSteadyLeak(pas, struct('traceNum', pas_vsteps_idx(largest_step_idx)));

if pas_res.gL > 0.025
  warning(['gL = ' num2str(pas_res.gL) ' uS is quite large. Expect estimation ' ...
                      'errors for gL and offset parameters.']);
end

% TODO: maybe allow small negative delays? Implement in param_Re_Ce_cap_leak_act_int_t
delay = max(0, calcDelay(pas, struct('traceNum', pas_vsteps_idx(largest_step_idx))));

if isfield(props, 'compCap')
  if length(props.compCap) > 1 % with Re
    capleak_f = ...
        param_Re_Ce_cap_leak_act_int_t(struct('gL', 0, 'EL', 0, 'Ce', 1e-10, ...
                                              'Re', props.compCap(2), ...
                                              'Cm', props.compCap(1)*1e-3, ...
                                              'delay', delay, 'offset', 0), ...
                                       'amplifier Re-cap comp', ...
                                       struct);
    capleak_f.Vm = setProp(capleak_f.Vm, 'selectParams', {}); %'delay', 'Ce'
  else
    mod_param_props = struct;
    mod_param_props.selectParams = {'delay'};
    capleak_f = ...
        param_cap_leak_int_t(struct('gL', 0, 'EL', 0, 'Cm', props.compCap*1e-3, ...
                                    'delay', delay, 'offset', 0), ...
                             'amplifier cap comp', ...
                             mod_param_props);
  end
  props.compCap = capleak_f;
  % simulate model
  cap_md = ...
      model_data_vcs(capleak_f, pas.data_vc, ...
                     [ pas.data_vc.id ': cap comp']);
  % add to I
  orig_i = pas.data_vc.i;
  pas.data_vc.i = pas.data_vc.i + cap_md.model_vc.i;
  
  % remove compCap
  props = rmfield(props, 'compCap');
end

[Re Cm peak_mag] = ...
    calcReCm(pas, mergeStructs(props, ...
                               mergeStructs(struct('traceNum', ...
                                                  pas_vsteps_idx(largest_step_idx), ...
                                                  'delay', delay), pas_res))); 

if verbose
  pas_res, Re, Cm, delay
end

if Re < min_Re
    warning(['Re=' num2str(Re) ' MOhm too small, setting to minimum 50 MOhm.']);
    Re = max(Re, min_Re); % limit
end

% look at peak capacitive artifact to scale plot axis
if peak_mag < 0
  y_lims = [peak_mag * 1.1,  -0.1 * peak_mag];
else
  y_lims = [-0.1 * peak_mag, peak_mag * 1.1];
end

% TODO: 
% - iterate once more to find a new Re estimate afterwards

results.int_Re_MO = Re;
results.int_Cm_pF = Cm * 1e3;
results.int_gL_nS = pas_res.gL * 1e3;
results.int_EL_mV = pas_res.EL;
results.int_offset_pA = pas_res.offset * 1e3;
results.est_delay_ms = delay;

capleakReCe_f = ...
    param_Re_Ce_cap_leak_act_int_t(...
      struct('Re', Re, 'Ce', 1.2e-3, 'gL', pas_res.gL, ...
             'EL', pas_res.EL, 'Cm', Cm, 'delay', delay, 'offset', pas_res.offset), ...
      ['cap, leak, Re and Ce (int)'], ...
      struct('parfor', 1));

% $$$ if isfield(props, 'compCap')
% $$$   capleakReCe_f = capleakReCe_f - capleak_f;
% $$$ end

a_md = ...
    model_data_vcs(capleakReCe_f, pas.data_vc, ...
                   [ pas.data_vc.id ': capleak, Re, Ce est']);
plotFigure(plotDataCompare(a_md, ' - integral method', ...
                           struct('levels', pas_vsteps_idx, ...
                                  'zoom', 'act', ...
                                  'axisLimits', ...
                                  [getTimeRelStep(pas.data_vc, ...
                                                  1, -.1) ...
                    * pas.data_vc.dt  * 1e3 + [0 3*Re*Cm], ...
                    y_lims])));

% fit to make a better Re estimate
if isfield(props, 'compCap') && false
  a_md.model_f.left.Vm = setProp(a_md.model_f.left.Vm, 'selectParams', ...
                                               {'Re', 'Ce', 'Cm', 'delay'});
else
  a_md.model_f.Vm = setProp(a_md.model_f.Vm, 'selectParams', ...
                                          {'Re', 'Ce', 'Cm', 'delay'});
end

narrowToWide();

if results.resnorm > min_resnorm
    warning(['fit failed, resnorm too large: ' num2str(results.resnorm) '. Doing a narrow fit...' ]);
    % fit very narrow range after step
    if isfield(props, 'compCap') && false
      a_md.model_f.left.Vm = setProp(a_md.model_f.left.Vm, 'selectParams', ...
                                              {'Re', 'Ce', 'Cm', 'delay'});
    else
      a_md.model_f.Vm = setProp(a_md.model_f.Vm, 'selectParams', ...
                                              {'Re', 'Ce', 'Cm', 'delay'});
    end
    runFit([1 -.1 3*Re*Cm], '2nd fit (narrow)');
    if results.resnorm > min_resnorm
        error(['narrow fit failed, resnorm too large: ' num2str(results.resnorm) ]);
    else
        % do full fit again
        warning(['narrow fit improved, doing a full fit again.' ]);
        runFit([1 -1 10], '3rd fit (full)');
        assert(results.resnorm < min_resnorm, ...
               ['Fit failed. Resnorm (' num2str(results.resnorm) ') > ' num2str(min_resnorm) ...
                ' after narrow and full fits.' ]);
    end
end

% rename all Vm_ columns
renameFields('Vm_', 'fit_');

% add units to names
renameFields('(fit_C.)', '$1_pF');
results.fit_Ce_pF = results.fit_Ce_pF * 1e3;
results.fit_Cm_pF = results.fit_Cm_pF * 1e3;

renameFields('(fit_EL)', '$1_mV');
renameFields('(fit_gL)', '$1_nS');
results.fit_gL_nS = results.fit_gL_nS * 1e3;

renameFields('(fit_Re)', '$1_MO');
renameFields('(fit_delay)', '$1_ms');
renameFields('(fit_offset)', '$1_pA');
results.fit_offset_pA = results.fit_offset_pA * 1e3;

function narrowToWide()
% new try:
% 1- do narrow fit first
% 2- then relax to larger range and more params

% TODO: use new Re and Cm estimates at some point?
  runFit([1 -.1 3*Re*Cm], 'Starting narrow fit');

  % do another fit with more params relaxed.
  % this also recalculates gL and EL based on the Re estimate.
  if isfield(props, 'compCap') && false
    a_md.model_f.left.Vm = ...
        setProp(a_md.model_f.left.Vm, 'selectParams', ...
                              {'Re', 'Ce', 'Cm', 'gL', 'EL', 'offset'});
  else
    a_md.model_f.Vm = ...
        setProp(a_md.model_f.Vm, 'selectParams', ...
                              {'Re', 'Ce', 'Cm', 'gL', 'EL', 'offset'});
  end
  runFit([1 -1 30], 'fit w/ relaxed gL,EL and offset');
  
  % last do narrower range
  runFit([1 -1 10], 'fit 1-10ms');
end

function oneFitsAll()
% old method:
% 1- fit 1-10 ms
% 2- relax and fit to 30 ms
% 3- then same relaxed params, fit 1-10 ms
% 4- if resnorm fails, do another narrow and full fit

  runFit([1 -1 10], 'fit 1-10ms');

% do another fit with more params relaxed.
% this also recalculates gL and EL based on the Re estimate.
if isfield(props, 'compCap') && false
  a_md.model_f.left.Vm = ...
      setProp(a_md.model_f.left.Vm, 'selectParams', ...
                            {'Re', 'Ce', 'Cm', 'gL', 'EL', 'offset'});
else
  a_md.model_f.Vm = ...
      setProp(a_md.model_f.Vm, 'selectParams', ...
                            {'Re', 'Ce', 'Cm', 'gL', 'EL', 'offset'});
end
runFit([1 -1 30], 'fit w/ relaxed gL,EL and offset');

% repeat regular fit
% $$$ a_md.model_f.Vm = setProp(a_md.model_f.Vm, 'selectParams', ...
% $$$                                         {'Re', 'Ce', 'Cm', 'delay'});

runFit([1 -1 10], 'fit 1-10ms');
end

function renameFields(re_from, re_to)
  results = cell2struct(struct2cell(results), ...
                          regexprep(fieldnames(results), ...
                                    re_from, re_to));
  
end

function runFit(fitrange, str)
  disp([ pas.data_vc.id ': ' str ])
  a_md = fit(a_md, ...
             '', struct('fitRangeRel', fitrange, ...
                        'fitLevels', pas_vsteps_idx, ...
                        'dispParams', 5,  ...
                        'dispPlot', 0, ...
                        'optimset', ...
                        struct('Display', 'iter', 'MaxFunEvals', 200)));
  if isfield(props, 'compCap') && false
    results = mergeStructs(getParamsStruct(a_md.model_f.left), results);
  else
    results = mergeStructs(getParamsStruct(a_md.model_f), results);
  end
  % reveal fit results (use normalized SSE)
  results.resnorm = a_md.model_f.props.ssenorm / length(pas_vsteps_idx);
  % ('zoom', 'act')
  % final fit
  fit_plot = ...
      plotDataCompare(a_md, [ ' - ' str ], ...
                      struct('levels', pas_vsteps_idx, ...
                             'axisLimits', ...
                             [getTimeRelStep(pas.data_vc, ...
                                             fitrange(1), -.1) ...
                      * pas.data_vc.dt  * 1e3 + [0 3*Re*Cm], ...
                      y_lims]));
  plotFigure(fit_plot);
  a_doc = doc_plot(fit_plot, [ 'Fitting passive parameters of ' pas.data_vc.id ', ' str '.' ], ...
                   [ get(pas.data_vc, 'id') '-passive-fits' ], struct, ...
                   pas.data_vc.id, props);
end
end