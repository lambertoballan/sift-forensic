# sift-forensic
Copy-move forgery detection using SIFT features (Amerini et al, TIFS 2011).

This code was developed by I. Amerini, L. Ballan, G. Serra at the Media Integration and Communication Center (MICC), University of Florence (Italy). This package is equivalent to the initial release available on the MICC webpage (May 8, 2012 - version 1.0).

If you use this code please cite the paper:
**A SIFT-based forensic method for copy-move attack detection and transformation recovery**, I. Amerini, L. Ballan, R. Caldelli, A. Del Bimbo, and G. Serra, IEEE Trans. on Information Forensics and Security, vol. 6, iss. 3, pp. 1099-1110, 2011.


##Introduction
This package contains the Matlab implementation of the copy-move detection approach presented in Amerini et al., TIFS 2011. Our code use several public functions and libraries developed by other authors; regarding these files, for any problem or license information, please refer to the respective authors.
In particular, SIFT features are extracted using the Rob Hess library (this package is now available on Github: http://robwhess.github.io/opensift/). Anyway, the code works also loading features extraced with other implementations (such as the original code by David Lowe or VLFeat).


##Main functions

process_image(imagefile, metric, thc, min_cluster_pts, plotimg, extractsift)

The function runs Copy-Move-Detection on a single image. For example run from the Matlab prompt:
>> process_image('examples/tampered1.jpg', 'ward', 3, 4, 1)

You can also import a file containing sift descriptors if you have pre-computed features:
>> process_image('examples/tampered2.jpg', 'ward', 3, 4, 1, 'examples/tampered2.sift')

- run_F220_experiment and run_F2000_experiment

These two scripts can be used to replicate the experiments reported in our paper; you have only to download these two datasets and unzip them into the 'dataset' directory. You can find this data at the URL:
http://www.lambertoballan.net/research/image-forensics/

Please note that you will probably obtain very similar (but not the same) results with respect to those reported in our paper since, in that case, we applied a 4-fold cross validation procedure that is not implemented in these scripts. The expected results are reported in a text file in the dataset directory.


##Datasets
The datasets used in our paper are publicly available and can be dowloaded from the MICC website:
- MICC-F220: this dataset is composed by 220 images; 110 are tampered and 110 originals (http://www.micc.unifi.it/downloads/MICC-F220.zip).
- MICC-F2000: this dataset is composed by 2000 images; 700 are tampered and 1300 originals (http://www.micc.unifi.it/downloads/MICC-F2000.zip).

You only need to download them and unzip the files in the "sift-forensic/dataset" directory.


##Contact
Irene Amerini (irene.amerini@unifi.it), Lamberto Ballan (lamberto.ballan@unifi.it) and Giuseppe Serra (giuseppe.serra@unimore.it)
