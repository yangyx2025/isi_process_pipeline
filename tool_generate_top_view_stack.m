%yyx 20250507
%读取allen模板文件生成带有barrel的tif stack
%然后用fiji生成max proj
%nrrd下载自https://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/

clear;
FunAddPath()
nrrd_path='K:\yyx\script\isi_process\function\allen_atlas';
nrrd_name='average_template_10.nrrd';
allen_atlas=FunLoadNrrd(nrrd_path,nrrd_name);
%% 
allen_altas_horizontal=FunTran2Horizontal(allen_atlas);%将矩阵方向转为俯视图
FunWriteStack(allen_altas_horizontal,nrrd_path,'allen_hori_template.tif');%将俯视图存储为stack

%% 
function FunWriteStack(allen_altas_horizontal,nrrd_path,stack_name)
    stack_file=fullfile(nrrd_path,stack_name);
    writeTifFast(stack_file,allen_altas_horizontal,16);
end
function allen_altas_horizontal=FunTran2Horizontal(allen_atlas)
    %将图像转为水平方向
    allen_altas_horizontal=permute(allen_atlas,[3,2,1]);
end
function allen_atlas=FunLoadNrrd(nrrd_path,nrrd_name)
    nrrd_file=fullfile(nrrd_path,nrrd_name);
    if ~isfile(nrrd_file)
        error('未找到nrrd文件')
    end
    [allen_atlas, ~] = nrrdread(nrrd_file);
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