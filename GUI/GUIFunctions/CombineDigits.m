function [Reading] = CombineDigits(LabelsStats, fminor, fminor_one, fmajor, plot_flag)
%plot is a flag saying whether to make plots of not
global HEIGHT
global NewWidth


%First find the order of values from left to right.
Output = [LabelsStats.Value];
Cent = [LabelsStats.Centroid];
x = Cent(1:2:end);

[~,Order] = sort(x);

Output = Output(Order);

%% Now combine digits that are close to each other into one reading
%First plot ellipses

%%%%%% Define an ellipse function for later use:
elli = @(x,y, ang1, x01, y01, rx1, ry1) double( ((cos(ang1)*(x - x01) +sin(ang1)*(y - y01))/rx1).^2  + ((sin(ang1)*(x - x01)+cos(ang1)*(y - y01))/ry1).^2   ); 
%%%%%%

EllipseStorage = cell(1,length(LabelsStats));    %for storing the location of each ellipse around the digit so as to check which ellipses collide.
CollideTotal = [];                              %For storing the graph that indicates colliding ellipses.

if plot_flag, figure(200), TotImage = 0; end

for i = 1:length(LabelsStats)           %Go through each digit
    
    x0 = Cent(2*i -1); y0 = Cent(2*i);              %Centroid of the digit
    
    MajorAxis = [ LabelsStats(i).MajorAxisLength]/2;        %Major and Minor axes of ellipses
    MinorAxis = [LabelsStats(i).MinorAxisLength]/2;
    
    
    if LabelsStats(i).Value == 1                    %If the digit is a one then the minor axis should be extended.
        fminor_ellipse = fminor_one;
    else
        fminor_ellipse = fminor;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    if LabelsStats(i).Orientation < 90 || LabelsStats(i).Orientation > -90
        rx = MajorAxis * fmajor;
        ry = MinorAxis * fminor_ellipse;
    else
        rx = MinorAxis * fminor_ellipse;
        ry = MajorAxis * fmajor;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    ang = pi - pi*LabelsStats(i).Orientation/180; 
    
    [u1, v1] = find(ones([HEIGHT, NewWidth]));      %Indices of the scene -- to be put into the ellipse equation to find regions inside and outside ellipse
%     
    figure(100)                     %Plot ellipses on final image
    ellipse(rx,ry,pi - ang,x0,y0);
    hold on
    
    % Save the Ellipse
    EllipseStorage{i} = reshape(elli(v1,u1,ang, x0, y0, rx, ry), [HEIGHT, NewWidth]) < 1;

    if plot_flag
    figure(200)                         %Plot just ellipses
    TotImage = TotImage + EllipseStorage{i};
    imshow(TotImage)
    hold on
    end
    
    Collide = inf*ones(length(LabelsStats),1);       %Indicates which ellipses this collides with
    for j = 1:i
        if j == i 
            continue
        end
                
        %Does ellipse intersect with any other region?
        if any(any(and(EllipseStorage{j},EllipseStorage{i})))

            Collide(j) =  1 ;
        end
        
        
    end
    CollideTotal = [CollideTotal, Collide];

end


%%  Now consider the graph of links between digits

CollideTotal(isinf(CollideTotal)) = 0;         

[n,~]=size(CollideTotal');
CollideTotalNew=CollideTotal'+CollideTotal;
CollideTotalNew(1:n+1:end)=diag(CollideTotal');


%find the graph indicating which digits to be combined
G = graph(CollideTotalNew);



%% Filter the possible readings by number of digits in the reading and the expected value of the reading.

%How many groups?
componentIndices = conncomp(G);

%How many digits in each group? Need to delete those that are less than or
%greater than a certain number
Max_digits = 3; Min_digits = 2;


Max_BG = 21.1; Min_BG = 2.8;


Group_Table = tabulate(componentIndices);       %Group table contains the how many digits are in each group
Group_Table(:,4) = or(Group_Table(:,2) > Max_digits,Group_Table(:,2) < Min_digits);     %Add a column that says if a group has too many or too few digits.


Group_Table_DigitsRemoved = Group_Table(:,1:3);
Group_Table_DigitsRemoved(find(Group_Table(:,4)), :) = [];

%Add a column with the group reading -- If there arent too many or too few digits

TagLabelOrder = componentIndices(Order);
for i = 1:size(Group_Table_DigitsRemoved,1)
    
    label = Group_Table_DigitsRemoved(i,1);
    
    Value = Output(TagLabelOrder == label);
    Value=num2str(Value);
    Value=Value(Value~=' '); % remove the space
    Value = strcat(Value(1:end-1), strcat(".", Value(end)));
    Group_Table_DigitsRemoved(i,3)=str2double(Value);
    
end


%Now check the value of each reading
Group_Table_DigitsRemoved(:,4) = or(Group_Table_DigitsRemoved(:,3) > Max_BG,Group_Table_DigitsRemoved(:,3) < Min_BG);     %Add a column that says if a reading is too large or too small.

Group_Table_ValueRemoved = Group_Table_DigitsRemoved(:,1:3);
Group_Table_ValueRemoved(find(Group_Table_DigitsRemoved(:,4)), :) = [];

%How many readings?
Num = size(Group_Table_ValueRemoved,1);
fprintf(sprintf('%.0f available reading(s) \n', Num))

Reading = Group_Table_ValueRemoved(:, 3);

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