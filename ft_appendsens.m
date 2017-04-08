function [sens] = ft_appendsens(cfg, varargin)

% FT_APPENDSENS concatenates multiple sens (elec) structures that have been 
% processed separately.
%
% Use as
%   combined = ft_appendsens(cfg, sens1, sens2, ...)
%
% See also FT_ELECTRODEPLACEMENT, FT_ELECTRODEREALIGN, FT_APPLY_MONTAGE

% Copyright (C) 2017, Arjen Stolk
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

% these are used by the ft_preamble/ft_postamble function and scripts
ft_revision = '$Id$';
ft_nargin   = nargin;
ft_nargout  = nargout;

% do the general setup of the function
ft_defaults
ft_preamble init
ft_preamble debug
ft_preamble loadvar varargin
ft_preamble provenance varargin
ft_preamble trackconfig

% the ft_abort variable is set to true or false in ft_preamble_init
if ft_abort
  return
end

Ndata = length(varargin);

% check if the input data is valid for this function
for i=1:Ndata
  if ~((isa(varargin{i}, 'struct') && isfield(varargin{i}, 'label') && isfield(varargin{i}, 'elecpos')))
    error('This function requires sens data as input.');
  end
end

% do a basic check whether the units and coordinate systems match
if isfield(varargin{1}, 'unit')
  sens.unit = varargin{1}.unit;
  for i=1:Ndata
    unit{i} = varargin{i}.unit;
  end
  unitmatch = all(strcmp(unit{1}, unit));
else
  unitmatch = 1;
  warning('no unit information present, assuming units match');
end
if isfield(varargin{1}, 'coordsys')
  sens.coordsys = varargin{1}.coordsys;
  for i=1:Ndata
    coordsys{i} = varargin{i}.coordsys;
  end
  coordsysmatch = all(strcmp(coordsys{1}, coordsys));
else
  coordsysmatch = 1;
  warning('no coordinate system information present, assuming coordinate systems match');
end

if ~unitmatch || ~coordsysmatch
  error('the units or coordinate systems of the input data structures are not equal');
end

% concatenate
haslabelold = 0;
haschanposold = 0;
for i=1:Ndata
  % the following fields should be present in any elec structure
  if isfield(varargin{i}, 'label')
    label{i} = varargin{i}.label;
  end  
  if isfield(varargin{i}, 'elecpos')
    elecpos{i} = varargin{i}.elecpos;
  end 
  if isfield(varargin{i}, 'chanpos')
    chanpos{i} = varargin{i}.chanpos;
  end
  % the following fields might be present in an elec structure
  if isfield(varargin{i}, 'labelold')
    labelold{i} = varargin{i}.labelold;
    haslabelold = 1;
  else % use current labels in case there are no old labels
    labelold{i} = varargin{i}.label;
  end
  if isfield(varargin{i}, 'chanposold')
    chanposold{i} = varargin{i}.chanposold;
    haschanposold = 1;
  else % use current chanpos in case there are no old chanpos
    chanposold{i} = varargin{i}.chanpos;
  end
end

sens.label = cat(1,label{:});
sens.elecpos = cat(1,elecpos{:});
sens.chanpos = cat(1,chanpos{:});

if haslabelold % append in case one of the elec structures has old labels
  sens.labelold = cat(1,labelold{:});
end
if haschanposold % append in case one of the elec structures has old chanpos
  sens.chanposold = cat(1,chanposold{:});
end

% ensure a full sens description
sens = ft_datatype_sens(sens);

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous varargin
ft_postamble provenance sens
ft_postamble history sens
ft_postamble savevar sens
