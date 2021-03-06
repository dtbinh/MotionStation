## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} html_help_text (@var{name}, @var{outname}, @var{options})
## Writes a function help text to disk formatted as @t{HTML}.
##
## The help text of the function @var{name} is written to the file @var{outname}
## formatted as @t{HTML}. The design of the generated @t{HTML} page is controlled
## through the @var{options} variable. This is a structure with the following
## optional fields.
##
## @table @samp
## @item header
## This field contains the @t{HTML} header of the generated file. Through this
## things such as @t{CSS} style sheets can be set.
## @item footer
## This field contains the @t{HTML} footer of the generated file. This should
## match the @samp{header} field to ensure all opened tags get closed.
## @item title
## This field sets the title of the @t{HTML} page. This is enforced even if the
## @samp{header} field contains a title.
## @end table
##
## @var{options} structures for various projects can be with the @code{get_html_options}
## function. As a convenience, if @var{options} is a string, a structure will
## be generated by calling @code{get_html_options}.
##
## @seealso{get_html_options, generate_package_html}
## @end deftypefn

function [header, text, footer] = texi2html (text, options = struct (), root = "")
  ## If options is a string, call get_html_options
  if (ischar (options))
    options = get_html_options (options);
  endif
    
  ## Add easily recognisable text before and after real text
  start = "###### OCTAVE START ######";
  stop  = "###### OCTAVE STOP ######";
  text = sprintf ("%s\n%s\n%s\n", start, text, stop);
      
  ## Handle @seealso
  if (isfield (options, "seealso"))
    seealso = options.seealso;
  else
    seealso = @(args) html_see_also_with_prefix (root, args {:});
  endif

  ## Run makeinfo
  orig_text = text;
  [text, status] = __makeinfo__ (text, "html", seealso);
  if (status != 0)
    txi_out = orig_text (1:min (100, length (orig_text)));
    warning ("texi2html: couldn't parse texinfo: \n%s", txi_out); # XXX: make this an error
  endif
      
  ## Split text into header, body, and footer using the text we added above
  start_idx = strfind (text, start);
  stop_idx = strfind (text, stop);
  header = text (1:start_idx - 1);
  footer = text (stop_idx + length (stop):end);
  text = text (start_idx + length (start):stop_idx - 1);
  
  ## Hack around 'makeinfo' bug that forgets to put <p>'s before function declarations
  text = strrep (text, "&mdash;", "<p class=\"functionfile\">");
            
  ## Read 'options' input argument
  [header, title, footer] = get_header_title_and_footer (options, :, root);
endfunction

function expanded = html_see_also_with_prefix (prefix, varargin)
  header = "@html\n<div class=\"seealso\">\n<b>See also</b>: ";
  footer = "\n</div>\n@end html\n";
  
  format = sprintf (" <a href=\"%s%%s.html\">%%s</a> ", prefix);
  
  varargin2 = cell (1, 2*length (varargin));
  varargin2 (1:2:end) = varargin;
  varargin2 (2:2:end) = varargin;
  
  list = sprintf (format, varargin2 {:});
  
  expanded = strcat (header, list, footer);
endfunction

