%Code Editted from: https://github.com/rbotta/gaze-text-detection.git	

function [swtMap ] = StrokeWidthTransform( im )

     swtMap  = FirstAndSecondPass( im );
        
end

function [ swtMap ] = FirstAndSecondPass( im )
global HEIGHT
%swt Preforms stoke width transform on input image

searchDirection =1; %For Black text on white background

 im = double(im);

% Find edges using canny edge dector
edgeMap = edge(im, 'canny');
% edgeMap = CannyEdge(im);

% Get all edge pixel postitions
[edgePointRows, edgePointCols] = find(edgeMap);

% Find gradient horizontal and vertical gradient
sobelMask = fspecial('sobel');
dx = imfilter(im,sobelMask);
dy = imfilter(im,sobelMask');
% figure, imshow(dx, []), title('Horizontal Gradient Image');
% figure, imshow(dy, []), title('Vertical Gradient Image');

% Initializing matrix of gradient direction
theta = zeros(size(edgeMap,1),size(edgeMap,2));

% Calculating theta, gradient direction, for each pixel on the image.
% ***This can be optimized by using edgePointCols and edgePointRows
% instead.***
for i=1:size(edgeMap,1)
    for j=1:size(edgeMap,2)
        if edgeMap(i,j) == 1
            theta(i,j) = atan2(dy(i,j),dx(i,j));
        end
    end
end

% Getting size of the image
[m,n] = size(edgeMap);

% Initializing Stoke Width array with infinity
swtMap = zeros(m,n);
for i=1:m
    for j=1:n
        swtMap(i,j) = inf;
    end
end

% Set the maximum stroke width, this number is variable for now but must be
% made to be more dynamic in the future
maxStrokeWidth = HEIGHT/2;

% Initialize container for all stoke points found
strokePointsX = zeros(size(edgePointCols));
strokePointsY = zeros(size(strokePointsX));
sizeOfStrokePoints = 0;

% Iterate through all edge points and compute stoke widths
for i=1:size(edgePointRows)
    step = 1;
    initialX = edgePointRows(i);
    initialY = edgePointCols(i);
    isStroke = 0;
    initialTheta = theta(initialX,initialY);
    sizeOfRay = 0;
    pointOfRayX = zeros(maxStrokeWidth,1);
    pointOfRayY = zeros(maxStrokeWidth,1);
    
    % Record first point of the ray
    pointOfRayX(sizeOfRay+1) = initialX;
    pointOfRayY(sizeOfRay+1) = initialY;
    
    % Increase the size of the ray
    sizeOfRay = sizeOfRay + 1;
    
    % Follow the ray
    while step < maxStrokeWidth
        nextX = round(initialX + cos(initialTheta) * searchDirection * step);
        nextY = round(initialY + sin(initialTheta) * searchDirection * step);
        
        step = step + 1;
        
        % Break loop if out of bounds.  For some reason this is really
        % slow.
        if nextX < 1 | nextY < 1 | nextX > m | nextY > n
            break
        end
        
        % Record next point of the ray
        pointOfRayX(sizeOfRay+1) = nextX;
        pointOfRayY(sizeOfRay+1) = nextY;
        
        % Increase size of the ray
        sizeOfRay = sizeOfRay + 1;
        
        % Another edge pixel has been found
        if edgeMap(nextX,nextY)
            
            oppositeTheta = theta(nextX,nextY);
            
            % Gradient direction roughtly opposite
            if abs(abs(initialTheta - oppositeTheta) - pi) < pi/2
                isStroke = 1;
                strokePointsX(sizeOfStrokePoints+1) = initialX;
                strokePointsY(sizeOfStrokePoints+1) = initialY;
                sizeOfStrokePoints = sizeOfStrokePoints + 1;
            end
            
            break
        end
    end
    
    % Edge pixel is part of stroke
    if isStroke
        
        % Calculate stoke width
        strokeWidth = sqrt((nextX - initialX)^2 + (nextY - initialY)^2);
        
        % Iterate all ray points and populate with the minimum stroke width
        for j=1:sizeOfRay
            swtMap(pointOfRayX(j),pointOfRayY(j)) = min(swtMap(pointOfRayX(j),pointOfRayY(j)),strokeWidth);
        end
    end
end

% figure, imshow(swtMap, []), title('Stroke Width Transform: First Pass');


% Iterate through all stoke points for a refinement pass.  Refer to figure
% 4b in the paper.

for i=1:sizeOfStrokePoints
    step = 1;
    initialX = strokePointsX(i);
    initialY = strokePointsY(i);
    initialTheta = theta(initialX,initialY);
    sizeOfRay = 0;
    pointOfRayX = zeros(maxStrokeWidth,1);
    pointOfRayY = zeros(maxStrokeWidth,1);
    swtValues = zeros(maxStrokeWidth,1);
    sizeOfSWTValues = 0;
    
    % Record first point of the ray
    pointOfRayX(sizeOfRay+1) = initialX;
    pointOfRayY(sizeOfRay+1) = initialY;
    
    % Increase the size of the ray
    sizeOfRay = sizeOfRay + 1;
    
    % Record the swt value of first stoke point
    swtValues(sizeOfSWTValues+1) = swtMap(initialX,initialY);
    sizeOfSWTValues = sizeOfSWTValues + 1;
    
    % Follow the ray
    while step < maxStrokeWidth
        nextX = round(initialX + cos(initialTheta) * searchDirection * step);
        nextY = round(initialY + sin(initialTheta) * searchDirection * step);
        
        step = step + 1;
        
        % Record next point of the ray
        pointOfRayX(sizeOfRay+1) = nextX;
        pointOfRayY(sizeOfRay+1) = nextY;
        
        % Increase size of the ray
        sizeOfRay = sizeOfRay + 1;
        
        % Record the swt value of next stoke point
        swtValues(sizeOfSWTValues+1) = swtMap(nextX,nextY);
        sizeOfSWTValues = sizeOfSWTValues + 1;
        
        % Another edge pixel has been found
        if edgeMap(nextX,nextY)
            break
        end
    end
    
    % Calculate stoke width as the median value of all swtValues seen.
    strokeWidth = median(swtValues(1:sizeOfSWTValues));
    
    % Iterate all ray points and populate with the minimum stroke width
    for j=1:sizeOfRay
        swtMap(pointOfRayX(j),pointOfRayY(j)) = min(swtMap(pointOfRayX(j),pointOfRayY(j)),strokeWidth);
    end
    
end

% figure, imshow(swtMap, []), title('Stroke Width Transform: Second Pass');

end

%%
function [ letters, swtrejected , NewswtMap] = FilterComponents( swtMap, swtLabel, ccNum, Filtering )
%Filter Blobs based on stroke widths

numLetters = 0;
letters = zeros(size(swtLabel));
swtrejected = zeros(size(swtLabel));

for i=1:ccNum
    if ~ismember(i, swtLabel)
            continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    %Filtering Values Setting
%     imshow(swtLabel==i)
    %%%%%%%%%%%%%%%%%%%%%%%
    
    [r,c] = find(swtLabel==i);
    idx = sub2ind(size(swtMap),r,c);
    componentSW = swtMap(idx);
    componentSW(componentSW == inf) = [];
    
    if isempty(componentSW)
        continue
    end
    
    varianceSW = var(componentSW);
    meanSW = mean(componentSW);
    width = max(c) - min(c);
    height = max(r) - min(r);
    diameter = sqrt(width^2+height^2);
    medianSW = median(componentSW);
    maxSW = max(componentSW);
    
    % Reject CC with hight stroke width variance.  The threshold if half
    % the average stroke width of a connected component
    if varianceSW/meanSW >Filtering.VarianceMean
        swtrejected(idx) =1;
        continue
    end
    
    % Ratio between the diameter of the connected component and its
    % median stroke width to be a value less than 10
    if diameter/medianSW >= Filtering.DiameterMedian
        %Save these letters in separate array to show which have been
        %rejected this way 
        swtrejected(idx) =1;
        continue
    end
    
    if size(componentSW,1)/maxSW >= Filtering.LengthMaxUpper || size(componentSW,1)/maxSW < Filtering.LengthMaxLower
        swtrejected(idx) =1;
        continue
    end
    
    
    letters(idx) = i;
end


NewswtMap = swtMap.*letters;
end


function [ Canny ] = CannyEdge( IMG )
%Go through horizontally and if there is a transition change 255 to 1

%Initalise Canny Matrix
Canny = ones(size(IMG));

for i = 2:size(IMG,1)
    %Vertical
    for j =1:size(IMG,2)
        %Horizontal
        if(abs(IMG(i-1, j) - IMG(i,j))) ==0
            Canny(i,j) = 0;
        end
        
    end
end

Canny2 = ones(size(IMG));

for j = 2:size(IMG,2)
    %Horizontal
    for i =1:size(IMG,1)
        %Vertical
        if(abs(IMG(i, j-1) - IMG(i,j))) ==0
            Canny2(i,j) = 0;
        end
        
    end
end

Canny = Canny + Canny2;

end