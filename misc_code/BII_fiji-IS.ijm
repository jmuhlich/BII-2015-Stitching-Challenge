levels = newArray("Level_1","Level_2","Level_3");
fns = newArray("img_Phase_r{yyy}_c{xxx}.tif","img_Cy5_r{yyy}_c{xxx}.tif","img_Cy5_r{yyy}_c{xxx}.tif");
xs = newArray(10,10,23);
ys = newArray(10,10,24);




reg_thres = 0.3;
max_avg = 2.5;
abs_disp = 3.5;


for(i = 0; i <= 2; i++) {
	level = levels[i];
	fp = "C:\\majurski\\image-data\\BII_Stitching_Challenge\\" + level + "\\Input_Image_Tiles\\";
	lev_tgt_fp = "C:\\majurski\\image-data\\BII_Stitching_Challenge\\" + level + "\\Image_Tiles_Global_Positions\\";
	fn = fns[i];
	x = xs[i];
	y = ys[i];


	startTime = getTime();
	run("Grid/Collection stitching", "type=[Filename defined position] order=[Defined by filename         ] grid_size_x=&x grid_size_y=&y tile_overlap=10 first_file_index_x=1 first_file_index_y=1 directory=&fp file_names=&fn output_textfile_name=TileConfiguration.txt fusion_method=[Do not fuse images (only write TileConfiguration)] regression_threshold=&reg_thres max/avg_displacement_threshold=&max_avg absolute_displacement_threshold=&abs_disp compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk]");

	elapsedTime = (getTime() - startTime)/1000; // runtime in seconds
	File.append(level + ": " + d2s(elapsedTime,8), lev_tgt_fp + "fiji-runtime.txt");
	File.copy(fp + "TileConfiguration.registered.txt", lev_tgt_fp + "TileConfiguration.registered.txt");

}
