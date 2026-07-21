function newMooring=cutMooring(oldMooring, index);
%function newMooring=cutMooring(oldMooring, index);
%
%version 1.1: updated with dynamic field names
%version 1.2: a bit more flexible - support ADCPs

theFields=fieldnames(oldMooring);
for n=1:length(theFields)
    if iscell(oldMooring.(theFields{n})) && numel(oldMooring.(theFields{n}))>=max(index)
        newMooring.(theFields{n})=oldMooring.(theFields{n})(index);
    elseif isstr(oldMooring.(theFields{n})) || iscell(oldMooring.(theFields{n})) || ...
            isstruct(oldMooring.(theFields{n})) || length(oldMooring.(theFields{n}))<=1
        newMooring.(theFields{n})=oldMooring.(theFields{n});
    elseif numel(oldMooring.(theFields{n}))~=length(oldMooring.(theFields{n}))
        if length(oldMooring.(theFields{n}))==size(oldMooring.(theFields{n}),1)
            newMooring.(theFields{n})=oldMooring.(theFields{n})(index,:);
        elseif length(oldMooring.(theFields{n}))==size(oldMooring.(theFields{n}),2)
            newMooring.(theFields{n})=oldMooring.(theFields{n})(:,index);
        elseif length(oldMooring.(theFields{n}))==size(oldMooring.(theFields{n}),3)
            newMooring.(theFields{n})=oldMooring.(theFields{n})(:,:,index);
        else
            error('We don''t support multi-dimensional variables yet!!!');
        end
    else
        newMooring.(theFields{n})=oldMooring.(theFields{n})(index);
    end
end
