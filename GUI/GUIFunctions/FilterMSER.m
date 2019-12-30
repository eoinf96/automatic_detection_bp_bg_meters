function [ regions, regionStats ] = FilterMSER(regions,regionStats,  Filtering )


bbox = vertcat(regionStats.BoundingBox); 
Width = num2cell(bbox(:,3));
[regionStats.Width] = deal(Width{:});

Height = num2cell(bbox(:,4));
[regionStats.Height] = deal(Height{:});

aspectRatio = num2cell(bbox(:,4)./bbox(:,3));
[regionStats.aspectRatio] = deal(aspectRatio{:});

%% Filter by these values


filterIdx = [regionStats.Area] < Filtering.MinArea | [regionStats.Area] > Filtering.MaxArea;
filterIdx = filterIdx | [regionStats.Height] < Filtering.MinHeight | [regionStats.Height] > Filtering.MaxHeight;
filterIdx = filterIdx | [regionStats.Width] < Filtering.MinWidth | [regionStats.Width] > Filtering.MaxWidth;
filterIdx = filterIdx | [regionStats.aspectRatio] < Filtering.RatioMin | [regionStats.aspectRatio] > Filtering.RatioMax;

regions(filterIdx) = [];
regionStats(filterIdx) = [];

%%
%EDIT to skip SW stuff for debugging reasons
skip = 0;
if ~skip


    if ~isempty(regions)
    %Get StrokeWidth
    for j = 1:numel(regionStats)

        regionImage = regionStats(j).Image;
        regionImage = padarray(regionImage, [1 1], 0);

        swtMap = StrokeWidthTransform(1-regionImage);

        swtMap(isinf(swtMap)) = [];
        swtMap(:);

        varianceSW = var(swtMap);
        meanSW = mean(swtMap);

        width = regionStats(j).Width;
        height = regionStats(j).Height;

        diameter = sqrt(width^2+height^2);
        medianSW = median(swtMap);
        maxSW = max(swtMap);

        regionStats(j).swtMap = swtMap;


        if isempty(swtMap)
            regionStats(j).StrokeWidthVarianceRatio = inf;
            regionStats(j).StrokeWidthDiameterMedian = inf;
            regionStats(j).StrokeWidthLengthMax = inf;
        else
            regionStats(j).StrokeWidthVarianceRatio = varianceSW/meanSW;
            regionStats(j).StrokeWidthDiameterMedian = diameter/medianSW;
            regionStats(j).StrokeWidthLengthMax = length(swtMap)/maxSW;
        end

        strokewidthFilteridx(j) = regionStats(j).StrokeWidthVarianceRatio > Filtering.NormalisedVariance;

        strokewidthFilteridx(j) = strokewidthFilteridx(j) | regionStats(j).StrokeWidthDiameterMedian > Filtering.DiameterMedian;


    end


    regions(strokewidthFilteridx) = [];
    regionStats(strokewidthFilteridx) = [];

    end

end
%% For the regions still in get HOG
for label_value = 1:length(regionStats)


    Blob = regionStats(label_value);


    % Get blob in scene so can get HOG
    Scene = ones(56);
    ClassificationHeight = 52;


    if Blob.aspectRatio > 1
            %Portrait blob, need the height to be ClassificationHeight
            Height = Blob.Height;
            Factor = 52/Height;
            Width = Blob.Width;
            NewWidth_Blob = floor(Factor * Width);

            segment = 1-imresize(Blob.Image, [ClassificationHeight, NewWidth_Blob]);

            xstart = floor((56 - NewWidth_Blob)/2);
            ystart = floor((56 - ClassificationHeight)/2);

            Scene(ystart:ystart+ClassificationHeight-1, xstart:xstart+NewWidth_Blob-1) = segment;
        else
            %Landscape blob, need the width to be ClassificationHeight
            Height = Blob.Height;
            Width = Blob.Width;

            Factor = 52/Width;
            NewHeight_Blob = floor(Factor * Height);

            segment = 1-imresize(Blob.Image, [NewHeight_Blob, ClassificationHeight]);

            xstart = floor((56 - ClassificationHeight)/2);
            ystart = floor((56 - NewHeight_Blob)/2);

            Scene(ystart:ystart+NewHeight_Blob-1, xstart:xstart+ClassificationHeight-1) = segment;   

    end

    %%

    HOG = extractHOGFeatures(Scene,'CellSize', [8 8]);
    
    regionStats(label_value).HOG = HOG;
    
    regionStats(label_value).Scene = Scene; 
    

end






if Filtering.round == 2
    %% Add in!! Now need to remove blobs that are overlapping. -- These may be parts of a digit that havent been combined due to the combine conditions being too tight etc

    %Go through each pixel list of the remaining blobs and check if they are
    %combining with anything.

    OverlappingBlob = zeros(length(regions),1);

    for i = 1:length(regions)
        CurrentIDXList = regions.PixelList{i, 1};
        for j = 1:i-1
            NewIDXList = regions.PixelList{j, 1};

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
    regions(logical(OverlappingBlob)) = [];
    regionStats(logical(OverlappingBlob)) = [];

end
end

