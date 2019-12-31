%Apply adaptive histogram equalisation to the retinex image
image_ahe = adapthisteq(image_retinex, 'NumTiles', [8 8]);

%Display results
figure
multi = cat(2, image_retinex, image_ahe);
montage(multi)
title('Applying AHE')