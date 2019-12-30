function [ Filtering ] = Filtering_Values( str, round)
%BGMETERFILTERING Summary of this function goes here
%   Detailed explanation goes here

if round == 1
    Filtering = round1(str);
elseif round == 2
    Filtering = round2(str);
end

Filtering.round = round;


end

function Filtering = round1( str)
global HEIGHT
global NewWidth
if strcmp(str,'BP')
        %%%%%% Blob Filtering Values
        TotalArea = HEIGHT*NewWidth;
        Filtering.MaxArea = TotalArea * 0.4;
        Filtering.MinArea = TotalArea*0.0001;
        Filtering.MaxHeight = HEIGHT*0.7;
        Filtering.MinHeight = HEIGHT * 0.01;
        Filtering.MaxWidth = NewWidth * 0.5;
        Filtering.MinWidth = NewWidth * 0.001;
        Filtering.RatioMin = 0.1;
        Filtering.RatioMax = 8;
    
        
        % Add stroke width variance filtering?
        Filtering.NormalisedVariance = 5;
        Filtering.DiameterMedian = 6;
        
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BG Meter
    
else
        %%%%%% Blob Filtering Values
        TotalArea =  HEIGHT*NewWidth;
        Filtering.MaxArea = TotalArea * 0.4;
%         Filtering.MinArea = TotalArea*0.0005;
        Filtering.MinArea = TotalArea*0.0001;
        Filtering.MaxHeight = HEIGHT*0.4;
        Filtering.MinHeight = HEIGHT * 0.01;
        Filtering.MaxWidth = NewWidth * 0.4;
        Filtering.MinWidth = NewWidth * 0.01;
        Filtering.RatioMin = 0.15;
        Filtering.RatioMax = 8;
        
        Filtering.NormalisedVariance = 5;
        Filtering.DiameterMedian = 15;
end

end


function Filtering = round2( str)
%Round 2 - tighter restrictions
global HEIGHT
global NewWidth
if strcmp(str,'BP')
        %%%%%% Blob Filtering Values
        TotalArea = HEIGHT*NewWidth;
        Filtering.MaxArea = TotalArea * 0.3;
        Filtering.MinArea = TotalArea*0.001;
        Filtering.MaxHeight = HEIGHT*0.5;
        Filtering.MinHeight = HEIGHT * 0.05;
        Filtering.MaxWidth = NewWidth * 0.5;
        Filtering.MinWidth = NewWidth * 0.01;
        Filtering.RatioMin = 0.5;
        Filtering.RatioMax = 5;
    
        
        % Add stroke width variance filtering?
        Filtering.NormalisedVariance = 10;
        Filtering.DiameterMedian = 15;
        
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BG Meter
    
else
        %%%%%% Blob Filtering Values
        TotalArea =  HEIGHT*NewWidth;
        Filtering.MaxArea = TotalArea * 0.3;
        Filtering.MinArea = TotalArea*0.001;
        Filtering.MaxHeight = HEIGHT*0.5;
        Filtering.MinHeight = HEIGHT * 0.1;
        Filtering.MaxWidth = NewWidth * 0.3;
        Filtering.MinWidth = NewWidth * 0.01;
        Filtering.RatioMin = 1;
        Filtering.RatioMax = 8;
        
        Filtering.NormalisedVariance = 4;
        Filtering.DiameterMedian = 15;
end

end