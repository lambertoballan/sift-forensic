% SHOW_INLIERS: Given an image a two sets of points, the function shows 
%               only the inliers.

function show_inliers(imagefile, zz1, zz2, inliers)

image1 = imread(imagefile);
figure;
imshow(image1);
 
for i=1:1:size(inliers,2)
    line([zz1(1,inliers(1,i)) zz2(1,inliers(1,i))], ...
          [zz1(2,inliers(1,i)) zz2(2,inliers(1,i))], 'Color', 'g');
end

end

