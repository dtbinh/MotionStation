#!/usr/local/bin/perl -w
# Parse a C/C++ header file and build up three data structures: the first
# is a list of the prototypes defined in the header file; the second is 
# a list of the structures used in those prototypes.  The third is a list of the 
# typedef statements that are defined in the file
#
# The header file must have already been processed by the pre-processor if it contains 
# preprocessor code.
#
# Options supported:
# 
#
# command line:
# prototypes [options] input.i  [optional headers to find protoypes in]  
#
# Copyright 2003 The MathWorks, Inc.
# $Revision: 1.1.6.7 $ 
$cmdline=join ' ', @ARGV;
parsArgs(debug=>0,outfile=>'-',calltype=>'cdecl');
$outfile=$options{outfile};
open OUTFILE,">$outfile" or die "Can not open output file $outfile because $!";

open INFILE ,"<$ARGV[0]" or die "Can not open file $ARGV[0] because $!";

%baseTypes = qw(int8_t int8 int8_T int8 char int8 short int16 int int32 long int32 __int64 int64 longlong int64 shortint int16 longint int32); 
%otherTypes = qw(bool bool struct struct unsigned uint32 float single double double enum int32);
for (keys %baseTypes) {
    my $bt=$baseTypes{$_};
    $types{$_}=$bt;
    $types{'unsigned' . $_ }='u'.$bt ;    
}
for (keys %otherTypes) {
	$types{$_}=$otherTypes{$_};
}
for (keys %types) {
   my $bt=$types{$_};
    $types{$_ . 'Ptr'}=$bt . 'Ptr';
#    $types{$_ . 'PtrPtr'}=$bt . 'PtrPtr'; 
 }

#fixup strange types
$typeOverrides{'bool'}=1;

$types{'int64_T'}='int64';
$types{'uint64_T'}='uint64';
$types{'charPtr'}='string';
$types{'charPtrPtr'}='stringPtrPtr';
$types{'mxArrayPtr'}='MATLAB array';
$mxArrayPtrPtr='MATLAB array Ptr';
$types{'mxArrayPtrPtr'}=$mxArrayPtrPtr;
$types{'void'}='void';  # for void functions
$types{'voidPtr'}='voidPtr';  
$types{'voidPtrPtr'}='voidPtrPtr';  
 
$types{'...'}='vararg';
#    An optional typefile may be specified the format of which is "ctype matlabtype" 
if (exists $options{typefile}) {
    open TYPEFILE,"<$options{typefile}" or die "Can not open typefile $options{typefile} because $!";
    while (<TYPEFILE>) {
        chomp $_;
        ($ctype,$mtype)=split(/\s+/,$_);
        if (defined( $ctype) and defined( $mtype)) {
            print "Adding user type $ctype to be $mtype\n"  if ($options{debug} eq 'types');
            $types{$ctype}=$mtype; 
            $typeOverrides{$ctype}=1;
        }
    }
    close TYPEFILE;
}

if (exists $options{thunkfile}) {
    my @mltypes=qw(int8 int16 int32);
    my @ctypes=qw(char short long);
    my $i;
    open THUNKFILE,"> $options{thunkfile}" or die "Can not open C output file $options{thunkfile} because $!";
    print THUNKFILE "/* C thunk file for functions in $outfile generated on " , scalar localtime , ". */\n\n";
    for ($i=0;$i<@ctypes;$i++) {
        print  THUNKFILE "typedef $ctypes[$i] $mltypes[$i];\n";
        print  THUNKFILE "typedef unsigned $ctypes[$i] u$mltypes[$i];\n";
        push @mltypes,"u$mltypes[$i]";
    } 
    print  THUNKFILE "typedef void * voidPtr;\n";
    print  THUNKFILE "typedef char * string;\n";
    push @mltypes,qw(string voidPtr);
    foreach (@mltypes) {
        $MatlabType{$_}=undef;
    }
}

