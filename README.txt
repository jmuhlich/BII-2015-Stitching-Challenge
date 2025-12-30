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
