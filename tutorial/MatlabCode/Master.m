clear
close all
clc
%Step 1 -- Convert to HSV colour space
HSV
%Step 2 -- Retinex
Retinex
%Step 3 -- Adaptive Histogram Equalisation
AHE
%Step 4 -- Maximally Stable Extremal Regions
MSER
%Step 5 -- CC of binarise image
BinarisationAndCC
%Step 6 -- Combine
Combine
%Step 7 -- Filter
Filter_Script
%Step 8 -- Classify Blobs
