% IMPORT_SIFT: Import SIFT keypoints from a text file (D. Lowe format) 
% 
% INPUTS:
%   filename        - image text file path (in Lowe format)
%
% OUTPUTS:
%   num             - number keypoints
%   locs            - coordinates (i.e. row,cols)
%   descs           - SIFT descriptors
%
% EXAMPLE:
%   [num locs descs] = import_sift('siftfeat.txt')
% 
% ---
% Authors: I. Amerini, L. Ballan, G. Serra
% Media Integration and Communication Center
% University of Florence
% May 7, 2012

function [num locs descs] = import_sift(filename)

% Open tmp.txt and check its header
g = fopen(filename, 'r');
if g == -1
    %error('Could not open sift file.');
    warning('Could not open sift file.');
    num = 0;
    locs = [];
    descs = [];
else
    [header, count] = fscanf(g, '%d %d', [1 2]);
    if count ~= 2
        error('Invalid keypoint file beginning.');
    end
    num = header(1);
    len = header(2);
    if len ~= 128
        error('Keypoint descriptor length invalid (should be 128).');
    end

    % Creates the two output matrices (use known size for efficiency)
    locs = double(zeros(num, 4));
    descs = double(zeros(num, 128));

    % Parse tmp.key
    for i = 1:num
        [vector, count] = fscanf(g, '%f %f %f %f', [1 4]); %row col scale ori
        if count ~= 4
            error('Invalid keypoint file format');
        end
        locs(i, :) = vector(1, :);

        [descrip, count] = fscanf(g, '%d', [1 len]);
        if (count ~= 128)
            error('Invalid keypoint file value.');
        end
        % Normalize each input vector to unit length
        %descrip = descrip / sqrt(sum(descrip.^2));
        descs(i, :) = descrip(1, :);
    end
    fclose(g);    
end

end

