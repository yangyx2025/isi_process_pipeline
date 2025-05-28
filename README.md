# isi_process_pipeline
1，isi_process01:从获取的isi图像得到差分结果。
  注意：（1）注意接口位置不要变动，代码识别通道名称确定数据的物理意义
      （2）isi过程中尽可能不要动小鼠位置
2，isi_process02：将isi图像配准到用于提取神经元的图像上
注意：（1）将多个isi结果与align图像合成一个多颜色通道图片用于脚本输入
3，isi_process03:根据isi与allen配准，
注意：根据血管，将单根胡须刺激结果标记在isi_process02的结果中