#$types{'unsigned'}='uint';
#$types{'unsignedPtr'}='uintPtr';
#$types{'unsignedPtrPtr'}='uintPPtr';
#$types{'struct'}='struct';
#$types{'structPtr'}='structPtr';
#$types{'structPtrPtr'}='structPPtr';
#$types{''}='error';
$functionCount=1; #matlab starts at one
$structCount=1;
$inSrcFile=1;  #if no line statements then all code counts
$packing=8;
for (@ARGV) {
    s/([\w\s]+)\.[\w\s]*$/$1/;
    push @SrcFiles,$_;
}
$SrcFiles=join '|',@SrcFiles;
print "SrcFiles is $SrcFiles.\n" if $options{debug};
$str='';
if ( $outfile=~/([^\\]+)\.[^\\]+$/ ) {
    $writeingfunc=1;
    print OUTFILE "function [methodinfo,structs,enuminfo]=$1;\n";
    #($mday,$month,$year)=localtime[3-5];
    print OUTFILE "%This function was generated by the perl file prototypes.pl called from loadlibary.m on " ,scalar localtime ,"\n";
    print OUTFILE "%loadlibary options:'$options{loadlibrarycmd}' \n" if exists $options{'loadlibrarycmd'} ; 
    print OUTFILE "%perl options:'$cmdline'\n"; 
    print OUTFILE "ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.\n";
    print OUTFILE "fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);\n";
    print OUTFILE "structs=[];enuminfo=[];fcnNum=1;\n";
} else {
       $writeingfunc=0;
    }
