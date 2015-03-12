% PROCESS_IMAGE: Run Copy-Move-Detection on a single image.
% 
% INPUTS:
%   imagefile       - image file
%   metric          - [opt] metric used in HAC ('ward','single','centroid')
%   thc             - [opt] threshold used in HAC
%   min_cluster_pts - [opt] min number of points per cluster
%   plotimg         - [opt] show output images
%   siftfile        - [opt] import sift features from siftfile
%
% OUTPUTS:
%   num             - number of geometric transformations
%   inliers1        - coordinates of inliers of the first set
%   inliers2        - coordinates of inliers of the second set
%
% EXAMPLE:
%   process_image('examples/tampered1.jpg', 'ward', 3, 4, 1)
% 
% ---
% Authors: I. Amerini, L. Ballan, G. Serra
% Media Integration and Communication Center
% University of Florence
% May 7, 2012

function [num_gt inliers1 inliers2] = process_image(imagefile, metric, ...
    thc, min_cluster_pts, plotimg, siftfile)

if(~exist('metric','var'))
    metric = 'ward'; % min number of points in a cluster
end

if(~exist('thc','var'))
    thc = 2.2; % min number of points in a cluster
end

if(~exist('min_cluster_pts','var'))
    min_cluster_pts = 3; % min number of points in a cluster
end

if(~exist('plotimg','var'))
    plotimg = 1; % show cluster image
end

if(~exist('siftfile','var'))
    siftfile = 'nofile';
end

image1 = imread(imagefile);
inliers1 = [];
inliers2 = [];

[num p1 p2 tp] = match_features(imagefile, siftfile);

if size(p1,1)==0
    num_gt=0;
else
    
    p=[p1(1:2,:) p2(1:2,:)]';
    
    % Hierarchical Agglomerative Clustering
    distance_p=pdist(p);
    Z = linkage(distance_p,metric);
    c = cluster(Z,'cutoff',thc,'depth',4);

    % show an image depicting clusters and matches
    if (plotimg==1)
        figure;
        imshow(image1);
        hold on
        for i = 1: size(p1,2)
            line([p1(1,i)' p2(1,i)'], [p1(2,i)' p2(2,i)'], 'Color', 'c');
        end
        gscatter(p(:,1),p(:,2),c)
    end

    % given clusters of matched points compute the number of transformations
    num_gt=0;
    
    c_max = max(c);
    if(c_max > 1)
        n_combination_cluster = combntns(1:c_max,2);

        for i=1:1:size(n_combination_cluster,1)
            k=n_combination_cluster(i,1);
            j=n_combination_cluster(i,2);

            z1=[];
            z2=[];
            for r=1:1:size(p1,2)
                if c(r)==k && c(r+size(p1,2))==j
                    z1 = [z1; [p(r,:) 1]];
                    z2 = [z2; [p(r+size(p1,2),:) 1]];
                end
                if c(r)==j && c(r+size(p1,2))==k
                    z1 = [z1; [p(r+size(p1,2),:) 1]];
                    z2 = [z2; [p(r,:) 1]];
                end
            end
            
            %z1 are coordinates of points in the first cluster 
            %z2 are coordinates of points in the second cluster            
            if (size(z1,1) > min_cluster_pts && size(z2,1) > min_cluster_pts)
                % run ransacfithomography for affine homography
                [H, inliers, dx, dy, xc, yc] = ransacfithomography2(z1', z2', 0.05);
                if size(H,1)==0
                    num_gt = num_gt;
                else
                    H = H / H(3,3);
                    num_gt = num_gt+1;
                    inliers1 = [inliers1; [z1(inliers,1) z1(inliers,2)]];
                    inliers2 = [inliers2; [z2(inliers,1) z2(inliers,2)]];
                    %show_inliers(imagefile,z1',z2',inliers);
                end
            end
        end  
    end
end

% tampering detection
if(num_gt)
    fprintf('Tampering detected!\n\n');
else
    fprintf('Image not tampered.\n\n');
end

end
