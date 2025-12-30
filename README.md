This code performs a quantitative analysis of microscope image stitching
accuracy using reference ground truth datasets (available separately, see links
below). It was originally used for an image stitching challenge associated with
a conference hosted by NIST, and also for evaluating stitching algorithms in the
paper describing the MIST stitching tool:

> Chalfoun et al. MIST: Accurate and Scalable Microscopy Image Stitching Tool
> with Stage Modeling and Error Minimization. Sci Rep 7, 4988
> (2017). https://doi.org/10.1038/s41598-017-04567-y

NIST hosts a few datasets relevant to this code:

* https://isg.nist.gov/deepzoomweb/data/referenceimagestitchingdata

  Reference image stitching data with accompanying ground truth, suitable for
  use as input to this evaluation code. You will need to reorganize the folders
  a bit to match the input format for this code (see folder structure
  documentation below) and of course provide CSV-formatted corrected tile
  coordinates from each stitching tool you wish to evaluate.

* https://isg.nist.gov/BII_2015/webPages/pages/stitching/Stitching.html

  BII 2015 image stitching challenge page, with input raw tiles but without the
  reference ground truth.  This link is provided for reference, but it is not of
  much use without the ground truth colony images and their centroid
  coordinates.

This version of the code has been modified slightly to run in Octave as well as
MATLAB. It has also been adjusted in a few places to work with NIST's reference
image stitching dataset (the first dataset link above) instead of the BII 2015
challenge images, in an attempt to reproduce the accuracy results presented in
Chalfoun et al.

The code was originally written by NIST employees Joe Chalfoun, Michael
Majurski, and others. Thanks to Joe Chalfoun for sharing the code.

See below for the original README.

-----

```
The MATLAB script: "script_run_stitching_challenge.m" will generate BII 2015
Stitching Challenge results given a filepath to where the data resides on disk.

In the script you need to modify the variable "filepath" to point to where you
have your stitching challenge data.

The folder "filepath" points to should have the following folder structure:
Level_1
        Stitched_Images
        Reference_Colony_Images
        Input_Image_Tiles
        Image_Tiles_Global_Positions
        Evaluation_Results
Level_2
        Stitched_Images
        Reference_Colony_Images
        Input_Image_Tiles
        Image_Tiles_Global_Positions
        Evaluation_Results
Level_3
        Stitched_Images
        Reference_Colony_Images
        Input_Image_Tiles
        Image_Tiles_Global_Positions
        Evaluation_Results

The folder "Reference_Colony_Images" should contain the reference colony images
used to perform the evaluation.

The folder "Input_Image_Tiles" should contain the image tiles that were used in
the stitching challenge level.

The folder "Image_Tiles_Global_Positions" should contain the resulting global
image tile positions csv files. The files should all be "<Technique_Name>.csv".

If the folders "Stitched_Images" or "Evaluation_Results" do not exist, the
script will create them.

The script will take each global positions csv file and generate a stitched
image using the stitching challenge image tiles within "Input_Image_Tiles"
saving the resulting image in "Stitched_Images". It will then segment the
stitched image and save that in "Evaluation_Results". It will then compute the
stitching evaluation and save the results in "Evaluation_Results" as
"<Technique_Name>.mat". In addition, a heatmap of the distance errors will be
generated and saved into "Evaluation_Results".
```
