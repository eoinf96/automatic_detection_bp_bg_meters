%First define the relevant parameters
sigmaSpatial = 30; sigmaRange = 0.1; samplingSpatial = sigmaSpatial; samplingRange = sigmaRange;
gamma = 1.5;

%Apply retinex using two bilateral filters from https://github.com/KirillLykov/cvision-algorithms.git
image_retinex = retinexFilter(value, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange, gamma, 0);

%Show the results
figure
multi = cat(3, value, image_retinex);
montage(multi)
title('Applying Retinex')
