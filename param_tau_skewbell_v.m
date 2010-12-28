function a_ps = param_tau_skewbell_v(param_init_vals, id, props)
  
% param_tau_skewbell_v - V-dep time constant product skewed bell shaped function, y = tau0 * exp(sig*(x-v)/s) / (1+exp((x-v)/s)).
%
% Usage:
%   a_ps = param_tau_skewbell_v(param_init_vals, id, props)
%
% Parameters:
%   param_init_vals: Initial values of function parameters, p = [tau0 sig v s].
%   id: A string identifying this function.
%   props: A structure with any optional properties.
% 	   (Rest passed to param_func)
%		
% Returns:
%	a_ps: param_func.
%
% Description:
%   This form is the theoretical restul of using exponential Boltzmann
% functions for act and inact. See Eq (11) in Willms, Baro, Harris-Warrick
% and Guckenheimer (1998) for explanation.
%
% See also: param_func, param_tau_2sigmoids_v
%
% $Id: param_tau_skewbell_v.m 128 2010-06-07 21:36:08Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/12/16

  var_names = {'voltage [mV]', 'time constant [ms]'};
  param_names = {'tau0', 'sig', 'v', 's'};
  func_handle = @(p,x) (p.tau0 * exp(p.sig * (x-p.v) ./ p.s)) / (1 + exp((x-p.v) ./ p.s)) ;

  if ~ exist('props', 'var')
    props = struct;
  end

  sig_param_ranges = ...
      [0 100; 0 10; -100 100; 0 100]';
  props = mergeStructs(props, ...
                       struct('xMin', -100, 'xMax', 100, ...
                              'paramRanges', [sig_param_ranges]));
  
  a_ps = ...
      param_func(var_names, param_init_vals, param_names, ...
                 func_handle, id, props);


