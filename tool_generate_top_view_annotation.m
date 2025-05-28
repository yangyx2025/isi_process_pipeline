%yyx 20250507
%对allen annotation文件生成top view视角文件,并写为tif
%nrrd文件下载自https://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2022/
clear;clc;
FunAddPath();
nrrd_path='K:\yyx\script\isi_process\function\allen_atlas';
nrrd_name='annotation_10.nrrd';
allen_annotation=FunLoadNrrd(nrrd_path,nrrd_name);
allen_annotation_top=FunGetTopView(allen_annotation);%获取最上方id
FunWriteTopViewTif(allen_annotation_top,nrrd_path);%将得到的图像写入源文件路径
%% 获取边缘信息
edgemask = boundarymask(allen_annotation_top);%
%% 展示图像
FunShowAnnotation(edgemask,allen_annotation_top);%展示annotation,计算时间较长<5min
%% 存储图像
FunWriteEdegeTif(edgemask,nrrd_path);

%% 
function FunWriteEdegeTif(edgemask,nrrd_path)
    tif_file=fullfile(nrrd_path,'cotical_area_edge.tif');
    imwrite(im2uint16(edgemask),tif_file);
    fprintf('已写入到%s\n',tif_file);
end
function FunShowAnnotation(edgemask,allen_annotation_top)
    %展示annotation
    RGB = label2rgb(allen_annotation_top, 'jet', 'k', 'shuffle');%'shuffle'指随机赋色
    figure; imshow(RGB); hold on;
    h = imshow(edgemask);
    set(h, 'AlphaData', 0.5);  % 半透明叠加
end
function FunWriteTopViewTif(allen_annotation_top,nrrd_path)
    tif_file=fullfile(nrrd_path,'allen_top_annoation.tif');
    writeTifFast(tif_file,allen_annotation_top,32);
    fprintf('已写入到%s\n',tif_file);
end
function allen_annotation_top=FunGetTopView(allen_annotation)
    %依次绘制top view 首次观察到的像素及对应allen annotation
    [m, n, z] = size(allen_annotation);
    allen_annotation_top   = zeros(m, n, 'like', allen_annotation);
    assigned  = false(m, n);   % 标记哪些 (i,j) 已经找到过 >0
    for k = 1:z
        slice = allen_annotation(:,:,k);
        % 找到本层第1次出现>0 且尚未赋值的位置
        newMask = (slice > 1) & ~assigned;
        % 赋值并标记
        allen_annotation_top(newMask)  = slice(newMask);
        assigned(newMask) = true;

        % 如果所有位置都已被赋值，就可以提早退出
        if all(assigned, 'all')
            break;
        end
    end
end
function allen_atlas=FunLoadNrrd(nrrd_path,nrrd_name)
    nrrd_file=fullfile(nrrd_path,nrrd_name);
    if ~isfile(nrrd_file)
        error('未找到nrrd文件')
    end
    [allen_atlas, ~] = nrrdread(nrrd_file);%读取文件
    %转为top view
    allen_atlas=permute(allen_atlas,[3,2,1]);

end
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