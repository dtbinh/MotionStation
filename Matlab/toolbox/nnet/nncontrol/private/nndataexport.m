function nndataexport(cmd,arg1,arg2,arg3)
%NNDATAEXPORT Data Export GUI for the Neural Network Controller Toolbox.
%
%  Synopsis
%
%    nndataexport(cmd,arg1,arg2,arg3)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:10:58 $


% CONSTANTS
me = 'Export Data.';

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig=findall(0,'type','figure','name',me);
if (size(fig,1)==0), fig=0; end

if length(get(fig,'children')) == 0, fig = 0; end

if fig
   ud = get(fig,'userdata');
end

if strcmp(cmd,'init')
  if strcmp(arg2,'ref')
    if ~exist(cat(2,tempdir,'nnmodrefdata.mat'))
      warndlg('There is no data to export.','Export Warning','modal');
      return      
    end
  else
    if ~exist(cat(2,tempdir,'nnidentdata.mat'))
      warndlg('There is no data to export.','Export Warning','modal');
      return      
    end
  end
  if fig==0  
    StdColor = get(0,'DefaultFigureColor');
    PointsToPixels = 72/get(0,'ScreenPixelsPerInch');
    StdUnit = 'points';
    ud.Handles.parent=arg1;
    ud.Handles.type_net=arg2;

%ud = ExportData;
%ud.ListData = struct('Names','','Objects',[]);

%---Open an Export figure
    fig = figure('Color',StdColor, ...
     'Interruptible','off', ...
     'BusyAction','cancel', ...
     'HandleVis','Callback', ...
    'MenuBar','none', ...
     'Visible','on',...
     'Name',me, ...
     'IntegerHandle','off',...
     'NumberTitle','off', ...
     'Resize', 'off', ...
     'WindowStyle','modal',...
     'Position',[193 127 275 140], ...
    'Tag','nndataexport');

%---Add the Export List controls
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
      'BackgroundColor',StdColor, ...
      'Position',PointsToPixels*[5 78 265 44], ...
     'Style','frame');
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
      'BackgroundColor',StdColor, ...
    'Position',PointsToPixels*[106 109 56 19], ...
    'String','Select', ...
    'Style','text');
    ud.Handles.nnplant = uicontrol('Parent',fig, ...
     'Units',StdUnit, ...
     'HorizontalAlignment','right', ...
    'BackgroundColor',StdColor, ...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[20 86 120 20], ...
    'String','Data Structure Name:', ...
    'Style','text', ...
    'Tag','Radiobutton1', ...
     'ToolTipStr','Defines the name of the data structure.',...
     'Value',1);
    ud.Handles.nnplantedit = uicontrol('Parent',fig, ...
    'Units','points', ...
    'BackgroundColor',[1 1 1], ...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[150 86 90 20], ...
    'String','tr_dat', ...
    'Style','edit', ...
     'ToolTipStr','You can select the name for the data structure.',...
    'Tag','EditText1');

  %---Add the window buttons
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Position',PointsToPixels*[5 5 265 70], ...
    'Style','frame');
    ud.Handles.DiskButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[14 41 125 20], ...
     'Callback','nncontrolutil(''nndataexport'',''disk'',gcbf);',...
    'String','Export to Disk', ...
     'ToolTipStr','Export the data structure to a file.',...
    'Tag','DiskButton');
    ud.Handles.WorkspaceButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[14 14 125 20], ...
     'Callback','nncontrolutil(''nndataexport'',''workspace'',gcbf);',...
    'String','Export to Workspace', ...
     'ToolTipStr','Export the data structure to the MATLAB workspace.',...
    'Tag','WorkspaceButton');
    ud.Handles.HelpButton= uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[155 14 102 20], ...
     'Callback','nncontrolutil(''nndataexport'',''windowstyle'',gcbf,''normal'');nncontrolutil(''nndataexporthelp'',''main'',gcbf);',...
    'String','Help', ...
     'ToolTipStr','Calls the help window for the export window.',...
    'Tag','HelpButton');
    ud.Handles.CancelButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
     'Position',PointsToPixels*[155 41 102 20], ...
     'Callback','nncontrolutil(''nndataexport'',''cancel'',gcbf);',...
    'String','Cancel', ...
     'ToolTipStr','Discard the export action and close this menu.',...
    'Tag','CancelButton');

  end
  set(fig,'UserData',ud,'visible','on','WindowStyle','modal')
  
elseif strcmp(cmd,'cancel')
   delete(fig)
   return;
   
elseif strcmp(cmd,'windowstyle')
   set(fig,'visible','on','WindowStyle',arg2)
   return;
   
elseif strcmp(cmd,'workspace') | strcmp(cmd,'disk')
   % We check if some option selected.
   if strcmp(ud.Handles.type_net,'ref')
      load(cat(2,tempdir,'nnmodrefdata.mat'),'tr_dat');
   else
      load(cat(2,tempdir,'nnidentdata.mat'),'tr_dat');
   end
   name_data=get(ud.Handles.nnplantedit,'string');
   if isempty(name_data),
      warndlg('There is no data to export.','Export Warning','modal');
      return      
   end
   
   overwrite=0;
   w = evalin('base','whos');
   Wname = {w.name};
   
   figure_variables=get(ud.Handles.parent,'userdata');
   parent_simulink=get(figure_variables.gcbh_ptr,'userdata');
      
   % We check for Controller and object structure.
   if ~isempty(strmatch(name_data,...
      Wname,'exact')),
      overwrite=1;
   end
   
   if strcmp(cmd,'workspace')
      if overwrite
         switch questdlg(...
              {'At least one of the items you are exporting to'
               'the workspace already exists.'
               ' ';
               'Exporting will overwrite the existing variables.'
               ' '
               'Do you want to continue?'},...
               'Variable Name Conflict','Yes','No','No');
            
        case 'Yes'
           overwriteOK = 1;
        case 'No'
           overwriteOK = 0;
        end % switch questdlg
      else
        overwriteOK = 1;
      end % if/else overwrite
      
      if overwriteOK 
        assignin('base',name_data,tr_dat);
        delete(fig)   
      end
   else
      fname = '*';
      fname=[fname,'.mat']; % Revisit for CODA -- is a .mat extension already provide
      [fname,p]=uiputfile(fname,'Export to Disk');
      if fname,
         fname = fullfile(p,fname);
         eval([name_data '= tr_dat;']);
         save(fname,name_data);
         delete(fig)   
      end
   end
   
end