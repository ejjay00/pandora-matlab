function [a_bundle test_names] = constrainedMeasuresPreset(a_bundle, preset, props)

% constrainedMeasuresPreset - Returns a dataset_db_bundle with constrained measures according to chosen preset.
%
% Usage:
% [a_bundle test_names] = constrainedMeasuresPreset(a_bundle, preset, props)
%
% Description:
%
%   Parameters:
%	a_bundle: A dataset_db_bundle object.
%	preset: Choose preset measure list (default=1).
%	props: A structure with any optional properties.
%		
%   Returns:
%	a_bundle: Modified bundle.
%
% See also: physiol_bundle/constrainedMeasuresPreset
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2006/06/13

if ~exist('props')
  props = struct;
end

if ~exist('preset')
  preset = 1;
end

p1_test_names = ...
    {'PulsePotAvg_H100pA', 'PulsePotMin_H100pA', 'PulsePotMinTime_H100pA', ...
     'PulsePotSag_H100pA', ...
     ... %# keep these three because they may be different than the averages:
     'RecIniSpontPotRatio_H100pA', 'RecIniSpontRateRatio_H100pA', 'IniRecISIRatio_H100pA', ...
     'RecSpont1SpikeRateISI_H100pA', 'RecSpont2SpikeRateISI_H100pA', ...
     'RecSpontFirstISI_H100pA', 'RecSpontFirstSpikeTime_H100pA', 'RecSpontISICV_H100pA', ...
     'RecSpontPotAvg_H100pA', ...
     'RecovSpikeAmplitudeMean_H100pA', 'RecovSpikeAmplitudeSTD_H100pA', ...
     'RecovSpikeBaseWidthMean_H100pA', 'RecovSpikeBaseWidthSTD_H100pA', ...
     'RecovSpikeFallTimeMean_H100pA', 'RecovSpikeFallTimeSTD_H100pA', ...
     'RecovSpikeInitVmBySlopeMean_H100pA', 'RecovSpikeInitVmBySlopeSTD_H100pA', ...
     'RecovSpikeInitVmMean_H100pA', 'RecovSpikeInitVmSTD_H100pA', ...
     'RecovSpikeMaxAHPMean_H100pA', 'RecovSpikeMaxAHPSTD_H100pA', ...
     'RecovSpikeMinTimeMean_H100pA', 'RecovSpikeMinTimeSTD_H100pA', ...
     'IniSpontISICV_0pA', 'IniSpontPotAvg_0pA', 'IniSpontSpikeRateISI_0pA', ...
     'SpontSpikeAmplitudeMean_0pA', 'SpontSpikeAmplitudeSTD_0pA', ...
     'SpontSpikeBaseWidthMean_0pA', 'SpontSpikeBaseWidthSTD_0pA', ...
     'SpontSpikeFallTimeMean_0pA', 'SpontSpikeFallTimeSTD_0pA', ...
     'SpontSpikeInitVmBySlopeMean_0pA', 'SpontSpikeInitVmBySlopeSTD_0pA', ...
     'SpontSpikeInitVmMean_0pA', 'SpontSpikeInitVmSTD_0pA', ...
     'SpontSpikeMaxAHPMean_0pA', 'SpontSpikeMaxAHPSTD_0pA', ...
     'SpontSpikeMinTimeMean_0pA', 'SpontSpikeMinTimeSTD_0pA', ...
     'PulseISICV_D40pA', 'PulseSFA_D40pA', 'PulseIni100msISICV_D40pA', ...
     'PulseIni100msRest1SpikeRateISI_D40pA', 'PulseIni100msRest2SpikeRateISI_D40pA', ...
     'PulseIni100msSpikeRateISI_D40pA', 'PulsePotAvg_D40pA', 'PulseSpikeAmpDecayTau_D40pA', ...
     'PulseSpikeAmpDecayDelta_D40pA', ...
     'PulseSpikeAmplitudeMean_D40pA', 'PulseSpikeAmplitudeSTD_D40pA', ...
     'PulseSpikeBaseWidthMean_D40pA', 'PulseSpikeBaseWidthSTD_D40pA', ...
     'PulseSpikeFallTimeMean_D40pA', 'PulseSpikeFallTimeSTD_D40pA', ...
     'PulseSpikeInitVmBySlopeMean_D40pA', 'PulseSpikeInitVmBySlopeSTD_D40pA', ...
     'PulseSpikeInitVmMean_D40pA', 'PulseSpikeInitVmSTD_D40pA', ...
     'PulseSpikeMaxAHPMean_D40pA', 'PulseSpikeMaxAHPSTD_D40pA', ...
     'PulseSpikeMinTimeMean_D40pA', 'PulseSpikeMinTimeSTD_D40pA', ...
     'PulseISICV_D100pA', 'PulseSFARatio_D100pA', 'PulseIni100msISICV_D100pA', ...
     'PulseIni100msRest1SpikeRateISI_D100pA', 'PulseIni100msRest2SpikeRateISI_D100pA', ...
     'PulseIni100msSpikeRateISI_D100pA', 'PulsePotAvg_D100pA', ...
     'PulseSpikeAmpDecayTau_D100pA', 'PulseSpikeAmpDecayDelta_D100pA', ...
     'RecIniSpontPotRatio_D100pA', 'RecIniSpontRateRatio_D100pA', ...
     'RecSpont1SpikeRateISI_D100pA', 'RecSpont2SpikeRateISI_D100pA', ...
     'RecSpontFirstISI_D100pA', 'RecSpontFirstSpikeTime_D100pA', 'RecSpontISICV_D100pA', ...
     'RecSpontPotAvg_D100pA', ...
     'PulseSpikeAmplitudeMean_D100pA', 'PulseSpikeAmplitudeSTD_D100pA', ...
     'PulseSpikeBaseWidthMean_D100pA', 'PulseSpikeBaseWidthSTD_D100pA', ...
     'PulseSpikeFallTimeMean_D100pA', 'PulseSpikeFallTimeSTD_D100pA', ...
     'PulseSpikeInitVmBySlopeMean_D100pA', 'PulseSpikeInitVmBySlopeSTD_D100pA', ...
     'PulseSpikeInitVmMean_D100pA', 'PulseSpikeInitVmSTD_D100pA', ...
     'PulseSpikeMaxAHPMean_D100pA', 'PulseSpikeMaxAHPSTD_D100pA', ...
     'PulseSpikeMinTimeMean_D100pA', 'PulseSpikeMinTimeSTD_D100pA', ...
     'RecovSpikeAmplitudeMean_D100pA', 'RecovSpikeAmplitudeSTD_D100pA', ...
     'RecovSpikeBaseWidthMean_D100pA', 'RecovSpikeBaseWidthSTD_D100pA', ...
     'RecovSpikeFallTimeMean_D100pA', 'RecovSpikeFallTimeSTD_D100pA', ...
     'RecovSpikeInitVmBySlopeMean_D100pA', 'RecovSpikeInitVmBySlopeSTD_D100pA', ...
     'RecovSpikeInitVmMean_D100pA', 'RecovSpikeInitVmSTD_D100pA', ...
     'RecovSpikeMaxAHPMean_D100pA', 'RecovSpikeMaxAHPSTD_D100pA', ...
     'RecovSpikeMinTimeMean_D100pA', 'RecovSpikeMinTimeSTD_D100pA', ...
     'PulseISICV_D200pA', 'PulseSFA_D200pA', 'PulseIni100msISICV_D200pA', ...
     'PulseIni100msRest1SpikeRateISI_D200pA', 'PulseIni100msRest2SpikeRateISI_D200pA', ...
     'PulseIni100msSpikeRateISI_D200pA', 'PulsePotAvg_D200pA', ...
     'PulseSpikeAmpDecayTau_D200pA', 'PulseSpikeAmpDecayDelta_D200pA', ...
     'PulseSpikeAmplitudeMean_D200pA', 'PulseSpikeAmplitudeSTD_D200pA', ...
     'PulseSpikeBaseWidthMean_D200pA', 'PulseSpikeBaseWidthSTD_D200pA', ...
     'PulseSpikeFallTimeMean_D200pA', 'PulseSpikeFallTimeSTD_D200pA', ...
     'PulseSpikeInitVmBySlopeMean_D200pA', 'PulseSpikeInitVmBySlopeSTD_D200pA', ...
     'PulseSpikeInitVmMean_D200pA', 'PulseSpikeInitVmSTD_D200pA', ...
     'PulseSpikeMaxAHPMean_D200pA', 'PulseSpikeMaxAHPSTD_D200pA', ...
     'PulseSpikeMinTimeMean_D200pA', 'PulseSpikeMinTimeSTD_D200pA'};

