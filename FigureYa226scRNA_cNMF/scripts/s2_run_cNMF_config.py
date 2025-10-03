# coding: utf-8

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt



# ## 0. configs

out_dir = "tmp/step2"
cNMF_dir = "../cNMF" ## cNMF程序的路径

# # 0.1. 输入文件
# row=cells,  col=genes
tsv_file = "../input/GSE154989_mmLungPlate_fQC_dSp_normTPM.tsv" 

# 这里转换为npz格式，加快读写速度
npz_file = tsv_file.replace(".tsv", ".npz")

## 输入文件1, rawCounts矩阵 [注]如果是smart-seq2，最好输入TPM矩阵，如果是10X，rawCounts矩阵即可
count_fn = npz_file
## 输入文件2, TPM矩阵(optional)
tpm_fn = npz_file
# tpm_fn = None # 如果没有TPM矩阵可以填为None [注]对于10X数据，填为None

## 输入文件3, 高可变基因，每行一个基因
genes_file = "../input/GSE154989_mmLungPlate.feathers.txt" # (可选) [注] 推荐使用降维&聚类得到的高可变基因集
## 如何不提供这个文件，cNMF会在prepare这一步自动计算, 此时需要指定基因数量
# num_hvgenes = 2000 ## high variance genes的数量

# # 0.2. 输出文件
output_dir = "tmp/step2" ## 输出路径
run_name = "20210225" ## 输出文件名前缀(我这里以日期命名)

# # 0.3. 参数
num_iter = 50 ## NMF分解迭代次数
K = " ".join(str(i) for i in range(10, 30+1, 2)) ## component的数量: "10, 12, 14, ..., 30" [注] 必须是一个字符串
seed = 11 ## 随机数种子，用于NMF初始化
num_workers = 20 ## 并行计算的CPU数目(Factorize step)
