%%
% File    : combine_blobs_ellipse.m
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
%   Combine blobs by fitting ellipses around each blob and forming links
%   between those that are found in each others ellipse. Links are then
%   broken based on certain criteria.
%
%   G1 = initial graph
%   G = final graph after applying conditions
%
%   
% ________________________________________________________________________


function [G1, G, blobs,blobs_stats  ] = combine_blobs_ellipse(blobs,blobs_stats, up, img)
%%

% Set parameters
f_ma = up.params.blob_clustering.major_axis; 
f_mi = up.params.blob_clustering.minor_axis;
T_H = up.params.blob_clustering.thresholds.Hue;
T_SW = up.params.blob_clustering.thresholds.SW;
T_D = up.params.blob_clustering.thresholds.D;

image_height = up.params.height;
image_width = up.params.width;

plot_flag = up.plot_flag;


%% Loop through each blob and fit an ellipse to it. Enlarge the ellipse by a factor
% Defined in set_algorithm parameters and search for other blobs within
% this larger ellipse. Find the minimum distance between the current blob
% and all blobs within the current blob's ellipse - normalise this distance
% by D the length of the diagonal of the original input image.

MinDistTotal = []; 
%MinDistTotal will be a matrix of size NxN where N is the number of blobs.
%It defines the minimum distance from one blob to another provided that the
%second blos is found within the ellipse of the other
D = (sqrt(image_height^2 + image_width^2));

%Perform loop
for i = 1:length(blobs_stats)
    
    
    loc = [blobs_stats(i).Centroid]; % xy location of centroid of blob
    x0 = loc(1);    y0 = loc(2);
    
    MajorAxis = [blobs_stats(i).MajorAxisLength]/2;
    MinorAxis = [blobs_stats(i).MinorAxisLength]/2;
    
    %Enlarge major and minor axis by f_ma and f_mi
    r_ma = MajorAxis*f_ma;    r_mi = MinorAxis*f_mi;
    
    ang = pi*blobs_stats(i).Orientation/180;
     
    %%% Need to plot??
    if plot_flag
        ellipse(r_ma,r_mi,pi-ang,loc(1),loc(2));
        hold on
    end
    
    %Go through each elipse and find regions inside and find closest distance
    elli = @(x,y) double( ((cos(ang)*(x - x0) +sin(ang)*(y - y0))/r_ma).^2  + ((sin(ang)*(x - x0)+cos(ang)*(y - y0))/r_mi).^2   ); 
    %elli defines the distance from a point (x,y) to an elliptical region 
    % around the centrod of the blob with the enlarged major and minor
    % axes -- any values < 1 are within the ellipse and any values >1 are
    % outside of the ellipse
  
    %define a black image with the same size as the original image
    BinaryIMG = zeros([image_height, image_width]);
    BinaryIMG_Current = BinaryIMG;
    %put the blob in as an array of ones
    BinaryIMG_Current([blobs_stats(i).PixelIdxList]) = 1;
    
    boundary_curent = bwboundaries(BinaryIMG_Current);
    %The boundary of the current blob
    y_current = boundary_curent{1,1}(:,2);
    x_current = boundary_curent{1,1}(:,1);
    
    
    %MinDidt defines the minimum distance from the current blob to a new
    %blob -- if the blos is not found inside the ellipse defined by
    %elli(x,y) then the distance is set to infinity
    MinDist = inf*ones(length(blobs_stats),1);
    for j = 1:length(blobs_stats)
        if j == i 
            %Skip measuring the distance to the same blob
            continue
        end
        [v, u] = ind2sub([image_height, image_width],[blobs_stats(j).PixelIdxList]);
        
        %Does ellipse intersect with any other region?        
        if any(elli(u,v) < 1)
            BinaryIMG_FindDist = BinaryIMG;
            
            BinaryIMG_FindDist([blobs_stats(j).PixelIdxList]) = 1;
            
            boundary_finddist = bwboundaries(BinaryIMG_FindDist);
            y = boundary_finddist{1,1}(:,2);
            x = boundary_finddist{1,1}(:,1);
            
