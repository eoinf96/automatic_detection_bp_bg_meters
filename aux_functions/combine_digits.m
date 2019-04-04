%%
% File    : combine_digits.m
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

%
function [reading] = combine_digits(blobs_stats,up)

%% First define the variables
fminor = up.params.digit_clustering.minor_axis;
fminor_one = up.params.digit_clustering.minor_axis_one;
fmajor = up.params.digit_clustering.major_axis;

image_height = up.params.height;
image_width = up.params.width;

T_H = up.params.digit_clustering.thresholds.Hue;
T_height = up.params.digit_clustering.thresholds.h;

plot_flag = up.plot_flag;
%%


elli = @(x,y, ang1, x01, y01, rx1, ry1) double( ((cos(ang1)*(x - x01) +sin(ang1)*(y - y01))/rx1).^2  + ((sin(ang1)*(x - x01) - cos(ang1)*(y - y01))/ry1).^2   ); 
%%%%%%

EllipseStorage = cell(1,length(blobs_stats));    %for storing the location of each ellipse around the digit so as to check which ellipses collide.
CollideTotal = [];                              %For storing the graph that indicates colliding ellipses.


% figure(100)
% set(gca, 'ZDir','reverse')
% set(gca, 'XDir','reverse')

if plot_flag
figure(200)
TotImage = 0; 
end

Cent = [blobs_stats.Centroid];



for i = 1:length(blobs_stats)           %Go through each digit
    
    x0 = Cent(2*i -1); y0 = Cent(2*i);              %Centroid of the digit
    
    MajorAxis = [ blobs_stats(i).MajorAxisLength]/2;        %Major and Minor axes of ellipses
    MinorAxis = [blobs_stats(i).MinorAxisLength]/2;
    
    
    if blobs_stats(i).Value == 1                    %If the digit is a one then the minor axis should be extended.
        fminor_ellipse = fminor_one;
    else
        fminor_ellipse = fminor;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    if blobs_stats(i).Orientation < 90 || blobs_stats(i).Orientation > -90
        rx = MajorAxis * fmajor;
        ry = MinorAxis * fminor_ellipse;
    else
        rx = MinorAxis * fminor_ellipse;
        ry = MajorAxis * fmajor;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    ang = pi - pi*blobs_stats(i).Orientation/180;        %Angle of ellipse
    
    [u1, v1] = find(ones([image_height, image_width]));      %Indices of the scene -- to be put into the ellipse equation to find regions inside and outside ellipse
    
    
    % Save the Ellipse
    EllipseStorage{i} = reshape(elli(v1,u1,ang, x0, y0, rx, ry), [image_height, image_width]) < 1;

    if plot_flag
    figure(200)                         %Plot just ellipses
    TotImage = TotImage + EllipseStorage{i};
    imshow(TotImage)
    hold on
    end
    
    
    Collide = inf*ones(length(blobs_stats),1);       %Indicates which ellipses this collides with
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

CollideTotal(isinf(CollideTotal)) = 0;         

