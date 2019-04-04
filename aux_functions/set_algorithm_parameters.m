function [params] = set_algorithm_parameters()

%%%%% Binarisation path
params.blob_extraction.Sauv.sigma_s = 30;
params.blob_extraction.Sauv.sigma_r = 0.1;
params.blob_extraction.Sauv.gamma = 1.5;
params.blob_extraction.Sauv.k= 0.34;
params.blob_extraction.Sauv.alpha = 0.059;

%%%%% MSER path
params.blob_extraction.MSER.sigma_s = 30;
params.blob_extraction.MSER.sigma_r = 0.1;
params.blob_extraction.MSER.gamma = 0.7;
params.blob_extraction.MSER.T = 0.3;
params.blob_extraction.MSER.Delta = 0.02;

%%%%% Blob clustering
params.blob_clustering.major_axis = 1.6;
params.blob_clustering.minor_axis = 1.3;

params.blob_clustering.thresholds.Hue = 0.3;
params.blob_clustering.thresholds.SW = 0.2;
params.blob_clustering.thresholds.D = 0.01;

%%%%% Digit combining
params.digit_clustering.minor_axis = 2;
params.digit_clustering.minor_axis_one = 10;
params.digit_clustering.major_axis =0.4;

params.digit_clustering.thresholds.Hue = 0.3;
params.digit_clustering.thresholds.h = 0.1;


end

