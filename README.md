# Matlab code for reading physiological values from images of blood glucose meters and blood pressure monitors #

The algorithms are defined in "Automated method for detecting and reading seven-segment digits from images of blood glucose meters and blood pressure monitors" - E.Finnegan

The process is as follows:

* Extract blobs (regions of an image that are likely to be segments).
* Filter blobs to remove noise
* Combine blobs to form seven-segment digits
* Classify the digits by their value from 0-9
* Combine digits to form physiological readings

Image dataset to be downloaded from: https://cameralab.eng.ox.ac.uk/resources.html, these images have been used to develop the algorithms presented in this repository. It is recommended for the user to download these images and copy to /data/images in the repository folder.

For use on a new dataset it is suggested that the user changes the parameters found in set_algorithm_parameters.m

The adjusted parameters can be tested using the GUI (still in development). The optimum parameters can be found by using the method in the original paper.

To compute a reading from an image run the code compute_reading_from_image.m. The image path is set as up.paths.image_folder on line 48. The output is printed to the command window.


=======================================

# Requirements #

=======================================


The code provided requires the following products be installed:

MATLAB R2018b
MATLAB R2018b: Image processing Toolbox
MATLAB R2018b: Parallel Computing Toolbox
MATLAB R2018b: Statistics and Machine Learning Toolbox
