function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:14 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%controlsmake creates the UICONTROLS.
%they are passed back in c.x with fieldnames
%mirroring the attribute name.  For example,
%c.att.Foo creates a uicontrol with handle
%c.x.Foo.  If the control creates a text field
%(for example a compound text/edit) the text
%field's handle is c.x.FooTitle

%controlsmake uses getinfo(c) to obtain the information
%it needs to automatically create uicontrols.  
%Information is stored in c.attx.Foo

c=controlsmake(c);

c.x.allTitle=uicontrol(c.x.all,...
   'style','text',...
   'String','Only execute subcomponents:',...
   'HorizontalAlignment','left');

%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

c.x.LayoutManager={c.x.allTitle
   [5 5]
   {c.x.minNumBlocksTitle c.x.minNumBlocks;
    c.x.minNumSubSystemsTitle c.x.minNumSubSystems
   [5] [5]
   c.x.isMaskTitle c.x.isMask(1)
   [5] c.x.isMask(2)
   [5] c.x.isMask(3)}};

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});