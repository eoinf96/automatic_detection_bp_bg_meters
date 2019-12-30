function [MSER, regionStats] = ClassifyNoiseAll(MSER, regionStats, w )
global HEIGHT
global NewWidth
%Go through each Label
   for label_value = 1:length(regionStats)
       
    Blob = regionStats(label_value);
       
    FeatureVector = [
                Blob.Height/HEIGHT;
                Blob.Width/NewWidth;
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
      
        Prediction = sigmoid(w'*FeatureVector);
    if Prediction <0.1
        %Noise
         classifyFilteridx(label_value) = 1;
    else
        classifyFilteridx(label_value) = 0;
    end
    
   end
   
MSER.PixelList(logical(classifyFilteridx)) = [];
% MSER.PixelIdxList(logical(classifyFilteridx)) = [];
regionStats(logical(classifyFilteridx)) = [];
end

function y = sigmoid(x)
% Sigmod function
% Written by Mo Chen (sth4nth@gmail.com).
y = exp(-log1pexp(-x));

end

function y = log1pexp(x)
% Accurately compute y = log(1+exp(x))
% reference: Accurately Computing log(1-exp(|a|)) Martin Machler
seed = 33.3;
y = x;
idx = x<seed;
y(idx) = log1p(exp(x(idx)));

end
