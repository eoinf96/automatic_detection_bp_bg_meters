function [ Reading] = BP_GUI( File, sigma_s_b, sigma_r_b, gamma_b, T, Delta, sigma_s_m, sigma_r_m, gamma_m, k, alpha , f_ma, f_mi, T_H, T_SW, T_D, ax)
% addpath(genpath('D:\Engineering\Year 4\4YP\Matlab\PreprocessFunctions2'));
addpath(genpath('/Volumes/E.Finnegan/Engineering/Year 4/4YP/SummerMatlab/GUI/GUIFunctions'));

wait = waitbar(0,'Getting blobs');

IMG = imread(File);
Device = 'BP';

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
%% MSER

[ MSERRegions, MSERRegionsStats ] = getMSERRegionsAllParams(IMG, sigma_s_m, sigma_r_m, gamma_m, T, Delta);



%% combine regions of MSER and Sauvola
TotalRegions = MSERRegions;
TotalRegions.PixelList = [MSERRegions_Binary.PixelList; MSERRegions.PixelList];


TotalStats = [BinarisedRegionStats; MSERRegionsStats];

waitbar(0.2,wait, 'Filtering Blobs')

%Filter Binarised
Filtering = Filtering_Values(Device, 1);
[ TotalRegions, TotalStats ] = FilterMSER(TotalRegions, TotalStats,  Filtering );
%% Now classify

load('MicroLifeBPHomeNoiseWeights_MSER')
w_blob = w;
[ TotalRegions, TotalStats] = ClassifyNoiseAll(TotalRegions, TotalStats, w_blob );

waitbar(0.4,wait, 'Combining blobs')

%% Combine all
[ ~,~, CombinedLabels,LabelsStats  ] = CombineBlobsEllipseAllParams(TotalRegions,TotalStats, f_ma, f_mi, T_H, T_SW, T_D, 0);

%% Final Filter
Filtering = Filtering_Values(Device, 2);
[ CombinedLabels, LabelsStats ] = FilterMSER(CombinedLabels, LabelsStats,  Filtering );


waitbar(0.6,wait, 'Classifying blobs')
% close(wait)

axes(ax)
imshow(IMG)
hold on
plot(CombinedLabels,'showPixelList',true,'showEllipses',false)
LabelsStats = Classify(CombinedLabels, LabelsStats);
hold off

% wait = waitbar(0.8,'Combining blobs');
waitbar(0.8,wait, 'Combining blobs')
%%

fminor = 2;% 2;
fminor_one = 10;% 10;
fmajor = 0.4;% 0.4;


Reading= CombineDigits_BP(LabelsStats, fminor, fminor_one, fmajor, 0);

waitbar(1,wait,  'Done')

close(wait)

end