regions_combined = regions_MSER; %Assign the new regions to be the same type as the regions located by MSER

%Concatenate the regions by MSER and CC of binary image (Only need to
%combine the PixelList field and the other fields are combined
%automatically)
regions_combined.PixelList = [regions_MSER.PixelList; regions_binary.PixelList];

%Combine the stats of the regions
regionstats_combined = [regionstats_MSER; regionstats_binary];