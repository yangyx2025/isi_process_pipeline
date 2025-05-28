%将isi图像与宽场成像配准
clear;clc
rootpath='L:\m0415\isi';%将多张所需图片放于一个文件夹
isi_align_name='Image00002.tif';%
%合并isi结果，要求ISI时尽量不要调整位置（单根胡须刺激和区域刺激可以独立做）
isi_res_name='Composite (RGB).tif';%这幅图片来自于isi结果和align图像的合并
cal_img_path='L:\m0415\isi';%crop或者align之后的cal_image
cal_img_name='crop_m04151_00001.tif';
img_left_imshow_factor=5;
img_right_imshow_factor=5;
%% 读取图片
[img_isi,img_isi_align,img_cal]=FunLoadImg(rootpath, ...
    isi_align_name,isi_res_name,cal_img_name);
%% 配准isi与align图像
[para,para_logical]=FunCheckParaFile(rootpath);
if para_logical
    movingPoints=para.movingPoints;
    fixedPoints=para.fixedPoints;
    cpselect(img_isi_align.*img_left_imshow_factor,img_cal.*img_right_imshow_factor,movingPoints,fixedPoints);
else
    cpselect(img_isi_align.*img_left_imshow_factor,img_cal.*img_right_imshow_factor);
end
disp('导出点对后继续');
keyboard
%% 进行仿射变换并存储
tform = fitgeotrans(movingPoints,fixedPoints,'affine');
FunSavePara(movingPoints,fixedPoints,tform,rootpath)
%% 变换图片并存储
[moving_img_isi,moving_img_isi_align]=FunTransImg(img_isi,img_isi_align,tform,img_cal);
FunSaveImg(moving_img_isi,moving_img_isi_align,rootpath)
%% 
function FunSaveImg(moving_img_isi,moving_img_isi_align,rootpath)
    imwrite(moving_img_isi,fullfile(rootpath,'isi_rgb.tif'));
    imwrite(moving_img_isi_align,fullfile(rootpath,'isi_align.tif'));
end
function [moving_img_isi,moving_img_isi_align]=FunTransImg( ...
    img_isi,img_isi_align,tform,img_cal)
    %对图像进行仿射变换
    moving_img_isi=imwarp(img_isi,tform,'OutputView',imref2d(size(img_cal)));
    moving_img_isi_align=imwarp(img_isi_align,tform,'OutputView',imref2d(size(img_cal)));
end
function FunSavePara(movingPoints,fixedPoints,tform,rootpath)
    %存储para文件
    para.movingPoints=movingPoints;
    para.fixedPoints=fixedPoints;
    para.tform=tform;
    save(fullfile(rootpath,'para.mat'),'para');
end
function [para,para_logical]=FunCheckParaFile(rootpath)
    %检查路径下是否存在para文件
    para_file=fullfile(rootpath,'para.mat');
    if isfile(para_file)
        para_logical=1;
        load(para_file,'para')
    else
        para_logical=0;
        para=struct();
    end
end
function [img_isi,img_isi_align,img_cal]=FunLoadImg(rootpath, ...
    isi_align_name,isi_res_name,cal_img_name)
    %读取合并后的isi结果（rgb）
    img_isi_file=fullfile(rootpath,isi_res_name);
    if ~isfile(img_isi_file)
        error('未发现isi结果图像')
    end
    img_isi=imread(img_isi_file);
    %读取isi结果伴随的align图像
    img_isi_align_file=fullfile(rootpath,isi_align_name);
    if ~isfile(img_isi_align_file)
        error('未发现isi伴随的align图像')
    end
    img_isi_align=imread(img_isi_align_file);
    %读取钙成像 align或crop的图像
    img_cal_file=fullfile(rootpath,cal_img_name);
    if ~isfile(img_cal_file)
        error('未发现isi结果图像')
    end
    img_cal=imread(img_cal_file);
end


