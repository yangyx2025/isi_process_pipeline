%根据zqy脚本改编 yyx 20250506
%需要多通道isi结果+align图像（要求isi不要更改位置，连续进行多组isi）
%allen 数据来自https://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/
%https://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/
clc, clear
close all
FunAddPath()
%% load ISI images and CCF
rootpath='L:\m0415\isi';
allen_filepath='K:\yyx\script\isi_process\function\allen_atlas';
isi_image_name='isi_rgb.tif';%配准后的isi+align image,(rgb) .tif
%[row_start,row_end,col_statrt,col_end]
allen_frame_range=[86,618,218,1020];%[46,262,118,382];
isi_image=FunLoadISIImage(rootpath,isi_image_name);
cortical_area_edge=FunLoadAllenAtlas(allen_filepath,allen_frame_range);
%% cortical region estimation
AP_manual_align_widefield_ccf(cortical_area_edge,isi_image,rootpath,allen_frame_range);
%% 读取para后将allen转化在wide-field img
% clc
% edge_img=imread('K:\yyx\script\pre_process\function\allen_atlas\cotical_area_edge.tif');
% edge_img_crop=edge_img(allen_frame_range(1):allen_frame_range(2),allen_frame_range(3):allen_frame_range(4));
% moving_img_isi=imwarp(edge_img_crop,affine2d(para.allen2isi_tform),'OutputView',imref2d([1474,1906]));
% imwrite(moving_img_isi,'L:\m0415\isi\test\area.tif');
%% 
function FunAddPath()
    script_full_path=mfilename('fullpath');
    [scriptpath, ~, ~] = fileparts(script_full_path);
    function_folder=fullfile(scriptpath,'function');
    if isfolder(function_folder)
        addpath(genpath(function_folder));
        fprintf('添加到路径: %s\n', function_folder);
    else
        error('未发现function文件夹: %s', helperFolder);
    end
end
function isi_img=FunLoadISIImage(rootpath,isi_img_name)
    isi_file=fullfile(rootpath,isi_img_name);
    if ~isfile(isi_file)
        error('未找到对应isi image')
    end
    isi_img=imread(isi_file);
end
function allen_map=FunLoadAllenAtlas(allen_filepath,allen_frame_range)
    allen_file=fullfile(allen_filepath,'combine_edge_and_barrel.tif');
    if ~isfile(allen_file)
        error('未找到对应Allen 数据')
    end
%     load(allen_file,'atlas');
%     clean_cortex_outline=im2uint8(atlas.clean_cortex_outline);
%     clean_cortex_outline=clean_cortex_outline(allen_frame_range(1):allen_frame_range(2),allen_frame_range(3):allen_frame_range(4));
    allen_map=imread(allen_file);
    allen_map=allen_map(allen_frame_range(1):allen_frame_range(2),allen_frame_range(3):allen_frame_range(4));
end

