% TAMPERING_LOCALIZATION: The function localize a copy-move tampering and 
%   returns the corresponding binary mask..
% 
% INPUTS:
%   filename        - image file name
%   A               - homography matrix
%   z1,z2           - coordinates of pair of matches between two clusters
%   inliers         - inliers for the geometric transformation A
%   th_bin_mask     - [opt] threshold used to compute the binary mask
%   show_mask       - [opt] show the binary mask
%
% OUTPUTS:
%   img_out         - binary mask
%
% EXAMPLE:
%   iout = tampering_localization(filename, A, z1, z2, inliers)
% 
% ---
% Authors: L. Ballan, G. Serra
% Media Integration and Communication Center
% University of Florence
% May 8, 2012

function img_out = tampering_localization(filename, A, z1, z2, inliers,...
    th_bin_mask, show_mask)
    
    if(~exist('th_bin_mask','var'))
        th_bin_mask = 0.3;
    end
    
    if(~exist('show_mask','var'))
        show_mask = 0;
    end
    
	im=imread(filename);
	tform = maketform('affine', A');
	imT = imtransform(im,tform, 'XData',[0 size(im,2)-1], 'YData',[0 size(im,1)-1]);	
    %figure, imshow(imT)

	[dispMap t]=fastZNCC(im, imT, 7);
	%figure; imshow(dispMap);
            
	dispMap(isnan(dispMap))=0;
	dispMap(dispMap<0)=0;
 	dispMapG = gray2ind(dispMap, 256);
	G = fspecial('gaussian',[7 7],0.5);
 	
	% filtering image
 	dispMapG = imfilter(dispMapG,G,'same');
    
    % fill holes
 	bw = im2bw(dispMapG,th_bin_mask);
 	bw = imfill(bw,'holes');
 	%hold on; imshow(bw);

    % discard regions not containing any sift match
 	bound = bwboundaries(bw);
 	inModel_x = [ z1(1,inliers) z2(1,inliers)]';
 	inModel_y = [ z1(2,inliers) z2(2,inliers)]';
    
    img_out = false(size(im,1),size(im,2));    
    for k=1:size(bound,1)
		b= bound{k};
        in = inpolygon(inModel_x,inModel_y,b(:,2),b(:,1));
        if ~isempty(find(in,1))
            bw_b =false(size(im,1),size(im,2)); 
            bw_b = roipoly(bw_b,b(:,2),b(:,1));
            img_out = img_out | bw_b;
        end
    end
    
    % show localization binary mask
    if show_mask
        figure; imshow(img_out);
    end
    
end