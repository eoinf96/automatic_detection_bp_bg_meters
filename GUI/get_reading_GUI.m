%%%
% File    : get_reading_GUI.m
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
%   Automatically locate, classify and combine digits found in images of
%   blood glucose and blood pressure monitors
%   This function is developed to operate with the GUI created
%

% ________________________________________________________________________


function [reading] = get_reading_GUI(image_file_name,params)

up.params = params;
up.plot_flag = true;
up.paths.function_path = '../aux_functions';
addpath(genpath(up.paths.function_path));


if strcmp(up.params.device_type, 'Blood Glucose')
    up.params.device_type = 'BG';
    blob_filtering_weights_loc = '../data/weights/blob_filtering_weights_one_touch.mat';
elseif strcmp(up.params.device_type, 'Blood Pressure')
    up.params.device_type = 'BP';
    blob_filtering_weights_loc = '../data/weights/blob_filtering_weights_microlife.mat';
else
    error('The device type is unkown - only BG or BP are supported')
end
load(blob_filtering_weights_loc, 'w')

up.params.blob_filtering_weights = w;


load('../data/weights/digit_classification_weights.mat', 'W')
up.params.digit_classification_weights = W; 



img = imread(image_file_name);

global HEIGHT 
HEIGHT = 500;
Factor = HEIGHT / size(img,1);
global NewWidth
% NewWidth = size(IMG_Original,2);
NewWidth = ceil(Factor * size(img,2));
img= imresize(img, [HEIGHT, NewWidth]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Binarisation
wait = waitbar(0,'Getting blobs');

%Get Retinex
[ blobs_binarisation, blobs_binarisation_stats ] = blob_extraction_binarisation(img, up);
%% MSER

[ blobs_MSER, blobs_MSER_stats ] = blob_extraction_MSER(img, up);



%% combine regions of MSER and Sauvola
blobs = blobs_MSER;
blobs.PixelList = [blobs_binarisation.PixelList; blobs_MSER.PixelList];
blobs_stats = [blobs_binarisation_stats; blobs_MSER_stats];


waitbar(0.2,wait, 'Filtering Blobs')

%Filter Binarised
up.params.filtering = get_filtering_values(up, 1);
[ blobs, blobs_stats ] = filter_blobs_rule_based(blobs, blobs_stats,  up);
%% Now classify

[ blobs, blobs_stats] = filter_blobs_feature_vector(blobs, blobs_stats, up );

waitbar(0.4,wait, 'Combining blobs')

%% Combine all
[ ~,~, blobs,blobs_stats  ] = combine_blobs_ellipse(blobs,blobs_stats,up, img);

%% Final Filter
up.params.filtering = get_filtering_values(up, 2);
[ blobs, blobs_stats ] = filter_blobs_rule_based(blobs, blobs_stats,  up );


waitbar(0.6,wait, 'Classifying blobs')
% close(wait)

axes(ax)
imshow(IMG)
hold on
plot(blobs,'showPixelList',true,'showEllipses',false)
blobs_stats = classify_digits( blobs, blobs_stats, up );
hold off

% wait = waitbar(0.8,'Combining blobs');
waitbar(0.8,wait, 'Combining blobs')
%%

reading = combine_digits(blobs_stats,up);

waitbar(1,wait,  'Done')

close(wait)



end

