function obj = plot_superpose(plots, axis_labels, title_str, props)

% plot_superpose - Multiple plot_abstract objects superposed on the same axis.
%
% Usage:
% obj = plot_superpose(plots, axis_labels, title_str, props)
%
% Description:
%   Subclass of plot_abstract. Contains multiple plot_abstract objects
% to be plotted on the same axis. This is different than the 
% plot_abstract/superpose, where only using the same plot command is allowed.
% Here, each plot_abstract can have its own special plotting command. Subclasses
% of plot_abstract is also allowed here. The decorations comes from this object
% and not children plots. This behavior is different than plot_stack, where
% each plot has its own decorations.
%
%   Parameters:
%	plots: Cell array of plot_abstract or subclass objects.
%	axis_labels: Cell array of axis label strings.
%	title_str: Plot description string.
%	props: A structure with any optional properties (passed to plot_abstract).
%		
%   Returns a structure object with the following fields:
%	plot_abstract, plots, props
%
% General operations on plot_superpose objects:
%   plot_superpose	- Construct a new plot_superpose object.
%   plot		- Plots this plot in the current axis. Abstract method,
%			needs to be defined for each subclass.
%
% Additional methods:
%	See methods('plot_superpose')
%
% See also: plot_abstract/superpose, plot_superpose/plot
%
% $Id$
% Author: Cengiz Gunay <cgunay@emory.edu>, 2004/09/22

%# TODO: decoration controls imposed by plot_stack is ignored!

if nargin == 0 %# Called with no params
  obj.plots = [];
  obj.props = struct([]);
  obj = class(obj, 'plot_superpose', plot_abstract);
elseif isa(plots, 'plot_superpose') %# copy constructor?
  obj = plots;
else
   if ~ exist('props')
     props = struct([]);
   end

   if ~ exist('axis_labels')
     axis_labels = [];
   end

   if ~ exist('title_str')
     title_str = '';
   end

   if iscell(plots)
     plots = cell2mat(plots);
   end

  obj.plots = plots;
  obj.props = props;

  %# Check if contained plots feature axis_labels
  for plot_num=1:length(plots)
    plot_axis_labels = plots(plot_num).axis_labels;

    if ~isempty(plot_axis_labels) 
      if ~isempty(plot_axis_labels{1})
	axis_labels{1} = plot_axis_labels{1};
      end
      if ~isempty(plot_axis_labels{2})
	axis_labels{2} = plot_axis_labels{2};
      end
    end
  end

  if isempty(title_str)
    title_str = plots(1).title;
  end

  obj = class(obj, 'plot_superpose', plot_abstract({}, axis_labels, title_str, ...
						   {}, '', props));
end

