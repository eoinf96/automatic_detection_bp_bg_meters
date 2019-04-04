%%
% File    : blob_extraction_MSER.m
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
%   Blob detection via retinex filtering, and Maximally Stable Extremal
%   Regions (MSER)
%
%
% LITERATURE
% ----------
%
% RETINEX USING BILATERAL FILTERS
%   Elad M. Retinex by two bilateral filters. International Conference on
% Scale-Space Theories in Computer Vision. 2005;:217–229
%
% MSER:
% Yin XC, Yin X, Huang K, et al. Robust text detection in natural scene 
%   images. IEEE transactions on pattern analysis and machine intelligence.
%  2014;36(5):970–983.
% ________________________________________________________________________

%%

function [ blobs_MSER, blobs_stats ] = blob_extraction_MSER( img,up)

    narginchk(2, inf);

    %% Set parameters
    sigmaSpatial = up.params.blob_extraction.MSER.sigma_s;
    sigmaRange = up.params.blob_extraction.MSER.sigma_r;
    gamma = up.params.blob_extraction.MSER.gamma;
    
    T = up.params.blob_extraction.MSER.T;
    Delta = up.params.blob_extraction.MSER.Delta;
    
    
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
    
    
    %Extract Maximally Stable Extremal Regions
    [blobs_MSER, blobs_ConnComp] = detectMSERFeatures(v_retinex, 'ThresholdDelta', Delta*100, 'MaxAreaVariation', T);
    
    %%
    %Get RegionStats
    
    blobs_stats = regionprops(blobs_ConnComp,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');
    
    
    % Only take one region from all overlapping regions
    %Go through each region and take the union of all regions that
    %intersect?  

    Keep = [];

    for N =1:length(blobs_stats)
       BB =  [blobs_stats(N).BoundingBox];
       BBall = [blobs_stats(:).BoundingBox];
       BBall = reshape(BBall, [4, length(BBall)/4]);
       Overlap =find(bboxOverlapRatio(BB, BBall') >0.8);

       %find the overlap with the largest area and delete all others
       [~, I] = max([blobs_stats(Overlap).Area]);

       Keep = [Keep; Overlap(I)];

    end
    Keep = unique(Keep);
    blobs_MSER = blobs_MSER(Keep);
    blobs_stats = blobs_stats(Keep);
    
    
    %% Get Hue Stat
    for i= 1:length(blobs_MSER)
       blobs_stats(i).Hue = hue([blobs_stats(i).PixelIdxList ]);
    end
    
end