%# A minimal set
p2_test_names = ...
    {'PulsePotAvg_H100pA', 'PulsePotMin_H100pA', ...
     'PulsePotSag_H100pA', ...
     'RecSpont1SpikeRateISI_H100pA', 'RecSpont2SpikeRateISI_H100pA', ...
     'RecSpontPotAvg_H100pA', ...
     'IniSpontPotAvg_0pA', 'IniSpontSpikeRateISI_0pA', ...
     'PulseIni100msRest2SpikeRateISI_D40pA', ...
     'PulseIni100msSpikeRateISI_D40pA', ...
     'PulseSFARatio_D100pA', ...
     'PulseIni100msRest2SpikeRateISI_D100pA', ...
     'PulseIni100msSpikeRateISI_D100pA', 'PulsePotAvg_D100pA', ...
     'PulseSpikeAmpDecayTau_D100pA', 'PulseSpikeAmpDecayDelta_D100pA', ...
     'RecSpont2SpikeRateISI_D100pA', ...
     'RecSpontPotAvg_D100pA', ...
     'PulseSpikeAmplitudeMean_D100pA', ...
     'PulseSpikeBaseWidthMean_D100pA', ...
     'PulseSpikeFallTimeMean_D100pA', ...
     'PulseSpikeInitVmBySlopeMean_D100pA', ...
     'PulseSpikeInitVmMean_D100pA', ...
     'PulseSpikeMaxAHPMean_D100pA', ...
     'PulseSpikeMinTimeMean_D100pA', ...
     'PulseIni100msRest2SpikeRateISI_D200pA', ...
     'PulseIni100msSpikeRateISI_D200pA'};

     %#'SpontSpikeAmplitudeMean_0pA', ...
     %#'SpontSpikeBaseWidthMean_0pA', ...
     %#'SpontSpikeFallTimeMean_0pA', ...
     %#'SpontSpikeInitVmMean_0pA', ...
     %#'SpontSpikeMaxAHPMean_0pA', ...
     %#'SpontSpikeMinTimeMean_0pA', ...

