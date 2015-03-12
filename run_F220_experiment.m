% RUN EXPERIMENT

tstart = tic;

% dataset
DB = 'MICC-F220';
db_dir ='dataset';
file_ground_truth = 'groundtruthDB_220.txt';

% parameters
metric = 'ward';
th = 2.2;
min_pts = 4;
 
% load ground truth from a file
[ImageName, GT] = textread(fullfile(db_dir,DB,file_ground_truth), '%s %d');
num_images = size(ImageName,1);
fid_gt = fopen(fullfile(db_dir,DB,file_ground_truth));
C = textscan(fid_gt, '%s %u');
fclose(fid_gt);

TP = 0;   % True Positive
TN = 0;   % True Negative
FP = 0;   % False Positive
FN = 0;   % False Negative

for i = 1:num_images
%parfor i = 1:num_images   % use for parallel computation (needs matlabpool)
    
    loc_file = fullfile(db_dir,DB,cell2mat(ImageName(i)));
    name = cell2mat(ImageName(i)); 
                
    % process an image
    fprintf('Processing: %s (%d/%d)\n',loc_file,i,num_images);
    countTrasfGeom = process_image(loc_file, metric, th, min_pts, 0);
                
    % tampering detection
    dim_v=size(C{1,1});
    for l=1:dim_v(1,1)
        if isequal(C{1,1}{l},ImageName{i})
            index=l;
        end
    end
    if countTrasfGeom>=1
        if C{1,2}(index)
            TP = TP+1;
        else
            FP = FP+1;
        end 
    else
        if C{1,2}(index)
            FN = FN+1;
        else
            TN = TN+1;
        end
    end

end

% compute performance             
FPR  = FP/(FP+TN);
TPR  = TP/(TP+FN);
fprintf('\nCopy-Move Forgery Detection performance:\n');
fprintf('\nTPR = %1.2f%%\nFPR = %1.2f%%\n', TPR*100, FPR*100);

% compute computational time
tproc = toc(tstart);
tps = datestr(datenum(0,0,0,0,0,tproc),'HH:MM:SS');
fprintf('\nComputational time: %s\n', tps);