$srcFile='';
while (<INFILE>)
{
    # Ignore pre-processor directives and blank lines
    chomp;
    next if  /^\s*$/; #Just skip white space lines
    if (/^\s*#/) {
     #print "skiping $_";
     if (/^#line\s+\d+\s+\"(.*)\"/ || /^# \d+ \"(.*)\" \d+$/ ) {
        if ($1 ne $srcFile) {
            $srcFile=$1;
            $inSrcFile=/\b$SrcFiles\b/;
            print "dumping ************* \n'$str'\n *****because of include file change\n" if ($options{debug} && $str ne '') ;  
            $str='' ;  #clear out string for safty
            print "inSrcFile is $inSrcFile for $_\n" if ($options{debug} eq 'srcfile');
     	}
     }
     if (/^\s*#pragma\s+pack/) {
         if (/^\s*#pragma\s+pack\s*\(\s*(\d+)\s*\)/) {
            $packing=$1;
         } else {
            print "Unsupported packing pragma\nfound on line $. of input\n'$_'\n";
        }
     }
     next; 
    }
    #split up a line on simicolens because this script only can deal with one statement at a time
    @statements=split /;/ ;
    @statements=map { $_ . ';'} @statements; #put back the semi's
    $statements[-1]=substr($statements[-1],0,-1) unless /;$/;  #remove the last semi if there was not one there

    foreach $st (@statements) 
    {
    $str = $str . ' ' . $st;    #space is needed becase line end is a delimiter
    print "str '$str' is blank\n" if (length($str)<2 && $options{debug});
    
    #check for matched parens
    my $t=$str;
    if ($t=~ tr/{([// != $t=~tr/})]//) {
        #print "odd parans found appending str is '$str'\n";
        next; 
    }

    
    # Collapse multiple whitespace to a single space character
    $str =~ s/\s+/ /g;

    #pull Windows __declspec(dllimport) and export they confuse other processing
    $str=~s/__declspec\s?\(.*?\)//;


    if (!/;\s*$/) { # line does not end in semi just concat it
        #print "Appending $_\n";
        next if ($str=~/^ ?(typedef|struct|enum) /);
        if ($str=~/\} ?$/) {
             print "**** found function '$str'\n" if $options{debug};;
             $str='';
             next;
        }  
        #print "**** found no semi in '$str'\n" if $options{debug};
        next;
    }

 
    # Build an association list of typedefs. The goal is to be able to
    # resolve a defined type into the native C/++ type underlying it
    # structure
    if ($str =~/typedef /) { 
    
        if ($str =~/typedef (struct|enum) \w*\s?\{[^}]*$/) {# append more data
            print "**** found partial $1 in $str\n" if $options{debug};
            next;
        }
        
        if ($str =~/typedef enum/) { #found an enum
            my $tstr=$';
            my $enumName;
            my $enumTypes;
            
            if ($tstr =~ /^\s?(\w+)\s?\{(.*)\}([^;]*)/) { #It has a name
                $enumName=$1;
                $enumDefines=$2;
                $enumTypes=$3;
                ProcessTypedef('enum','enum'. $enumName);
            } elsif ($tstr =~/^\s?\{(.*)\} ?(\w+) ?,?([^;]*)/) { # it is nameless
                $enumDefines=$1;
                $enumName=$2;
                $enumTypes=$3;
            } else {
                print "error matching enum typedef in '$str' trying more data.\n" if $options{debug};
                next;
            }
            if ($enumDefines=~/^\s*$/) { #no actual enum values
    	        AddType($enumName,'int32');
    	    }else {
                AddType($enumName,MakeMatlabVar($enumName));
                $enumName=MakeMatlabVar($enumName);
                ProcessTypedef($enumName,$enumTypes);
                ProcessEnum($enumName,$enumDefines);
            }
            $str='';
            next;        
        }
    
        if ($str =~/typedef struct (\w+)\s?\{(.*)\}\s*([^;]*)/ ) {# we got a struct 
            print "Found struct $1 to be $3.\n" if $options{debug} eq 'structs';
            ProcessStruct($1,$2,$3);
            $str='';
            next;
        }

        if ($str =~/typedef struct\s?\{(.*)\}\s*(\w+) ?,?([^;]*)/ ) {# we got nameless a struct
            print "Found nameless struct to be $2.\n" if $options{debug} eq 'structs';
            if (exists $types{$2})
            {
                DumpError("Error type '$2' is multiply defined.\n"); 
            }
            my $typedefs=$3;
            my $sname=$2;
            ProcessStruct($sname,$1,$typedefs);
            $str='';
            next;
        }
        if ($str =~/typedef .*?\(.*\b(\w+)\s*\) ?\(.*\).*;/) {
        #if ($str =~/typedef .*?\([* ]*(\w+)\) ?\(.*\).*;/) {
        #if ($str =~/typedef .*\)\s*;/) {
            print "found funtion prototype typedef '$str'.\n" if $options{debug};
            AddType($1,'FcnPtr');
            $str='';
            next;
        }
        
        if ($str =~/typedef([^;,*]+)([*\s]+\w+.*)\;/) #one line typedef
        {
            $typedef = $1;
            $newtypes = $2;
            $newtypes=arrayToPtr($newtypes);
            if ($typedef =~ /^ (struct|enum)\s*\{/) {
                DumpError("Punted typedef because found '$1'.");
                next;
            }            
            # Chop off leading and trailing spaces
            $newtypes =~ s/^[ \t]+//g;
            $newtypes =~ s/[ \t]+$//g;
            $typedef =~ s/^[ \t]+//g;
            $typedef =~ s/[ \t]+$//g;
            print "defining '$newtypes' to be '$typedef'\n" if $options{debug} eq 'types';
            ProcessTypedef($typedef,$newtypes);
            $str='';
            next;
        }
    } elsif ($str =~/^\s*enum\s*(\w+)\s*\{(.*?)\}\s*;/) {#found a naked enum
    	if ($2=~/^\s*$/) {#no actual enum values
    	    AddType($1,'int32');
    	}else {
            ProcessEnum($1,$2);
            ProcessTypedef('enum','enum'. $1);
        }
        $str='';
    } elsif ($str =~/^\s*struct\s+(\w+)\s*\{(.*?)\}\s*;/) {#found a naked struct
        ProcessStruct($1,$2,'');
        $str='';
    } elsif ($str =~/^\s*struct\s+(\w+)\s*;/) {#found a struct forward decleration
        ProcessStruct($1,'','');
        $str='';
    }elsif ($str =~/^[^{}();]*;\s*/) {
        #basic data decleration drop it
        print "found simple data decleration of $str\n" if $options{debug};
        $str='';
        next;
#    } elsif ($str =~/^[^{}();]*?[^\w]+\([^,]+\)[^{}();]+;\s*/) {
    } elsif ($str =~/^.*\w+ ?; ?/) {
        #advanced (one with parens /casting) data decleration drop it
        print "found advanced data declaration of $str\n" if $options{debug};
        $str='';
        next;
    } elsif ($str =~/^.*?\( ?\* ?(\w+)\) ?\(.*\) ?; ?/) {
#    } elsif ($str =~/^.*?\( ?\* ?\w+\)/) {
        #function pointer data decleration drop it
        print "found function pointer data declaration of $str\n" if $options{debug};

        $str='';
        next;
    } elsif ($str =~ /^ ?(.*?)(\w+) ?\((.*?)\) ?;/) {
    # Function prototype. Emit a line of MATLAB code to build up the function
	if (!$inSrcFile) {
                print "Function '$2' skipped because srcfile is '$srcFile'.\n" if $options{debug} eq 'srcfile';
		$str = "";
		next;
	}
        $ftype= $rtype = $1;
        $name = $2;
        $pstr = $3;
        if ($pstr=~/\(/) {
            # supporting this will require rewriting the parameter parser
            print "Function $name skipped because '$pstr' contains function pointer arguments.\n" if $options{debug};
            $str="";
            next;
        } 
    	$calltype=$options{calltype};
        #pull any 'extern' statements
        if ($rtype =~ s/\bextern\b//g) {
            $rtype =~ s/\"C\"//; # did it have extern "C" ?
        }
        
        #pull any 'stdcall' statements. WINAPI is present to help reduce the need for windows.h 
        if ($rtype =~ s/\b(_*stdcall|WINAPI)\b//g) {
            $calltype='stdcall';
        }

        if ($rtype =~ s/\b_*cdecl\b//g) {
            $calltype='cdecl';
        }
    		
        $lhs=GetUddType($rtype);
        print "function '$name' type is $ftype striped is '$rtype' translated to $lhs\n" if ($options{debug} eq 'functions');

        #$pstr=~s/(\w+)\s*\[\]/\*$1/g; # change var[] to *var
        @parameters = split(/,/, $pstr);
        # Print out the parameter list 
        foreach $parameter (@parameters)
        {
            #print "Paramiter is $parameter\n";
            #clean multiple whitespace to single space
            $parameter =~ s/\s{2,}/ /g;
            # Chop off leading and trailing whitespace
            $parameter =~ s/^\s+//g;
            $parameter =~ s/\s+$//g;

            $parameter=arrayToPtr($parameter) if $parameter=~/\[/;

            if ($parameter =~/^(.*[ *])(\w+)$/) 
            {                
                #get rid of the variable if present
                $parameter=$1;
                $paramName=$2;
                # could be $parameter=unsigned $paramName=long
                if (exists $types{cleanupType($paramName)})
                {
                    #Rebuild the parameter
                    $parameter.=$paramName;     
                    $paramName='';               
                }
            } else {
                $paramName='';
            }
            # fix up types that have array declerations ie int[]
            $parameter=~s/(\*+)(\w+)$/$2$1/;
            $parameter=GetUddType($parameter);            
#            print "'$parameter', ";
        }
        #now print out prototype to the file
        print OUTFILE "% $str \n";
        #is it a mex style function?
        if (@parameters==4 && $lhs eq 'void' && $parameters[0] eq 'int32' && $parameters[2] eq 'int32'
            && $parameters[1] eq $mxArrayPtrPtr && $parameters[3] eq $mxArrayPtrPtr) {
                $calltype='matlabcall'
            }
        print OUTFILE "fcns.name{fcnNum}='$name'; ";
        $alias=MakeMatlabVar($name);
        print OUTFILE "fcns.alias{fcnNum}='$alias'; " if $alias ne $name;
        if (exists $options{thunkfile} && ($calltype ne 'matlabcall')) {
            my $thunkname=addFunctionThunk($lhs,@parameters);
            print OUTFILE "fcns.thunkname{fcnNum}='$thunkname';";
        }
            
            
        print OUTFILE "fcns.calltype{fcnNum}='$calltype'; ";
        if ($lhs eq 'void') {
            print OUTFILE "fcns.LHS{fcnNum}=[]; ";
        } else {
            print OUTFILE "fcns.LHS{fcnNum}='$lhs'; ";
        }
        if (@parameters==0 || $parameters[0] eq 'void') {
            print OUTFILE "fcns.RHS{fcnNum}=[];";
        }else {
            print OUTFILE "fcns.RHS{fcnNum}={'" ,join("', '",@parameters),"'};";
        }
        print OUTFILE "fcnNum=fcnNum+1;\n";
        $functionCount++;
        print "function string was '$str'\n" if ($options{debug} eq 'functions');
        $str = "";
    } 
        #can the string be dumped?
        print "Dumping '$str'\n" if ($options{debug} && length($str)>1);
        $str="";
}
}

print "Last string was '$str'\n" if ($options{debug} && length($str)>1);

for (@structOrder) {
    if (exists $typesUsed{$_}) {
        if (!exists $structs{$_}) {
            print "warning struct $_ not found\n";
        } else {
            print OUTFILE "structs.$_.packing=$structPacking{$_};\n";
            print OUTFILE "structs.$_.members=struct('",join( "', '",@{$structs{$_}}),"');\n"; 
            $structCount++;
        }
    }
}

for (keys %enums) {
    if (exists $typesUsed{$_}) {
        print OUTFILE "enuminfo.$_=struct(" ,join(",",@{$enums{$_}}) , ");\n"; 
    }
}    
    
print OUTFILE "methodinfo=fcns;" if $writeingfunc;
#end of main function


##foreach $i (0..scalar @torder - 1)
#foreach $i (@torder)
#{
##    $key = $torder[$i];
#    print "types.$i = '$types{$i}';\n";
#}
sub MakeStructName {
    MakeMatlabVar($_[0],'struct_');
}


#clean up a type name to one that is representable in matlab as a variable name
sub MakeMatlabVar {
    $_=$_[0];
    my $rep=defined $_[1] ? $_[1] : '';
    s/^_+/$rep/;  # change leading _ they are illegal in matlab
    $_;
}
    
#create a new type basictype is the matlab type 
sub AddType {
    my $newtype=$_[0];
    my $basictype=$_[1];
    die if (!defined $newtype || !defined $basictype );
    if (exists $types{$newtype} and $types{$newtype} ne 'error') {
         print ("Error attempt to define '$newtype' a second time on line $. current defininition is '$types{$newtype}'.\n"); 
    }
    else {
        print "Creating type '$newtype' to be '$basictype'\n" if ($options{debug} eq 'types');
        $types{$newtype} = $basictype;
    }
}

sub ProcessTypedef {
    my $basetype=$_[0];
    my $newtype;
    my @newtypes=split ',',$_[1];
#    print "newtypes is '@newtypes' split from '$_[1]'\n";
    for (@newtypes) {
        $_=arrayToPtr($_) if /\[/;
        if (/\*/)
        {
            if (!defined($_) or !defined($basetype) ){
                print "one of '$_' and '$basetype' was not defined\n";
                next;
            }
                
            my $type=$basetype . $_;
            #print "working string '$type'\n";
            $type =~/^(.*[* ])(\w+)\s*/;
            $newtype=$2;
            $newbase=cleanupType($1);
        }  else {
            $newtype=$_;
            $newbase=cleanupType($basetype);
        }
        #clean all whitespace 
        $newtype =~ s/\s+//g;

        if (exists $types{$newtype})
        {
            if (!exists $typeOverrides{$newtype}) {
                if ($types{$newtype} ne GetUddType($newbase))  {
                    DumpError("Type '$newtype' is multiply defined.\n"); 
                } else {
                    print "Found second identical definition of type $newtype.\n" if $options{debug} eq 'types';
                }
            }
        } else {
            AddType($newtype,GetUddType($newbase));
        }
        $_=$newtype;
    }
    $newtypes[0];
}

sub ProcessEnum {
    my $name=$_[0];
    my $members=$_[1];
    my @ed;

    my @memb=split ',', $members;
    my $value=0;
    print "Found enum $name.\n" if $options{debug} eq 'enums';
    for (@memb) {
        s/\s//g; #trim all spaces
        next if ($_ eq ''); 
        if (/^(\w+)=(.*)$/) {
            $_=$1;
            $value=$2;
            if ($value=~/[-+]?\w+$/) {
                print "    Adding enum $1 to be a value of $value," if $options{debug} eq 'enums';
                $value=$enumValueMap{$value} if exists $enumValueMap{$value};
            } else { # value may not be parsable
                $value=$& if $value=~/0?[xXbB]?\d+/;
                $value=eval($value);
            }
            $value=oct($value) if $value=~/^0/;
            print "translated to '$value'.\n" if $options{debug} eq 'enums';
            
        } else {
            $value++;
        }
        $enumValueMap{$_}=$value;
        $_=MakeMatlabVar($_);
        push @ed,"'$_',$value";
    }
    $enums{$name}=\@ed; 
    if ($inSrcFile) {
        $typesUsed{$name}=[];
    }
    #print OUTFILE "structinfo{$structCount}=struct('name','$sname','" ,join( "', '",@sd),"');\n"; 
    #$structCount++;
}


# mark a datatype as used by a function that will be imported
sub AddUsedType {
    $_=$_[0];
    s/Ptr//g;
    if ($options{debug} eq 'types')
    {
        print "Found use of struct $_\n" if exists $structs{$type};
        print "Found use of enum $_\n" if exists $enums{$type};
    }
    $typesUsed{$_}=[];
}
    
 
sub ProcessStruct {
    my $cname=$_[0];
    my $sname=MakeMatlabVar($cname,'s_');
    my $members=$_[1];
    my $types=$_[2];
    my @sd;
    if ($members=~/:/) {
        print "Bitfields are unsupported in structures. Structure $sname skipped.\n" ;
        return;
    }
    if ($members=~/\bunion\b/) {
        print "Unions are unsupported in structures. Structure $sname skipped.\n" ;
        return;
    }
    AddType($cname,$sname) if $cname ne $sname;
    AddType($sname,$sname);
    ProcessTypedef($sname,$types);

    my @memb=split ';', $members;
    my $errcount;
    for (@memb) {
        if (/^(.*?)\b(\w+)\s?,(.*)$/) {  # if multiple vars of same type
             my $type=$1;
             my $var1=MakeMatlabVar($2,'m_');
             my @othervars=split ',', $3;
             print "Found multiple struct members type=$type, var1=$var1, othervars=@othervars\n" if ($options{debug} eq 'structs');
             push @sd,$var1;
             push @sd,GetUddType($type);
             
             for (@othervars) {
                my $st=$type . ' ' .$_;
                if ($st=~/^(.*)\b(\w+)\s*$/) {
                    my $t=$1;
                    my $var=$2;
                    print "from $st Adding var $var of type $t\n" if ($options{debug} eq 'structs');
                    push @sd,(MakeMatlabVar($var,'m_'),GetUddType($t));
                } else {
                    push @sd,('error' . $errcount++ ,$_) if (!/^ ?$/);
                }
            }           
        } elsif (/^(.*)\b(\w+)\s*$/) {
            my $var=MakeMatlabVar($2,'m_');
            my $type=$1;
            push @sd,$var;
            push @sd,GetUddType($type);
        } elsif (/^(.*)\b(\w+)\s*\[\s*(\n+)\s*\]\s*$/) { #sized array
            my $var=MakeMatlabVar($2,'m_');
            my $type=$1;
            my $size=$3;
            print "found sized array of $1 size $3 in structure\n " if ($options{debug} eq 'structs');
            push @sd,$var;
            push @sd,GetUddType($type).'#'.$size;
        } else {
            push @sd,('error' . $errcount++ ,$_) if (!/^ ?$/);
        }
    }

    push @structOrder,$sname;
    $structs{$sname}=\@sd;
    $structPacking{$sname}=$packing; 
    if ($inSrcFile) {
        $typesUsed{$sname}=[];
    }
    #print OUTFILE "structinfo{$structCount}=struct('name','$sname','" ,join( "', '",@sd),"');\n"; 
    #$structCount++;

}

# get the udd type for a given c type
sub GetUddType{
    my $type=cleanupType($_[0]);
    if (exists $types{$type})
    {
        $type=$types{$type};
#        if ($inSrcFile && exists $structs{$type} ) {
        if ($inSrcFile  ) {
            AddUsedType($type);
        }
        
    } else { 
        #DumpError("Type '$type' was not found. A add a typedef to the header file defining it as a known type.");
        my $deftype='error';
        if ($type=~/Ptr(Ptr)?$/) {
             $deftype=defined $1 ? "voidPtr$1" : "voidPtr";
        }
        print "Type '$type' was not found on line on $. defaulting to type $deftype.\n" if $options{debug};
        $type=$deftype;
    }
    $type;    
}

sub arrayToPtr{
    $_=$_[0];
    s/(\w+)\s*\[\s*\w*\s*\]/\*$1/g;
    return $_;
}


# Take a c type and remove all extra information and change * to Ptr or PtrPtr
sub cleanupType{
    my $type=$_[0];
    #pull any 'const' statments
    $type =~ s/_{0,2}const//g;
    #pull any 'signed' statements
    $type =~ s/\bsigned\b//g;
    
    #pull any 'struct' statements
    $type =~ s/\bstruct\b//g;
 
    #clean all whitespace 
    $type =~ s/\s+//g;
        
    $ptr=index($type, "*");
    if ($ptr>=0) {
        $type =~ s/\*/Ptr/g; 
        if (!exists $types{$type}) { # check to see if the base type exists and if so add the Ptr type       
            $basetype=substr($type,0,$ptr); 
            if (exists $types{$basetype}  ) { #create the new type
                #create a new pointer type
                $newtype=$type;
                $newtype=~s/$basetype/$types{$basetype}/;
                print "Dynamicly adding type '$type' to be '$newtype'\n" if ($options{debug} eq 'types');
                AddType($type,$newtype); 
            } else {
                print "Type '$type' not added because could not find basetype of '$basetype'\n" if ($options{debug} eq 'types');
            }                
        }            
    }
    $type;
}


sub addFunctionThunk {
    my @params;
    my $thunkname;
    my $p;
    foreach (@_) {
        $_='voidPtr' if /Ptr/;
        $_='int' if !exists $MatlabType{$_};
    }
    $thunkname=join("",@_) . 'Thunk';
    if (exists $thunkTable{$thunkname}) {
        return $thunkname;
    }
    $thunkTable{$thunkname}=undef;
    my ($lhs,@rhs)=@_;
    print THUNKFILE "$lhs $thunkname(void fcn(),const char *callstack,int stacksize)\n{\n";
    if (@rhs==1 && $rhs[0] eq 'void') {
        @params=();
    } else {
        $p=0;
        foreach (@rhs) {
            print THUNKFILE "\t$_ p$p;\n";
            push @params,"p$p";
            $p+=1;
        }
        $p=0;
        foreach (@rhs) {
            print THUNKFILE "\tp$p=*(const $_*)callstack;\n";
            print THUNKFILE "\tcallstack+=sizeof(p$p);\n";
            $p+=1;
        }
    }
    if ($lhs eq 'void') {
        print THUNKFILE "\t(($lhs (*)(", join(" , ",@rhs) ," ))fcn)(",join(" , ",@params),");\n}\n\n";
    } else {
        print THUNKFILE "\treturn (($lhs (*)(", join(" , ",@rhs) ," ))fcn)(",join(" , ",@params),");\n}\n\n";
    }
    return $thunkname;
}

sub DumpError{
    print "ERROR: @_\n";
    print "found on line $. of input\n";
    die "Working string is '$str'.\n";
}

sub parsArgs
{
%options=@_; #qw(s 1 d 0 m 0 r 0 a 0 l 1 e path);
my @inputs;
#parse the input for options
while (@ARGV) {
	$_=shift @ARGV;
	if (/^-(\w+)/) { 
		my $opt=$1;
		#now look for special opts
		if (/-\w+=/) { #options that store there own string
		        #print "found string option '$opt' in '$_'.\n";
			$options{$opt}=$';
		} elsif (/-\w+-/) { #disable opt
			$options{$opt}=0;
		} elsif (/-\w+\+/) {
			$options{$opt}=1;
		} else { $options{$opt}=!$options{$opt};}
		print "option $opt is now $options{$opt}\n" if ($options{debug});
				
	} else {
		push (@inputs,$_);
	}
}
#put ARGV back
@ARGV=@inputs;
}