[n,~]=size(CollideTotal');
CollideTotalNew=CollideTotal'+CollideTotal;
CollideTotalNew(1:n+1:end)=diag(CollideTotal');


%find the graph indicating which digits to be combined
G1 = graph(CollideTotalNew);

%% Filter 

AveHue =  arrayfun(@(k) mean(blobs_stats(k).Hue), 1:numel(blobs_stats))';
HueCond = repmat(AveHue, [1,length(AveHue)]);
HueCondThresh = abs(HueCond - HueCond')<T_H;

blob_heights = [blobs_stats.Height]';
blob_heights = repmat(blob_heights, [1,length(blob_heights)]);
HeightsCondThresh = (abs(blob_heights - blob_heights')/image_height)<T_height;



CollideTotalNew = CollideTotalNew.*HueCondThresh.*HeightsCondThresh;


G = graph(CollideTotalNew);

%How many groups?
componentIndices = conncomp(G);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Contruct the final reading different for blood glucose meter or blood pressure meter (as layout of devices are different)

if strcmp(up.device_type, 'BG')
    reading = contruct_reading_bg(componentIndices, blobs_stats);
    
    
    
     if ~isempty(reading)
        fprintf(sprintf('Estimated Reading Value: %.1f \n', reading))
    end
    
        
elseif strcmp(up.device_type, 'BP')
    reading = contruct_reading_bp(componentIndices, blobs_stats);
    
    
    if reading == 0
        return
    end

    fprintf(sprintf('Estimated Reading Value: \n Systolic Blood Pressure:  %.0f, \n Diastolic Blood Pressure:  %.0f, \n Heart Rate:  %.0f \n', reading(end-2:end)))

    
else
    warning('The device type is unkown - only BG or BP are supported')
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function reading = contruct_reading_bg(componentIndices, blobs_stats)

%First find the order of values from left to right.
Output = [blobs_stats.Value];
Cent = [blobs_stats.Centroid];
x = Cent(1:2:end);

[~,Order] = sort(x);

Output = Output(Order);


%% Filter the possible readings by number of digits in the reading and the expected value of the reading.



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

reading = Group_Table_ValueRemoved(:, 3);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function reading = contruct_reading_bp(componentIndices, blobs_stats)
%First find the order of values from left to right.
Output = [blobs_stats.Value];
Cent = [blobs_stats.Centroid];
x = Cent(1:2:end);

[~,Order] = sort(x);

Output = Output(Order);


%% Filter the possible readings by number of digits in the reading and the expected value of the reading.


%How many digits in each group? Need to delete those that are less than or
%greater than a certain number
Max_digits = 3; Min_digits = 2;


Max_BP_Sys = 210; Min_BP_Sys = 70;
Max_BP_Dia = 130; Min_BP_Dia = 40;
Max_BP_HR = 200; Min_BP_HR = 40;

Max = [Max_BP_Sys; Max_BP_Dia; Max_BP_HR];
Min = [Min_BP_Sys; Min_BP_Dia; Min_BP_HR];


Group_Table = tabulate(componentIndices);       %Group table contains the how many digits are in each group
Group_Table(:,4) = or(Group_Table(:,2) > Max_digits,Group_Table(:,2) < Min_digits);     %Add a column that says if a group has too many or too few digits.


Group_Table(:,3) = [];
Group_Table(find(Group_Table(:,3)), :) = [];

%Add a column with the group reading -- If there arent too many or too few digits

%If there are 3 readings then assign from top to bottom, if there are 4
%readings then see if the top one is the time and if there are more then
%there is error.

TagLabelOrder = componentIndices(Order);
for i = 1:size(Group_Table,1)
    
    label = Group_Table(i,1);
    
    Value = Output(TagLabelOrder == label);
    
    Y_ave = mean(Cent(2*find(componentIndices == label)));
    
    
    Value=num2str(Value);
    Value=Value(Value~=' '); % remove the space
    Group_Table(i,3)=str2double(Value);
    
    Group_Table(i,4) = Y_ave;
    
end

%%%%% Now remove any readings that are out of all possible ranges
Delete = or(Group_Table(:,3) > max(Max),Group_Table(:,3) < min(Min)); 
Group_Table(find(Delete), :) = [];

%How many groups left?
%If there are more than 4 groups or less than 3 then there is an error
if size(Group_Table, 1) > 4
    fprintf('Too many potential readings \n')
    return
elseif size(Group_Table, 1) < 3
    fprintf('Too few potential readings \n')
    return
end


% Need to find the average height of the digits in each group and arrange
% the rows by the height
%Order the rows by the average height of the digits.
[~,Order] = sort(Group_Table(:,4));

Group_Table = Group_Table(Order,:);

%Now we know that the bottom 3 rows are the potential readings -- if there
%are 4 potential readings then the top row should only be due to the clock
%-- this should be flagged for manual checking.

%Now check if the readings are within the correct range. If they are then
%display reading to user.
Group_Table(end-2:end,5) = or(Group_Table(end-2:end,3) > Max,Group_Table(end-2:end,3) < Min);

if any(Group_Table(:,5))
   fprintf('Potential reading is out of range \n');
    return
end
    

%Print the potential reading
reading = Group_Table(:, 3);

end