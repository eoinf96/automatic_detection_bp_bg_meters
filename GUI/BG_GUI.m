function [Reading  ] = BG_GUI( File, sigma_s_b, sigma_r_b, gamma_b, T, Delta, sigma_s_m, sigma_r_m, gamma_m, k, alpha , f_ma, f_mi, T_H, T_SW, T_D, ax)
addpath(genpath('/Volumes/E.Finnegan/Engineering/Year 4/4YP/SummerMatlab/GUI/GUIFunctions'));

wait = waitbar(0,'Getting blobs');


IMG = imread(File);
str = 'BG';


%%%%%%%%%%%%%%%% rotate
info = imfinfo(File);
if isfield(info,'Orientation')
   orient = info(1).Orientation;
   switch orient
     case 1
        %normal, leave the data alone
     case 2
        IMG = IMG(:,end:-1:1,:);         %right to left
     case 3
        IMG = IMG(end:-1:1,end:-1:1,:);  %180 degree rotation
     case 4
        IMG = IMG(end:-1:1,:,:);         %bottom to top
     case 5
        IMG = permute(IMG, [2 1 3]);     %counterclockwise and upside down
     case 6
        IMG = rot90(IMG,3);              %undo 90 degree by rotating 270
     case 7
        IMG = rot90(IMG(end:-1:1,:,:));  %undo counterclockwise and left/right
     case 8
        IMG = rot90(IMG);                %undo 270 rotation by rotating 90
     otherwise
        warning(sprintf('unknown orientation %g ignored\n', orient));
   end
 end
%%%%%%%%%%%%%%%% rotate

global HEIGHT 
HEIGHT = 500;
Factor = HEIGHT / size(IMG,1);
global NewWidth
% NewWidth = size(IMG_Original,2);
NewWidth = ceil(Factor * size(IMG,2));
IMG= imresize(IMG, [HEIGHT, NewWidth]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Binarisation

%Get Retinex
[ MSERRegions_Binary, BinarisedRegionStats ] = getMSERBinaryAllParams(IMG, sigma_s_b, sigma_r_b, gamma_b, k, alpha);


% figure, imshow(IMG)
% hold on
% plot(MSERRegions_Binary,'showPixelList',true,'showEllipses',false);
%% MSER

[ MSERRegions, MSERRegionsStats ] = getMSERRegionsAllParams(IMG, sigma_s_m, sigma_r_m, gamma_m, T, Delta);

%% combine regions of MSER and Sauvola
TotalRegions = MSERRegions;
TotalRegions.PixelList = [MSERRegions_Binary.PixelList; MSERRegions.PixelList];


TotalStats = [BinarisedRegionStats; MSERRegionsStats];

waitbar(0.2,wait, 'Filtering Blobs')


%Filter Binarised
Filtering = Filtering_Values(str, 1);
[ TotalRegions, TotalStats ] = FilterMSER(TotalRegions, TotalStats,  Filtering );
%% Now classify

load('OneTouch_Weights_All')
w_blob = w;
[ TotalRegions, TotalStats] = ClassifyNoiseAll(TotalRegions, TotalStats, w_blob );

waitbar(0.4,wait, 'Combining blobs')


%% Combine all
[ ~,~, CombinedLabels,LabelsStats  ] = CombineBlobsEllipseAllParams(TotalRegions,TotalStats, f_ma, f_mi, T_H, T_SW, T_D, 0);

%% Final Filter
if ~isempty(LabelsStats)
Filtering = Filtering_Values(str, 2);
[ CombinedLabels, LabelsStats ] = FilterMSER(CombinedLabels, LabelsStats,  Filtering );
end

%% Add classification
waitbar(0.6,wait, 'Classifying blobs')


axes(ax)

imshow(IMG)
hold on
plot(CombinedLabels,'showPixelList',true,'showEllipses',false)
LabelsStats = Classify(CombinedLabels, LabelsStats);

hold off


waitbar(0.8,wait, 'Combining blobs')

%%

fminor = 2;% 2;
fminor_one = 10;% 10;
fmajor = 0.4;% 0.4;


if isempty(LabelsStats)
    Reading = [];
else
    Reading = CombineDigits( LabelsStats,fminor, fminor_one, fmajor,0); 
end


waitbar(1,wait,  'Done')

close(wait)



end