test_weights = struct;
switch preset
  case 1
    %# Remove redundant or obscure entries, but still keep many.
    test_names = p1_test_names;
  case 2
    %# Same tests as in 1, but change weights
    test_names = p1_test_names;
    test_weights.PulsePotAvg_H100pA = 10;
  case 3
    %# Same tests as in 1, but change weights
    test_names = p1_test_names;
    test_weights.PulsePotAvg_H100pA = 100;
  case 4
    %# Same tests as in 1, but change weights 
    %# (increase H100 CIP potential, reduce sAHP level at D100)
    test_names = p1_test_names;
    test_weights.PulsePotAvg_H100pA = 10;
    test_weights.RecIniSpontPotRatio_D100pA = 10; 
    test_weights.RecIniSpontRateRatio_D100pA = 10;
  case 5
    %# Minimal 47 measures
    test_names = p2_test_names;
  case 6
    %# Same as 5, but match -100 pA potential
    test_names = p2_test_names;
    test_weights.PulsePotAvg_H100pA = 10;
    test_weights.PulsePotSag_H100pA = 10;
    test_weights.PulseSpikeAmplitude_D100pA = 10;
  case 7
    %# Same as 6, but also match f-I curve
    test_names = p2_test_names;
    test_weights.PulsePotAvg_H100pA = 10;
    test_weights.PulsePotSag_H100pA = 10;
    test_weights.PulseSpikeAmplitude_D100pA = 10;
    rate_factor = 1.5;
    test_weights.IniSpontSpikeRateISI_0pA = rate_factor;
    test_weights.PulseIni100msSpikeRateISI_D40pA = rate_factor;
    test_weights.PulseIni100msRest2SpikeRateISI_D40pA = rate_factor;
    test_weights.PulseIni100msSpikeRateISI_D100pA = rate_factor;
    test_weights.PulseIni100msRest2SpikeRateISI_D100pA = rate_factor;
    test_weights.PulseIni100msSpikeRateISI_D200pA = rate_factor;
    test_weights.PulseIni100msRest2SpikeRateISI_D200pA = rate_factor;
  otherwise
    error([ 'Preset ' num2str(preset) ': No such preset.']);
end

j_db = get(a_bundle, 'joined_db');

%# Add the parameters to list
test_names = { 1:get(j_db, 'num_params'), test_names{:} };

j_db = set(j_db, 'id', [ get(j_db, 'id') '; preset' num2str(preset) ]);

if ~ isempty(test_weights)
  j_db = setProp(j_db, 'testWeights', test_weights);
end

a_bundle = set(a_bundle, 'joined_db', j_db(:, test_names));


