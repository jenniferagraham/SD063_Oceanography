function newstruct=cutstruct(oldstruct, index)
%CUTSTRUCT extract a subset of indeces from a structure
%
%   newstruct = CUTSTRUCT(oldstruct, index)
%
%   version 0.1 - Unknown date - Povl Abrahamsen - originally "cutmooring"
%   version 0.2 - Povl Abrahamsen - updated with dynamic field names
%   version 0.3 - Povl Abrahamsen - a bit more flexible - support ADCPs

theFields=fieldnames(oldstruct);
for n=1:length(theFields)
    if iscell(oldstruct.(theFields{n})) && numel(oldstruct.(theFields{n}))>=max(index)
        newstruct.(theFields{n})=oldstruct.(theFields{n})(index);
    elseif isstr(oldstruct.(theFields{n})) || iscell(oldstruct.(theFields{n})) || ...
            isstruct(oldstruct.(theFields{n})) || length(oldstruct.(theFields{n}))<=1
        newstruct.(theFields{n})=oldstruct.(theFields{n});
    elseif numel(oldstruct.(theFields{n}))~=length(oldstruct.(theFields{n}))
        if length(oldstruct.(theFields{n}))==size(oldstruct.(theFields{n}),1)
            newstruct.(theFields{n})=oldstruct.(theFields{n})(index,:);
        elseif length(oldstruct.(theFields{n}))==size(oldstruct.(theFields{n}),2)
            newstruct.(theFields{n})=oldstruct.(theFields{n})(:,index);
        elseif length(oldstruct.(theFields{n}))==size(oldstruct.(theFields{n}),3)
            newstruct.(theFields{n})=oldstruct.(theFields{n})(:,:,index);
        else
            error('We don''t support multi-dimensional variables yet!!!');
        end
    else
        newstruct.(theFields{n})=oldstruct.(theFields{n})(index);
    end
end
