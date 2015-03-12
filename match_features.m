% MATCH_FEATURES: Match SIFT features in a single image using our multiple
%                 match strategy.
% 
% INPUTS:
%   filename        - image filename (if features have to be computed) or
%                     descriptors filename in the other case
%   filesift        - [opt] file containing sift descriptors
%
% OUTPUTS:
%   num             - number of matches
%   p1,p2           - coordinates of pair of matches
%   tp              - computational time    
%
% EXAMPLES:
%   e.g. extract features and matches from a '.jpg' image:
%   [num p1 p2 tp] = match_features('examples/tampered1.jpg')
%
%   e.g. import features and matches from a '.sift' descriptors file:
%   [num p1 p2 tp] = match_features('examples/tampered2.sift',0)                      
% 
% ---
% Authors: I. Amerini, L. Ballan, L. Del Tongo, G. Serra
% Media Integration and Communication Center
% University of Florence
% May 7, 2012

function [num p1 p2 tp] = match_features(filename, filesift)

% thresholds used for g2NN test
dr2 = 0.5;

extract_feat = 1; % by default extract SIFT features using Hess' code

if(exist('filesift','var') && ~strcmp(filesift,'nofile'))
    extract_feat = 0; 
end

tic; % to calculate proc time

if extract_feat
    sift_bin = fullfile('lib','sift','bin','siftfeat');   % e.g. 'lib/sift/bin/siftfeat' in linux
    [pf,nf,ef] = fileparts(filename);
    desc_file = [fullfile(pf,nf) '.txt'];
    
    im1=imread(filename);
    if (size(im1,1)<=1000 && size(im1,2)<=1000)
        status1 = system([sift_bin ' -x -o ' desc_file ' ' filename]);
    else
        status1 = system([sift_bin ' -d -x -o ' desc_file ' ' filename]);
    end

    if status1 ~=0 
        error('error calling executables');
    end

    % import sift descriptors
    [num, locs, descs] = import_sift(desc_file);
    system(['rm ' desc_file]);
else
    % import sift descriptors
    [num, locs, descs] = import_sift(filesift);
end

if (num==0)
    p1=[];
    p2=[];
    tp=[];
else
    p1=[];
    p2=[];
    num=0;
    
    % load data
    loc1 = locs(:,1:2);
    %scale1 = locs(:,3);
    %ori1 = locs(:,4);
    des1 = descs;
    
    % descriptor are normalized with norm-2
    if (size(des1,1)<15000)
        des1 = des1./repmat(sqrt(diag(des1*des1')),1,size(des1,2));
    else
        des1_norm = des1; 
        for j= 1 : size(des1,2)
            des1_j = des1_norm(j,:);
            des1_norm(j,:) = des1_j/norm(des1_j,2); 
        end
        des1 = des1_norm;
    end
    
    % sift matching
    des2t = des1';   % precompute matrix transpose
    if size(des1,1) > 1 % start the matching procedure iff there are at least 2 points
        for i = 1 : size(des1,1)
            dotprods = des1(i,:) * des2t;        % Computes vector of dot products
            [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

            j=2;
            while vals(j)<dr2* vals(j+1) 
                j=j+1;
            end
            for k = 2 : j-1
                match(i) = indx(k); 
                if pdist([loc1(i,1) loc1(i,2); loc1(match(i),1) loc1(match(i),2)]) >10  
                    p1 = [p1 [loc1(i,2); loc1(i,1); 1]];
                    p2 = [p2 [loc1(match(i),2); loc1(match(i),1); 1]];
                    num=num+1;
                end
            end
        end
    end
    
    tp = toc; % processing time (features + matching)
    
    if size(p1,1)==0
        fprintf('Found %d matches.\n', num);
    else
        p=[p1(1:2,:)' p2(1:2,:)'];
        p=unique(p,'rows');
        p1=[p(:,1:2)'; ones(1,size(p,1))];
        p2=[p(:,3:4)'; ones(1,size(p,1))];
        num=size(p1,2);
        fprintf('Found %d matches.\n', num);
    end
   
end
