function xint=NaN_interp(x)
% xint=NaN_interp(x)
% Find the NaN values in x (not matrix), and replaces with the interpolated values
% output is xint, the same size as x.


if all(isnan(x))
    xint=x;

else

    flag=0;
    [m,n]=size(x);
    if n>1; x=x'; flag=1; end
%     x1=denan(x);
    x1 = x;x1(isnan(x))=[];
    y1=find(~isnan(x));
    y2=[1:length(x)]';
    
    if length(x1)<2
        xint=NaN.*x;
    else
    xint=interp1(y1,x1,y2);
    end
    %make sure x and xint are of same dimension
    if flag; xint=xint';end
end
