function [LabelsStats] = Classify( Labels, LabelsStats )
    Classes = [0,1,2,3,4,5,6,7,8,9];
    load('Weights.mat')
    for i = 1:length(Labels)
      
        Blob_Vect = LabelsStats(i).HOG;
        Guess = Blob_Vect*W;
        NormGuess = softmax(Guess);
        
        [Probability,Prediction_loc] = max(NormGuess);
        Prediction = Classes(Prediction_loc);
        
        
        %If probably a one then stretch the image and retest - could be a 7
        %Stretch by how much? -- add 5.
        stretch = 10;
        if Prediction == 1
            Scene = LabelsStats(i).Scene;
                        
            
            Scene = imresize(Scene, [56 56+2*stretch]);
            Scene(:,1:stretch) = [];
            Scene(:,end-(stretch-1):end) = [];
            
    
            
            %%%%%
            angle = 35;
            T = @(I) imrotate(I,angle,'bilinear','crop');
            %// Apply transformation
            Transformed_Scene = T(Scene);
            mask = T(ones(size(Scene)))==1;
            NewScene = Scene;
            NewScene(mask) = Transformed_Scene(mask);
            %%%%%%
        
            HOG = extractHOGFeatures(NewScene,'CellSize', [8 8]);
            
            Guess = HOG*W;
            NormGuess = softmax(Guess);
        
            [Probability,Prediction_loc] = max(NormGuess);
            Prediction_new = Classes(Prediction_loc);
            
            if Prediction_new == 7
                Prediction = Prediction_new;
            end
            
        end
        
        if Probability > 0.3
            rectangle('Position',LabelsStats(i).BoundingBox,'LineWidth',2,'LineStyle','--', 'EdgeColor', 'g')
            text(LabelsStats(i).BoundingBox(1),LabelsStats(i).BoundingBox(2)-10, num2str(Prediction), 'Color', 'g', 'FontSize', 25)
            LabelsStats(i).Value = Prediction;
            LabelsStats(i).Prob = Probability;
        end
              
        
    end
end

function Blob =  getBlob(Labels, label)
    Labelled_Blob = Labels ==label;
    Blob.maxrow = find(logical(sum(Labelled_Blob,2)),1,'last');
    Blob.minrow = find(logical(sum(Labelled_Blob,2)),1,'first');
    Blob.maxcol = find(logical(sum(Labelled_Blob)),1,'last');
    Blob.mincol = find(logical(sum(Labelled_Blob)),1,'first');
    
    Blob.array = Labels(Blob.minrow:Blob.maxrow,Blob.mincol:Blob.maxcol);
    Blob.array = double(Blob.array == label);
    
    Blob.height = Blob.maxrow - Blob.minrow + 1;
    Blob.width = Blob.maxcol - Blob.mincol + 1;
    
    Blob.ratio = Blob.height/Blob.width;
    
    Blob.CoveredArea = Blob.height * Blob.width;
    Blob.ActualArea = sum(sum(Blob.array));
end

function out = softmax(x)
    out = exp(x)/(sum(exp(x)));
end