%%
% File    : get_filtering_values.m
% Author  : Eoin Finnegan
% Created : April 3, 2019
% ________________________________________________________________________
%
%
% You may contact the author by e-mail (eoin.finnegan@eng.ox.ac.uk)
%
% ________________________________________________________________________
%
% DESCRIPTON
% ----------
%   Set rule-based filtering values. The filtering values are:
%       MaxArea
%       MinArea
%       MaxHeight
%       MinHeight
%       MaxWidth
%       MinWidth
%       RatioMin
%       RatioMax
%       NormalisedVariance
%       DiameterMedian
%   The definitions of these can be found in:
% Automated method for detecting and reading seven-segment digits from
% images of blood glucose meters and blood pressure monitors - E.Finnegan
%
%The function requires 2 inputs: the device type (Only BG and BP are
%supported) and the round of filtering. In round 1 the filtering values are
%set to remove non-segments. In round 2 the filtering values are set to
%remove non-digits
%
%
% ________________________________________________________________________

%%

function [ filtering_values ] = get_filtering_values( up, round)

narginchk(2, inf);

if round == 1
    filtering_values = round1(up);
elseif round == 2
    filtering_values = round2(up);
else 
    warning('round variable is unknown - only 1 and 2 supported')
end

%Include the round of filtering into the struct
filtering_values.round = round;
end


%%
function filtering_values = round1( up)

device = up.device_type;
image_height = up.params.height;
image_width = up.params.width;


if strcmp(device,'BP')
        %%%%%% Blob Filtering Values
        TotalArea = image_height*image_width;
        filtering_values.MaxArea = TotalArea * 0.4;
        filtering_values.MinArea = TotalArea*0.0001;
        filtering_values.MaxHeight = image_height*0.7;
        filtering_values.MinHeight = image_height * 0.01;
        filtering_values.MaxWidth = image_width * 0.5;
        filtering_values.MinWidth = image_width * 0.001;
        filtering_values.RatioMin = 0.1;
        filtering_values.RatioMax = 8;
    
        
        % Add stroke width variance filtering?
        filtering_values.NormalisedVariance = 5;
        filtering_values.DiameterMedian = 6;
        
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BG Meter
    
elseif strcmp(device,'BG')
        %%%%%% Blob Filtering Values
        TotalArea =  image_height*image_width;
        filtering_values.MaxArea = TotalArea * 0.4;
%         Filtering.MinArea = TotalArea*0.0005;
        filtering_values.MinArea = TotalArea*0.0001;
        filtering_values.MaxHeight = image_height*0.4;
        filtering_values.MinHeight = image_height * 0.01;
        filtering_values.MaxWidth = image_width * 0.4;
        filtering_values.MinWidth = image_width * 0.01;
        filtering_values.RatioMin = 0.15;
        filtering_values.RatioMax = 8;
        
        filtering_values.NormalisedVariance = 5;
        filtering_values.DiameterMedian = 15;
        
else
    warning('device variable unknown - only BP and BG supported')
    
end

end


function Filtering = round2( up)
%Round 2 - tighter restrictions

device = up.device_type;
image_height = up.params.height;
image_width = up.params.width;


if strcmp(device,'BP')
        %%%%%% Blob Filtering Values
        TotalArea = image_height*image_width;
        Filtering.MaxArea = TotalArea * 0.3;
        Filtering.MinArea = TotalArea*0.001;
        Filtering.MaxHeight = image_height*0.5;
        Filtering.MinHeight = image_height * 0.05;
        Filtering.MaxWidth = image_width * 0.5;
        Filtering.MinWidth = image_width * 0.01;
        Filtering.RatioMin = 0.5;
        Filtering.RatioMax = 5;
    
        
        % Add stroke width variance filtering?
        Filtering.NormalisedVariance = 10;
        Filtering.DiameterMedian = 15;
        
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BG Meter
    
elseif strcmp(device,'BG')
        %%%%%% Blob Filtering Values
        TotalArea =  image_height*image_width;
        Filtering.MaxArea = TotalArea * 0.3;
        Filtering.MinArea = TotalArea*0.001;
        Filtering.MaxHeight = image_height*0.5;
        Filtering.MinHeight = image_height * 0.1;
        Filtering.MaxWidth = image_width * 0.3;
        Filtering.MinWidth = image_width * 0.01;
        Filtering.RatioMin = 1;
        Filtering.RatioMax = 8;
        
        Filtering.NormalisedVariance = 4;
        Filtering.DiameterMedian = 15;
        
        
else
    warning('device variable unknown - only BP and BG supported')
end

end