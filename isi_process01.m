%yyx 20250416
%处理isi结果，得到差值图像，要求event事件中存在完整胡须刺激事件
%yyx 20250417 增加平均图像差值计算start-sti
%yyx 20250418 去掉event部分，以后只需要成像开始后给胡须刺激
%yyx 20250421 彻底去掉event,增加waitbar
clearvars -except data_converted
clc;
close all;
FunAddPath()
disp('=== ISI图像处理ing ===');
%% 修改参数

imagepath='M:\m0728\isi\20240929_m0728\01\image';
tdms_filepath='M:\m0728\isi\20240929_m0728\01\syc';
tdms_filename='01_conv.tdms';

voltage_th=2.5;%电压阈值
%% 文件系统预处理
savepath=fullfile(imagepath,'res');
mkdir(savepath);
savename=FunCreatSavename(savepath);
%% 数据读取与校验
% 读取tdms文件
syc_data=FunLoadTDMS(tdms_filepath,tdms_filename);
%读取image
info=FunLoadImage(imagepath);
%%宽场成像时间点提取
cam_event=FunGetEventTransitionPoint(syc_data.image,'up',voltage_th);
%胡须刺激时间点提取
wh_event=FunGetEventTransitionPoint(syc_data.wh,'up&down',voltage_th);
%校验数据
FunCheckData(wh_event,cam_event,info);%检查可能存在的问题
disp('检查是否存在问题，无问题可继续运行');
keyboard
%% 根据数据同步和任务结构进行图像归类
sti_timepoint_matrix=FunGetStiTimepointMatrix(wh_event);%建立事件时间矩阵
info_start=FunGetValidImageInfo(sti_timepoint_matrix(:,[1,2]),info,cam_event);
info_sti=FunGetValidImageInfo(sti_timepoint_matrix(:,[2,3]),info,cam_event);
info_end=FunGetValidImageInfo(sti_timepoint_matrix(:,[3,4]),info,cam_event);
%% 计算均值
avr_start=FunGetAvrImg(info_start,savename{1});
avr_sti=FunGetAvrImg(info_sti,savename{2});
avr_end=FunGetAvrImg(info_end,savename{3});

%% 计算均值差
delta_start_sti=FunGetDeltaImg(avr_start,avr_sti,savepath);



%%
function FunAddPath()
    script_full_path=mfilename('fullpath');
    [scriptpath, ~, ~] = fileparts(script_full_path);
    function_folder=fullfile(scriptpath,'function');
    if isfolder(function_folder)
        addpath(genpath(function_folder));
        fprintf('Added folder to path: %s\n', function_folder);
    else
        error('未发现function文件夹: %s', helperFolder);
    end
end
function savename = FunCreatSavename(savepath)
    % 定义文件名前缀
    basenames = {'isi-start', 'isi-sti', 'isi-end'};
    savename = cell(numel(basenames), 1);
    % 生成统一的时间戳字符串（格式为 yyyy-MM-dd-HH-mm）
    timestampstr = datestr(now, 'yyyy-mm-dd-HH-MM');
    % 遍历每个前缀，并生成完整的文件名
    for i = 1:numel(basenames)
        % 构建文件名，如: 'isi_start_2025-04-16-16-30.tif'
        filename = sprintf('%s-%s.tif', basenames{i}, timestampstr);
        % 生成完整路径
        savename{i} = fullfile(savepath, filename);
    end
end
function res_info=FunGetValidImageInfo(event_time,info,cam_event)
    res_info=struct([]);
    for i=1:size(event_time,1)
        idx = (cam_event > event_time(i, 1)) & (cam_event < event_time(i, 2));
        if any(idx)
            res_info = [res_info; info(idx)];
        end
    end
    if isempty(res_info)
        disp('未发现合适图像')
        keyboard
    else
        fprintf('检查到%d个待处理图像文件\n',length(res_info));
    end
end
function sti_timepoint_matrix=FunGetStiTimepointMatrix(wh_event)
    trial_num=length(wh_event)/4;
    fprintf('检查到%d个trial\n',trial_num);
    sti_edge_timepoint_matrix=reshape(wh_event,4,trial_num)';
    sti_timepoint_matrix=nan(trial_num-1,4);
    for i=1:size(sti_edge_timepoint_matrix,1)-1%去掉最后一个trial防止不完整
        sti_timepoint_matrix(i,1)=sti_edge_timepoint_matrix(i,1);
        sti_timepoint_matrix(i,2)=sti_edge_timepoint_matrix(i,3);
        sti_timepoint_matrix(i,3)=sti_edge_timepoint_matrix(i,4);
        sti_timepoint_matrix(i,4)=sti_edge_timepoint_matrix(i+1,1)-1;
    end
end
function syc_data=FunLoadTDMS(tdms_filepath,tdms_filename)
    tdms_file=fullfile(tdms_filepath,tdms_filename);
    syc_data=struct();
    if ~isfile(tdms_file)
        error('路径中未发现tdms文件');
    end
    try
        [data_converted,~,~,~]=convertTDMS(true,tdms_file);
    catch
        error('无法读取tdms文件')
    end
    for i=3:size(data_converted.Data.MeasuredData,2)
        channel_name=data_converted.Data.MeasuredData(i).Name;
        channelid = regexp(channel_name, 'ai\d+', 'match');
        channelid=channelid{1};
        switch channelid
            case 'ai1'%wide field image
                syc_data.image=data_converted.Data.MeasuredData(i).Data;
            case 'ai3'%whisker
                syc_data.wh=data_converted.Data.MeasuredData(i).Data;
            otherwise
                continue
        end
    end
end

function FunCheckData(wh_event,cam_event,info)
     if mod(numel(wh_event),4) ~= 0
         disp('胡须刺激事件并非4的倍数');
     end
     fprintf('检查到%d个帧数差异\n',abs(length(cam_event)-length(info)))
end
function info=FunLoadImage(imagepath)
    info=dir([imagepath,'\*.tif']);
    if isempty(info)
        error('路径中未找到任何TIF图像文件');
    end
    info=natsortfiles(info);
end

function res_image=FunGetAvrImg(info,savename)
    %拆分savename，只保留文件名
    [~,name,ext] = fileparts(savename); 
    str=strcat(name,ext);

    img_temp=imread(fullfile(info(1).folder,info(1).name));
    img=zeros(size(img_temp));
    img_num=length(info);
    % 创建进度条
    h_wait = waitbar(0, sprintf('%s，处理进度: 0%%', str));
    for i=1:img_num
        filename=fullfile(info(i).folder,info(i).name);
        image_buff=imread(filename);
        img=img+double(image_buff);
        %waitbar
        progress = i/img_num;
        waitbar(progress, h_wait, sprintf('%s，处理进度: %d%%', str, round(progress*100)));
    end
    close(h_wait);
    res_image=img./img_num;
    imwrite(uint16(res_image),savename);
end
function delta_start_sti=FunGetDeltaImg(avr_start,avr_sti,savepath)
    delta_start_sti=avr_start-avr_sti;
    savefull=fullfile(savepath,'delta_start_sti.tif');
    imwrite(uint16(delta_start_sti),savefull);
end
