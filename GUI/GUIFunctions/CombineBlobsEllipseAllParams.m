function [G1, G, MSER,LabelsStats  ] = CombineBlobsEllipseAllParams(MSER,regionStats, fx, fy,  T_H, T_SW, T_D, plot)
%plot is a flag saying wheter to make plots of not
global HEIGHT
global NewWidth

MinDistTotal = [];
D = (sqrt(NewWidth^2 + HEIGHT^2));
for i = 1:length(regionStats)
    
    loc = [regionStats(i).Centroid];
    x0 = loc(1);    y0 = loc(2);
    
    MajorAxis = [regionStats(i).MajorAxisLength]/2;
    MinorAxis = [regionStats(i).MinorAxisLength]/2;
    rx = MajorAxis*fx;    ry = MinorAxis*fy;
    
    ang = pi*regionStats(i).Orientation/180;
     
     %%% Need to plot??
    if plot
        ellipse(rx,ry,pi-ang,loc(1),loc(2));
        hold on
    end
    
    %Go through each elipse and find regions inside and find closest distance

    elli = @(x,y) double( ((cos(ang)*(x - x0) +sin(ang)*(y - y0))/rx).^2  + ((sin(ang)*(x - x0)+cos(ang)*(y - y0))/ry).^2   ); 
    
  
    
    BinaryIMG = zeros([HEIGHT, NewWidth]);
    BinaryIMG_Current = BinaryIMG;
    BinaryIMG_Current([regionStats(i).PixelIdxList]) = 1;
    
    boundary_curent = bwboundaries(BinaryIMG_Current);
    y_current = boundary_curent{1,1}(:,2);
    x_current = boundary_curent{1,1}(:,1);
%     [y_current, x_current] = ind2sub([HEIGHT, NewWidth],[regionStats(i).PixelIdxList]);
    
    MinDist = inf*ones(length(regionStats),1);
    for j = 1:length(regionStats)
        if j == i 
            continue
        end
        [v, u] = ind2sub([HEIGHT, NewWidth],[regionStats(j).PixelIdxList]);
        
        %Does ellipse intersect with any other region?        
        if any(elli(u,v) < 1)
            BinaryIMG_FindDist = BinaryIMG;
            
            BinaryIMG_FindDist([regionStats(j).PixelIdxList]) = 1;
            
            boundary_finddist = bwboundaries(BinaryIMG_FindDist);
            y = boundary_finddist{1,1}(:,2);
            x = boundary_finddist{1,1}(:,1);
            
%             [y, x] = ind2sub([HEIGHT, NewWidth],[regionStats(j).PixelIdxList]);
            
            Dist = pdist2([x_current, y_current], [x, y]);


            MinDist(j) =  min(min(Dist))/D ;
        end
        
        
    end
    MinDistTotal = [MinDistTotal, MinDist];
end

MinDistTotal(MinDistTotal == 0) = eps;
% MinDistTotal = MinDistTotal/(sqrt(size(IMG_Original,1)^2 + size(IMG_Original,2)^2));


%%
% Remove non symmetric
[NonSymmetricy,NonSymmetricx]  = find(~(triu(MinDistTotal, 1) == tril(MinDistTotal, -1)'));

for i = 1:length(NonSymmetricx)
    MinDistTotal(NonSymmetricy(i), NonSymmetricx(i)) = inf;
    MinDistTotal(NonSymmetricx(i), NonSymmetricy(i)) = inf;
end

MinDistTotal(isinf(MinDistTotal)) = 0;


G1 = graph(MinDistTotal);



AveHue =  arrayfun(@(k) mean(regionStats(k).Hue), 1:numel(regionStats))';
AveSWT = arrayfun(@(k) mean(regionStats(k).swtMap), 1:numel(regionStats))';
AveSWT(isnan(AveSWT)) = [];
SWTGlobalAve = mean(AveSWT);

HueCond = repmat(AveHue, [1,length(AveHue)]);
HueCondThresh = abs(HueCond - HueCond')<T_H;

SWTCond = repmat(AveSWT, [1,length(AveSWT)]);
SWTCondThresh = (abs(SWTCond - SWTCond')/SWTGlobalAve)<T_SW;

DistcondThresh = MinDistTotal < T_D;


MinDistTotal = MinDistTotal.*HueCondThresh.*SWTCondThresh.*DistcondThresh;


G = graph(MinDistTotal);
% if plot
%     figure
%     Weights = G.Edges.Weight;
%     L = 5*Weights/max(Weights);
%      plot(G, 'LineWidth', L)
% end

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
PixelList = MSER.PixelList;

IndexList = cell(max(componentIndices),1);
for i = 1:length(NewPixelList)
   Combined = PixelList(componentIndices == i);
   NewPixelList(i) =  {vertcat(Combined{:})};
   
   IndexList(i) = {sub2ind([HEIGHT, NewWidth],NewPixelList{i}(:,2), NewPixelList{i}(:,1))};
   
end

MSER.PixelList = NewPixelList;

ConnComp.Connectivity = 8;
ConnComp.ImageSize = [HEIGHT, NewWidth];
ConnComp.NumObjects = i;
ConnComp.PixelIdxList = IndexList;



LabelsStats = regionprops(ConnComp,'PixelIdxList','Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'Area', 'BoundingBox', 'Euler', 'Solidity', 'Extent', 'Image');







end


function h=ellipse(ra,rb,ang,x0,y0,C,Nb)
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
