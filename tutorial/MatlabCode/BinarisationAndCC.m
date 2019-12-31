%Define params
alpha = 0.059; k = 0.34;

%Get binary CC
image_binarised = sauvola(image_ahe, floor(HEIGHT*alpha),k);

%Display the results of the binarisation
multi = cat(3, image_ahe, image_binarised);
figure, montage(multi)
title('Result of applying Sauvola binarisation to output of AHE')

%So that the regions detected by MSER and Binarisation and handled in the same way 
[regions_binary, ConnComp_binary] = detectMSERFeatures(image_binarised); 

%Use regioprops to get features of each region -- to be used later
regionstats_binary = regionprops(ConnComp_binary,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');

% Get Hue Stat
for i= 1:length(regionstats_binary)
   regionstats_binary(i).Hue = hue([regionstats_binary(i).PixelIdxList ]);
end

figure
imshow(image_retinex)
hold on
plot(regions_binary, 'showPixelList', true,'showEllipses',false)
hold off
title('Regions located by CC of Binarised Image')
