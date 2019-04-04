%%
% File    : filter_blobs_feature_vector.m
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
%   Perform classifier based blob filtering
% ________________________________________________________________________

%%

function [blobs, blobs_stats] = filter_blobs_feature_vector(blobs, blobs_stats, up )
narginchk(3, inf);

%% Set parameters
w = up.params.blob_filtering_weights;
image_height = up.params.height;
image_width = up.params.width;

%%

%Loop through each blob, create the feature vector and classify whether
%blob or not.
   for label_value = 1:length(blobs_stats)
       
    Blob = blobs_stats(label_value);
       
    feature_vector = [
                Blob.Height/image_height;
                Blob.Width/image_width;
                Blob.aspectRatio; 
                Blob.Extent; 
                Blob.Solidity;
                Blob.EulerNumber;
                Blob.StrokeWidthVarianceRatio;
                Blob.StrokeWidthDiameterMedian;
                Blob.StrokeWidthLengthMax;
                Blob.HOG';
                1
                ];
      
%               imshow(Blob.Scene)
      
    Prediction = sigmoid(w'*feature_vector);
    if Prediction <0.1 
        %Prediction threshold is fairly low so that we are more likely to
        %accept noise than reject a segment (noise can be filtered out
        %later but segments cannot be recovered).
        
        %Noise
         classifyFilteridx(label_value) = 1;
    else
        classifyFilteridx(label_value) = 0;
    end
    
   end

   
%Remove blobs that have been classified as noise.
blobs.PixelList(logical(classifyFilteridx)) = [];
blobs_stats(logical(classifyFilteridx)) = [];
end

function y = sigmoid(x)
% 
%         ______1________
%     y =        -x
%          1 + e^
% 
% Sigmod function
y = 1/(1 + exp(-x));


end
