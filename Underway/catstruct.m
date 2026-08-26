function c=catstruct(a,b,dim)
%CATSTRUCT concatenate two structures along a specified dimension
%
%   newstruct = CATSTRUCT(oldstruct1, oldstruct2, dimension)
%
%   If you do not specify the dimension, we will try to guess it.
%
%   version 1.0 - 20220818 - Povl Abrahamsen, SD020 - initial version?
%   version 1.1 - 20240805 - Povl Abrahamsen, SD041 - fix the scenario
%       where a field is missing in structure b - substitute with NaNs
%   version 1.2 - 20241213 - Povl Abrahamsen, post-SD033 - convert any
%       cellstr/char mismatches to char arrays for storage efficiency

thefields=fieldnames(a);
if nargin<3
if exist('iscolumn','builtin')
    if isrow(a.(thefields{1}))
        dim=2;
    elseif iscolumn(a.(thefields{1}))
        dim=1;
    end
else
    asize=size(a.(thefields{1}));
    dim=isvector(a.(thefields{1}));
    if ~dim
        dim=2;
    end
end
end
for n=1:length(thefields)
    if isfield(b,thefields{n})
        if ischar(a.(thefields{n})) && iscellstr(b.(thefields{n}))
            c.(thefields{n})=cat(dim,a.(thefields{n}),cell2mat(b.(thefields{n})));
        else
            c.(thefields{n})=cat(dim,a.(thefields{n}),b.(thefields{n}));
        end
    else
        c.(thefields{n})=cat(dim,a.(thefields{n}),nan(size(b.(thefields{1}))));
    end
end
