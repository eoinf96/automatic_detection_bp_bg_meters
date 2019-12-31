%Define params
Delta = 0.02; T = 0.25;

%Detect MSER regions
[regions_MSER, mserConnComp] = detectMSERFeatures(image_retinex, 'ThresholdDelta', Delta*100, 'MaxAreaVariation', T);

%Use regioprops to get features of each region -- to be used later 
regionstats_MSER = regionprops(mserConnComp,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');

% Get Hue Stat
for i= 1:length(regions_MSER)
   regionstats_MSER(i).Hue = hue([regionstats_MSER(i).PixelIdxList ]);
end

figure
imshow(image_retinex)
hold on
plot(regions_MSER, 'showPixelList', true,'showEllipses',false)
hold off
title('Regions located by MSER')