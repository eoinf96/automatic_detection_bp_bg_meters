% Code modifed from https://uk.mathworks.com/matlabcentral/fileexchange/40266-sauvola-local-image-thresholding
% Distributed under the FreeBSD Software License
% (C) Copyright Jan Motl (jan@motl.us) 2013


%%

function output = sauvola(image, window, k)
    % Initialization
    %   To deal with border distortion the PADDING parameter can be either
    %   set to a scalar or a string: 
    %       'circular'    Pads with circular repetition of elements.
    %       'replicate'   Repeats border elements of matrix A.
    %       'symmetric'   Pads array with mirror reflections of itself. 
    padding = 'replicate';
    
    window = floor([window, window]);

    % Convert to double
    image = double(image);

    % Mean value
    mean = averagefilter(image, window, padding);

    % Standard deviation
    meanSquare = averagefilter(image.^2, window, padding);
    deviation = (meanSquare - mean.^2).^0.5;

    % Sauvola
    R = max(deviation(:));
    threshold = mean.*(1 + k * (deviation / R-1));
    output = (image > threshold);
end

function image=averagefilter(image, window, padding) 
    %   B = AVERAGEFILTER(A, [M N], PADDING) filters matrix A with the 
    %   predefinned padding. By default the matrix is padded with zeros to 
    %   be compatible with IMFILTER. 

    m = window(1);
    n = window(2);

    if ~mod(m,2) m = m-1; end       % check for even window sizes
    if ~mod(n,2) n = n-1; end

    if (ndims(image)~=2)            % check for color pictures
        display('The input image must be a two dimensional array.')
        display('Consider using rgb2gray or similar function.')
        return
    end

    % Initialization.
    [rows columns] = size(image);   % size of the image

    % Pad the image.
    imageP  = padarray(image, [(m+1)/2 (n+1)/2], padding, 'pre');
    imagePP = padarray(imageP, [(m-1)/2 (n-1)/2], padding, 'post');

    % Always use double because uint8 would be too small.
    imageD = double(imagePP);

    % Matrix 't' is the sum of numbers on the left and above the current cell.
    t = cumsum(cumsum(imageD),2);

    % Calculate the mean values from the look up table 't'.
    imageI = t(1+m:rows+m, 1+n:columns+n) + t(1:rows, 1:columns) - t(1+m:rows+m, 1:columns) - t(1:rows, 1+n:columns+n);

    % Now each pixel contains sum of the window. But we want the average value.
    imageI = imageI/(m*n);

    % Return matrix in the original type class.
    image = cast(imageI, class(image));
end