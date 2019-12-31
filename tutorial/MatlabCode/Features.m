%Run through all images in the saved folders and extract the relevant
%features and save as .mat file

Folder = "MiroLife_BP_Home_Noise_Train';

MatSaveName = 'MiroLife_BP_Home_Noise_Train.mat';

imagefiles = dir('*.png');      
nfiles = length(imagefiles);    % Number of files found

for ii = 1:nfiles
    %Read in image as 52x52 image
    currentfilename = imagefiles(ii).name;
    blob = imread(currentfilename);
        
    
end