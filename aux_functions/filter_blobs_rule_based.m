%%
% File    : filter_blobs_rule_based.m
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
%   Perform rule-based blob filtering. Blobs are filtered based on the
%   properties and values defined in get_filtering_values.m
%
%   Function performs Stroke With Transform on each blob individually
%
%   Saves a HOG 8x8 feature vector for those remaining blobs
%
% LITERATURE
% ----------
%
%   STROKE WIDTH TRANSFORM
% Li Y, Lu H. Scene text detection via stroke width. Pattern Recognition 
% (ICPR), 2012 21st International Conference on. 2012;:681–684
%
%   
% ________________________________________________________________________

%%
function [ blobs, blobs_stats ] = filter_blobs_rule_based(blobs,blobs_stats,  up )

filtering_values = up.params.filtering;

narginchk(3, inf);
    
%% First define some valyes for each blob and add to blob_stats
bbox = vertcat(blobs_stats.BoundingBox); 
Width = num2cell(bbox(:,3));
[blobs_stats.Width] = deal(Width{:});

Height = num2cell(bbox(:,4));
[blobs_stats.Height] = deal(Height{:});

aspectRatio = num2cell(bbox(:,4)./bbox(:,3));
[blobs_stats.aspectRatio] = deal(aspectRatio{:});

%% Filter by these values


filterIdx = [blobs_stats.Area] < filtering_values.MinArea | [blobs_stats.Area] > filtering_values.MaxArea;
filterIdx = filterIdx | [blobs_stats.Height] < filtering_values.MinHeight | [blobs_stats.Height] > filtering_values.MaxHeight;
filterIdx = filterIdx | [blobs_stats.Width] < filtering_values.MinWidth | [blobs_stats.Width] > filtering_values.MaxWidth;
filterIdx = filterIdx | [blobs_stats.aspectRatio] < filtering_values.RatioMin | [blobs_stats.aspectRatio] > filtering_values.RatioMax;

blobs(filterIdx) = [];
blobs_stats(filterIdx) = [];

%% If there are any blobs left now perform stroke width transform on the image and filter.

if ~isempty(blobs)

for j = 1:numel(blobs_stats)

    regionImage = blobs_stats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);
    
    
    %Get StrokeWidth of each blob
    swtMap = stroke_width_transform(1-regionImage, up.params.height);

    swtMap(isinf(swtMap)) = [];
    swtMap(:);

    varianceSW = var(swtMap);
    meanSW = mean(swtMap);

    width = blobs_stats(j).Width;
    height = blobs_stats(j).Height;

    diameter = sqrt(width^2+height^2);
    medianSW = median(swtMap);
    maxSW = max(swtMap);

    blobs_stats(j).swtMap = swtMap;


    if isempty(swtMap)
        blobs_stats(j).StrokeWidthVarianceRatio = inf;
        blobs_stats(j).StrokeWidthDiameterMedian = inf;
        blobs_stats(j).StrokeWidthLengthMax = inf;
    else
        blobs_stats(j).StrokeWidthVarianceRatio = varianceSW/meanSW;
        blobs_stats(j).StrokeWidthDiameterMedian = diameter/medianSW;
        blobs_stats(j).StrokeWidthLengthMax = length(swtMap)/maxSW;
    end

    
    %Now filter those blobs whose SW values are outside of the required
    %range
    strokewidthFilteridx(j) = blobs_stats(j).StrokeWidthVarianceRatio > filtering_values.NormalisedVariance;

    strokewidthFilteridx(j) = strokewidthFilteridx(j) | blobs_stats(j).StrokeWidthDiameterMedian > filtering_values.DiameterMedian;


end

%Remove filtered blobs
blobs(strokewidthFilteridx) = [];
blobs_stats(strokewidthFilteridx) = [];

end

%% For the regions still in get HOG feature set
for label_value = 1:length(blobs_stats)
    %Loop through the blobs - frame them in a 56 x 56 pixel array and
    %extract the 8x8 HOG feature vector
    
    %A scene is the 56x56 array that the blob is centred in

    individual_blob = blobs_stats(label_value);

    %initialise scene
    scene = ones(56);
    
    %This is how long (if portrait) or wide (if landscape) we want the blob to be within the scene
    ClassificationHeight = 52;


    if individual_blob.aspectRatio > 1
            %Portrait blob, need the height to be ClassificationHeight
            factor = 52/individual_blob.Height;
            NewWidth_Blob = floor(factor * individual_blob.Width);
            
            %resize the blob so that the height is 52 pixels
            segment = 1-imresize(individual_blob.Image, [ClassificationHeight, NewWidth_Blob]);

            xstart = floor((56 - NewWidth_Blob)/2);
            ystart = floor((56 - ClassificationHeight)/2);
            
            %Insert the blob into the scene
            scene(ystart:ystart+ClassificationHeight-1, xstart:xstart+NewWidth_Blob-1) = segment;
        else
            %Landscape blob, need the width to be ClassificationHeight

            factor = 52/individual_blob.Width;
            NewHeight_Blob = floor(factor * individual_blob.Height);

            %resize the blob so that the width is 52 pixels
            segment = 1-imresize(individual_blob.Image, [NewHeight_Blob, ClassificationHeight]);

            xstart = floor((56 - ClassificationHeight)/2);
            ystart = floor((56 - NewHeight_Blob)/2);

            scene(ystart:ystart+NewHeight_Blob-1, xstart:xstart+ClassificationHeight-1) = segment;   

    end

    %%
    
    %Now extract the HOG feature vector for the scene and save in the
    %blob_stats
    
    HOG = extractHOGFeatures(scene,'CellSize', [8 8]);
    
    blobs_stats(label_value).HOG = HOG;
    
    blobs_stats(label_value).Scene = scene; 
    

end






if filtering_values.round == 2
    %% Now need to remove blobs that are overlapping. -- These may be parts of a digit that havent been combined due to the combine conditions being too tight etc

    %Go through each pixel list of the remaining blobs and check if they are
    %combining with anything.

    OverlappingBlob = zeros(length(blobs),1);

    for i = 1:length(blobs)
        CurrentIDXList = blobs.PixelList{i, 1};
        for j = 1:i-1
            NewIDXList = blobs.PixelList{j, 1};

            Result = ismember(CurrentIDXList,NewIDXList,'rows');

            if any(Result)   %Then Label the blob that has the smallest area for deleting

                if size(CurrentIDXList,1) >= size(NewIDXList,1)
                     OverlappingBlob(i) = 1;
                else
                    OverlappingBlob(j) = 1;
                end


            end
        end

    end


    %Need to remove blobs that are overlapping
    blobs(logical(OverlappingBlob)) = [];
    blobs_stats(logical(OverlappingBlob)) = [];

end
end

