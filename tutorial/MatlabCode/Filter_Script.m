%First define the rule based values:

%Toal size of the image
TotalArea = HEIGHT*NewWidth;

%Filteiring is done twice this is round 1
Filtering.round = 1;


%Area
Filtering.MaxArea = TotalArea * 0.4; Filtering.MinArea = TotalArea*0.0001;

%Height
Filtering.MaxHeight = HEIGHT*0.7; Filtering.MinHeight = HEIGHT * 0.01;

%Width
Filtering.MaxWidth = NewWidth * 0.5; Filtering.MinWidth = NewWidth * 0.001;

%Ratio
Filtering.RatioMin = 0.1; Filtering.RatioMax = 8;

%Stroke Width
Filtering.NormalisedVariance = 5; Filtering.DiameterMedian = 6;

%Filter the regions
[regions_filtered, regionstats_filteres] = Filter(regions_combined, regionstats_combined, Filtering);

%Display the results:
figure
imshow(image_retinex)
hold on
plot(regions_combined, 'showPixelList', true,'showEllipses',false)
hold off
title('Combined Regions')

figure
imshow(image_retinex)
hold on
plot(regions_filtered, 'showPixelList', true,'showEllipses',false)
hold off
title('Filtered Regions')
