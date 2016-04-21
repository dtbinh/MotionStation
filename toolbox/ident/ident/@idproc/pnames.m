function [Props,AsgnVals] = pnames(m, flag)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(M)  returns the list PROPS of
%   public properties of the object M (a cell vector), as well as 
%   the assignable values ASGNVALS for these properties (a cell vector
%   of strings).  PROPS contains the true case-sensitive property names.
%   These include the public properties of M's parent(s).
%
%   See also  GET, SET.

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.5.4.1 $  $Date: 2004/04/10 23:17:14 $


% IDMODEL properties
Props = {'Type';'Kp';'Tp1';'Tp2';'Tp3';...
        'Tz';'Tw';'Zeta';'Td';'Integration';'InputLevel';'InitialState';'DisturbanceModel'};

% Add public parent properties unless otherwise requested
% Also return assignable values if needed
model = pvget(m.idgrey,'idmodel');
if nargin==1
  if nargout==1 
     Props = [Props; pnames(model)];
  else
     AsgnVals = {...
             'Acronym like ''P1D'' (see help IDPROC)';...%[''P1''|''P2''|''P1(D)(I)(Z)''|''P2(D)(I)(Z)'']';...
             'Static Gain, Real number';...
              'Time Constant 1, Real number';...
             'Time Constant 2, Real number';...
             'Time Constant 3, Real number';...
             'Numerator time constant, Real number';...
               'Resonance Time, Real number';...
              'Damping Ratio, Real number';...
              'Dead Time, Real positive number';...
              '[''On''|''Off'']';...
              'The equilibrium level of the input signal, Real number';...
           '[''Model''|''Auto''|''Estimate''|''Zero''|''Backcast'']';...
           '[''Estimate''|''ARMA1''|''ARMA2''|''Fixed''|''None'']'...		 
     };
    [IDMProps, IDMVals] = pnames(model);
     Props = [Props ; IDMProps];
     AsgnVals = [AsgnVals ; IDMVals]; 
  end
end