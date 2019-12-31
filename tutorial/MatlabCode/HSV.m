IMG_Original = imread('BPMeter.png'); %Read in the image

%Resize the image for processing speed -- can change to be anything 
global HEIGHT; HEIGHT = 500;
global NewWidth; 
NewWidth = ceil(HEIGHT / size(IMG_Original,1) * size(IMG_Original,2));
IMG_Original= imresize(IMG_Original, [HEIGHT, NewWidth]);

hsv = rgb2hsv(IMG_Original); %Convert RGB to HSV

hue = hsv(:,:,1); value = hsv(:,:,3); %Save the hue and value component