%             [y, x] = ind2sub([HEIGHT, NewWidth],[regionStats(j).PixelIdxList]);
            
            %find the minimum distance from the current blob to the blob j
            Dist = pdist2([x_current, y_current], [x, y]);

            %normalise by D
            MinDist(j) =  min(min(Dist))/D ;
        end
        
        
    end
    MinDistTotal = [MinDistTotal, MinDist];
end

MinDistTotal(MinDistTotal == 0) = eps;


%% Now define the graph of links between blobs
% Remove non symmetric
[NonSymmetricy,NonSymmetricx]  = find(~(triu(MinDistTotal, 1) == tril(MinDistTotal, -1)'));

for i = 1:length(NonSymmetricx)
    MinDistTotal(NonSymmetricy(i), NonSymmetricx(i)) = inf;
    MinDistTotal(NonSymmetricx(i), NonSymmetricy(i)) = inf;
end

MinDistTotal(isinf(MinDistTotal)) = 0;

%Find the first graph 
G1 = graph(MinDistTotal);
if plot_flag
    figure
    plot(G1)
    title('Initial graph of links between blobs')
end

%% Apply conditions to remove links between blobs if they are not similar enough

%CONDITION 1
%The normalised distance must be within T_D
DistcondThresh = MinDistTotal < T_D;



%CONDITION 2
%The hues must be within T_H
AveHue =  arrayfun(@(k) mean(blobs_stats(k).Hue), 1:numel(blobs_stats))';
HueCond = repmat(AveHue, [1,length(AveHue)]);
HueCondThresh = abs(HueCond - HueCond')<T_H;


%CONDITION 3
%The normalised Stroke Width must be within T_SW
AveSWT = arrayfun(@(k) mean(blobs_stats(k).swtMap), 1:numel(blobs_stats))';
AveSWT(isnan(AveSWT)) = [];

SWTGlobalAve = mean(AveSWT);
SWTCond = repmat(AveSWT, [1,length(AveSWT)]);
SWTCondThresh = (abs(SWTCond - SWTCond')/SWTGlobalAve)<T_SW;




%% Now remove links if the conditions are not met
MinDistTotal = MinDistTotal.*HueCondThresh.*SWTCondThresh.*DistcondThresh;


G = graph(MinDistTotal);
if plot_flag
    figure
    plot(G)
    title('Final graph of links between blobs after applying conditions')
end

%% Now combine groups on graph to be one label 
componentIndices = conncomp(G);
%% Go through the connected Components and give label
%     CombinedLabels = zeros(HEIGHT, NewWidth);
%     
%     for i = 1:max(componentIndices)
% %        idx = find(componentIndices == i);
%        PixelIdxList = vertcat(regionStats(componentIndices == i).PixelIdxList);
%        CombinedLabels(PixelIdxList) = i;
%     end
    
  
%     LabelsStats = regionprops(CombinedLabels,'PixelIdxList','Centroid', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');


NewPixelList = cell(max(componentIndices),1);
PixelList = blobs.PixelList;

IndexList = cell(max(componentIndices),1);
for i = 1:length(NewPixelList)
   Combined = PixelList(componentIndices == i);
   NewPixelList(i) =  {vertcat(Combined{:})};
   
   IndexList(i) = {sub2ind([image_height, image_width],NewPixelList{i}(:,2), NewPixelList{i}(:,1))};
   
end

blobs.PixelList = NewPixelList;

ConnComp.Connectivity = 8;
ConnComp.ImageSize = [image_height, image_width];
ConnComp.NumObjects = i;
ConnComp.PixelIdxList = IndexList;



blobs_stats = regionprops(ConnComp,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');



    %% Get Hue Stat
    
    hsv = rgb2hsv(img);
    hue = hsv(:,:,1);
    
    for i= 1:length(blobs_stats)
       blobs_stats(i).Hue = hue([blobs_stats(i).PixelIdxList ]);
    end



end


function h=ellipse(ra,rb,ang,x0,y0,C,Nb)
%% Code modifed from https://uk.mathworks.com/matlabcentral/fileexchange/289-ellipse-m
% Distributed under the FreeBSD Software License
% (C) Copyright David Long (jan@motl.us) 2018
%%
% Ellipse adds ellipses to the current plot
%
% ELLIPSE(ra,rb,ang,x0,y0) adds an ellipse with semimajor axis of ra,
% a semimajor axis of radius rb, a semimajor axis of ang, centered at
% the point x0,y0.
%
% The length of ra, rb, and ang should be the same. 
% If ra is a vector of length L and x0,y0 scalars, L ellipses
% are added at point x0,y0.
% If ra is a scalar and x0,y0 vectors of length M, M ellipse are with the same 
% radii are added at the points x0,y0.
% If ra, x0, y0 are vectors of the same length L=M, M ellipses are added.
% If ra is a vector of length L and x0, y0 are  vectors of length
% M~=L, L*M ellipses are added, at each point x0,y0, L ellipses of radius ra.
%
% ELLIPSE(ra,rb,ang,x0,y0,C)
% adds ellipses of color C. C may be a string ('r','b',...) or the RGB value. 
% If no color is specified, it makes automatic use of the colors specified by 
% the axes ColorOrder property. For several circles C may be a vector.
%
% ELLIPSE(ra,rb,ang,x0,y0,C,Nb), Nb specifies the number of points
% used to draw the ellipse. The default value is 300. Nb may be used
% for each ellipse individually.
%
% h=ELLIPSE(...) returns the handles to the ellipses.
%
% usage exmple: the following produces a red ellipse centered at 1,1
% and tipped down at a 45 deg axis from the x axis
% ellipse(1,2,pi/4,1,1,'r')
%
% note that if ra=rb, ELLIPSE plots a circle
%

% written by D.G. Long, Brigham Young University, based on the
% CIRCLES.m original 
% written by Peter Blattner, Institute of Microtechnology, University of 
% Neuchatel, Switzerland, blattner@imt.unine.ch




% Check the number of input arguments 

if nargin<1,
  ra=[];
end;
if nargin<2,
  rb=[];
end;
if nargin<3,
  ang=[];
end;

if nargin<5,
  x0=[];
  y0=[];
end;
 
if nargin<6,
  C=[];
end

if nargin<7,
  Nb=[];
end

% set up the default values

if isempty(ra),ra=1;end;
if isempty(rb),rb=1;end;
if isempty(ang),ang=0;end;
if isempty(x0),x0=0;end;
if isempty(y0),y0=0;end;
if isempty(Nb),Nb=300;end;
if isempty(C),C=get(gca,'colororder');end;

% work on the variable sizes

x0=x0(:);
y0=y0(:);
ra=ra(:);
rb=rb(:);
ang=ang(:);
Nb=Nb(:);

if isstr(C),C=C(:);end;

if length(ra)~=length(rb),
  error('length(ra)~=length(rb)');
end;
if length(x0)~=length(y0),
  error('length(x0)~=length(y0)');
end;

% how many inscribed elllipses are plotted

if length(ra)~=length(x0)
  maxk=length(ra)*length(x0);
else
  maxk=length(ra);
end;

% drawing loop

for k=1:maxk
  
  if length(x0)==1
    xpos=x0;
    ypos=y0;
    radm=ra(k);
    radn=rb(k);
    if length(ang)==1
      an=ang;
    else
      an=ang(k);
    end;
  elseif length(ra)==1
    xpos=x0(k);
    ypos=y0(k);
    radm=ra;
    radn=rb;
    an=ang;
  elseif length(x0)==length(ra)
    xpos=x0(k);
    ypos=y0(k);
    radm=ra(k);
    radn=rb(k);
    an=ang(k)
  else
    rada=ra(fix((k-1)/size(x0,1))+1);
    radb=rb(fix((k-1)/size(x0,1))+1);
    an=ang(fix((k-1)/size(x0,1))+1);
    xpos=x0(rem(k-1,size(x0,1))+1);
    ypos=y0(rem(k-1,size(y0,1))+1);
  end;

  co=cos(an);
  si=sin(an);
  the=linspace(0,2*pi,Nb(rem(k-1,size(Nb,1))+1,:)+1);
%  x=radm*cos(the)*co-si*radn*sin(the)+xpos;
%  y=radm*cos(the)*si+co*radn*sin(the)+ypos;
  p=line(radm*cos(the)*co-si*radn*sin(the)+xpos,radm*cos(the)*si+co*radn*sin(the)+ypos);
  set(p,'color',C(rem(k-1,size(C,1))+1,:));
  
  if nargout > 0
    h(k)=p;
  end
  
end;


end
