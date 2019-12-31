%%
% File    : compute_reading_from_image.m
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
%
%
% LITERATURE
% ----------
% Automated method for detecting and reading seven segment digits from 
% images of blood glucose metres and blood pressure monitors - E.Finnegan
%
% ________________________________________________________________________

%%
close all
clear
clc
%%

t_start = cputime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set universal parameters
up.rand_flag = true;
up.plot_flag = true;
up.device_type = 'BG';
up.device_name = 'OneTouch';



%Add functions path to the working path
up.paths.function_path = './aux_functions';
addpath(genpath(up.paths.function_path));

%path to the directory containing the images
image_folder_root = './data/images/';

up.paths.image_folder = [image_folder_root, up.device_name, '/Train'];


%Check that the folder exists
if ~exist(up.paths.image_folder, 'dir')
   error('Image folder does not exist') 
end

%Edit the function set_algorithm_parameters to edit the parameters of the
%algorithms used.
up.params = set_algorithm_parameters;


% Blob filtering weights -- load your own here if trained on a
% different dataset
if strcmp(up.device_type, 'BG')
    blob_filtering_weights_loc = './data/weights/blob_filtering_weights_one_touch.mat';
elseif strcmp(up.device_type, 'BP')
    blob_filtering_weights_loc = './data/weights/blob_filtering_weights_microlife.mat';
else
    error('The device type is unkown - only BG or BP are supported')
end
load(blob_filtering_weights_loc, 'w')

up.params.blob_filtering_weights = w;


%%%%% Digit classification weights -- load your own here if trained on a
%%%%% different dataset
load('./data/weights/digit_classification_weights.mat', 'W')
up.params.digit_classification_weights = W; 

%clear unneeded variables
clear w W

%%

if up.rand_flag
    FileList = dir(fullfile(up.paths.image_folder));
    FileList = FileList(62:end);

    index    = randperm(numel(FileList), 1);

    up.paths.image_name = FileList(index).name;
    up.paths.image_path = fullfile(up.paths.image_folder, FileList(index).name);
    
    
    %clear unneeded variables
    clear FileList index
else
   up.paths.image_name = 'IMG_8468.JPG'; 
   up.paths.image_path = strcat(strcat(up.paths.image_folder, '/'), up.paths.image_name);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in image and resize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

img = imread(up.paths.image_path);

%%%%%%%%%%%%%%%% rotate
info = imfinfo(up.paths.image_path);
if isfield(info,'Orientation')
   switch info(1).Orientation
     case 1
        %normal, leave the data alone
     case 2
        img = img(:,end:-1:1,:);         %right to left
     case 3
        img = img(end:-1:1,end:-1:1,:);  %180 degree rotation
     case 4
        img = img(end:-1:1,:,:);         %bottom to top
     case 5
        img = permute(img, [2 1 3]);     %counterclockwise and upside down
     case 6
        img = rot90(img,3);              %undo 90 degree by rotating 270
     case 7
        img = rot90(img(end:-1:1,:,:));  %undo counterclockwise and left/right
     case 8
        img = rot90(img);                %undo 270 rotation by rotating 90
     otherwise
        warning(sprintf('unknown orientation %g ignored\n', orient));
   end
end
 
%clear unneeded variables
clear info
%%%%%%%%%%%%%%%% 


up.params.height = 500;
f = up.params.height / size(img,1);

up.params.width = ceil(f * size(img,2));
img= imresize(img, [up.params.height, up.params.width]);

%clear unneeded variables
clear f
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
fprintf(" --- Extracting Blobs --- ")

%% Binarisation

% Blob extraction via connected components of a binarised image
[ blobs_binarisation, blobs_binarisation_stats ] = blob_extraction_binarisation(img, up);


%% MSER

% Blob extraction via Maximally Stable Extremal Regions
[ blobs_MSER, blobs_MSER_stats ] = blob_extraction_MSER(img, up);
%% combine regions of MSER and Sauvola
blobs = blobs_MSER;
blobs.PixelList = [blobs_binarisation.PixelList; blobs_MSER.PixelList];

blobs_stats = [blobs_binarisation_stats; blobs_MSER_stats];

t_blob = cputime;
fprintf(sprintf("        %.2f seconds \n", t_blob - t_start))

%clear unneeded variables
clear blobs_binarisation blobs_binarisation_stats blobs_MSER blobs_MSER_stats 

%%
fprintf(" --- Filtering Blobs --- ")

% Filter the blobs via rule based filtering
up.params.filtering = get_filtering_values(up, 1);
[ blobs, blobs_stats ] = filter_blobs_rule_based(blobs, blobs_stats,  up);


%% 

% Filter the blobs via classification using a feature vector
[ blobs, blobs_stats] = filter_blobs_feature_vector(blobs, blobs_stats, up );

if up.plot_flag
    figure, imshow(img)
    hold on
    plot(blobs,'showPixelList',true,'showEllipses',false)
    hold off
end

t_filt = cputime;
fprintf(sprintf("        %.2f seconds \n", t_filt - t_blob))

%% Combine blobs
fprintf(" --- Combining Blobs --- ")

%Combine blobs by ellipse fitting
[ G,G1, blobs,blobs_stats  ] = combine_blobs_ellipse(blobs,blobs_stats,up, img);

if up.plot_flag
    figure, imshow(img)
    hold on
    plot(blobs,'showPixelList',true,'showEllipses',false)
    hold off
end


t_comb = cputime;
fprintf(sprintf("        %.2f seconds \n", t_comb - t_filt))
%% Final Filter
if ~isempty(blobs_stats)
    up.params.filtering = get_filtering_values(up, 2);
    [ blobs, blobs_stats ] = filter_blobs_rule_based(blobs, blobs_stats,  up );
else
    warning('There are no blobs remaining')
    return
end

if up.plot_flag
    figure, imshow(img)
    hold on
    plot(blobs,'showPixelList',true,'showEllipses',false)
    hold off
end

%% Classify
fprintf(" --- Classify digits --- ")


if up.plot_flag
    %Plot a rectangle around each classified digit in the image with its
    %label
    figure(100)
    imshow(img)
    title('Labelled Image')
    hold on
end
blobs_stats = classify_digits( blobs, blobs_stats, up );

if up.plot_flag
    hold off
end

t_class = cputime;
fprintf(sprintf("        %.2f seconds \n", t_class - t_comb))


%% Get Output Value
fprintf(" --- Combine digits and get reading(s) ---  \n")


reading = combine_digits(blobs_stats,up);

t_comb_dig = cputime;
fprintf(sprintf("        %.2f seconds \n", t_comb_dig - t_class))



fprintf(sprintf(" Total time: %.2f seconds \n", t_comb_dig - t_start))
