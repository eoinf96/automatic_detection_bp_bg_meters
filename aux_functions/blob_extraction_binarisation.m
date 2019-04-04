%%
% File    : blob_extraction_binarisation.m
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
%   Blob detection via retinex filtering, adaptive histogram equalisation,
%   binarisation using Sauvola's adaptie binarisation and connected
%   components.
%
%
% LITERATURE
% ----------
%
% RETINEX USING BILATERAL FILTERS:
%   Elad M. Retinex by two bilateral filters. International Conference on
% Scale-Space Theories in Computer Vision. 2005;:217–229
%
% SAUVOLA ADAPTIVE BINARISATION:
%   Sauvola J, Pietikak M. Adaptive document image binarization. 
% Pattern Recognition. 2000;33:225–236.
%
% ________________________________________________________________________

%%

function [ blobs_binary_MSER, blobs_binary_stats ] = blob_extraction_binarisation( img, up)


    narginchk(2, inf);
    
    %% Set parameters
    sigmaSpatial = up.params.blob_extraction.Sauv.sigma_s;
    sigmaRange = up.params.blob_extraction.Sauv.sigma_r;
    gamma = up.params.blob_extraction.Sauv.gamma;
    
    alpha = up.params.blob_extraction.Sauv.alpha;
    k = up.params.blob_extraction.Sauv.k;
        
    
    %% Get HSV colour space of image
    hsv=rgb2hsv(img);
    value =hsv(:,:,3);
    hue = hsv(:,:,1);
    

    %% 
    %apply retinex filter
    
    %set sampling value to be the same as the variance in both the spatial 
    %and range direction as suggested in literature to speed up the algorithm
    
    samplingSpatial = sigmaSpatial;
    samplingRange = sigmaRange;
    
    v_retinex = retinexFilter(value, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange, gamma, 0);
    
    %apply adaptive histogram equalisation
    v_retinex_hist = adapthisteq(v_retinex);

    
    %apply sauvola binarisation
    window_size = floor(up.params.height*alpha);
    img_binarised = sauvola(v_retinex_hist, window_size,k);
    
    
    %%
    
    %Save the binarised regions as MSER regions - This is the same as
    %performing connected component analysis but allows for the blobs found
    %via MSER and CC to be handled in the same way (Maximally stable
    %regions of a binary image are the same as connected components of a
    %binary image)
    [blobs_binary_MSER, blobs_ConnComp] = detectMSERFeatures(img_binarised);
    
    
    %Get the region props
    blobs_binary_stats = regionprops(blobs_ConnComp,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');

    % Get Hue Stat
    for i= 1:length(blobs_binary_stats)
       blobs_binary_stats(i).Hue = hue([blobs_binary_stats(i).PixelIdxList ]);
    end
    
    

end