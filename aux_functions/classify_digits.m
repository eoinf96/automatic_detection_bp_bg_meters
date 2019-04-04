%%
% File    : classify_digits.m
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
%   Classify digits found in each image by their value. Must have a
%   weight vector saved in the universal parameters struct
%
%
%   
% ________________________________________________________________________
%%


function [blobs_stats] = classify_digits( blobs, blobs_stats, up )

narginchk(3, inf);

    %%  Define parameters
    plot_flag = up.plot_flag;
    W = up.params.digit_classification_weights;

    %%

    Classes = [0,1,2,3,4,5,6,7,8,9];
    
    for i = 1:length(blobs)
      
        Blob_Vect = blobs_stats(i).HOG;
        Guess = Blob_Vect*W;
        NormGuess = softmax(Guess);
        
        [Probability,Prediction_loc] = max(NormGuess);
        Prediction = Classes(Prediction_loc);
        
        
        %If probably a one then stretch the image and retest - could be a 7
        %Stretch by how much? -- add 5.
        
        %If the prediction is a one then check by applying an enlargment
        %and rotation to the image and checking if the prediction changes
        %to a 7
        stretch = 10;
        angle = 35;
        if Prediction == 1
            Scene = blobs_stats(i).Scene;
                        
            %%%%% Stretch the scene
            Scene = imresize(Scene, [56 56+2*stretch]);
            Scene(:,1:stretch) = [];
            Scene(:,end-(stretch-1):end) = [];
            %%%%%
    
            
            %%%%% Rotate the scene
            T = @(I) imrotate(I,angle,'bilinear','crop');
            %// Apply transformation
            Transformed_Scene = T(Scene);
            mask = T(ones(size(Scene)))==1;
            NewScene = Scene;
            NewScene(mask) = Transformed_Scene(mask);
            %%%%%%
            
            
            %%%%% Take HOG feature vector of the scene
            HOG = extractHOGFeatures(NewScene,'CellSize', [8 8]);
            %%%%%
            
            %%%%% Now check the prediction
            Guess = HOG*W;
            NormGuess = softmax(Guess);
        
            [Probability,Prediction_loc] = max(NormGuess);
            Prediction_new = Classes(Prediction_loc);
            
            if Prediction_new == 7
                Prediction = Prediction_new;
            end
            
        end
        
        
        %Only accept if the probability of a correct prediction is greater
        %than 30%
        if Probability > 0.3
            if plot_flag
                rectangle('Position',blobs_stats(i).BoundingBox,'LineWidth',2,'LineStyle','--', 'EdgeColor', 'g')
                text(blobs_stats(i).BoundingBox(1),blobs_stats(i).BoundingBox(2)-10, num2str(Prediction), 'Color', 'g', 'FontSize', 25)
            end
                
            blobs_stats(i).Value = Prediction;
            blobs_stats(i).Prob = Probability;
        end
              
        
    end
end

%% Softmax function

function out = softmax(x)
    out = exp(x)/(sum(exp(x)));
end