# coding: utf-8

from s2_run_cNMF_config import *

# ## 1. prepare Input

# 这里将tsv格式转换为npz格式，加快文件读写效率

def save_df_to_npz(obj, filename):
    np.savez_compressed(filename, data=obj.values, index=obj.index.values, columns=obj.columns.values)
    
if not os.path.exists(npz_file):
    tpm = pd.read_csv(tsv_file, sep='\t', index_col=0)
    save_df_to_npz(tpm, npz_file)


# ## 2. run cNMF

# In[4]:

if not os.path.exists(out_dir):  os.makedirs(out_dir)

# ## 2.1 prepare
# 预处理：
# 1. 选择高可变基因(我们这里选择了2000个高可变基因)
# 2. 对矩阵按照基因进行variance scale

prepare_cmd = 'python %s/cnmf.py prepare --output-dir %s --name %s -c %s --tpm %s -k %s --n-iter %d --total-workers %d --seed %d --genes-file %s --beta-loss frobenius' % (cNMF_dir, output_dir, run_name, count_fn, tpm_fn, K, num_iter, num_workers, seed, genes_file)
print('Prepare command assuming no parallelization:\n%s' % prepare_cmd)
os.system(prepare_cmd)


# ## 2.2 cNMF

# In[6]:

worker_index = ' '.join([str(x) for x in range(num_workers)])
factorize_cmd = 'nohup parallel python %s/cnmf.py factorize --output-dir %s --name %s --total-workers %d --worker-index {} ::: %s' % (
    cNMF_dir, output_dir, run_name, num_workers, worker_index)
print('Factorize command to simultaneously run factorization over %d cores using GNU parallel:\n%s' % (num_workers, factorize_cmd))
os.system(factorize_cmd)


# ## 2.3 merge replicates

# In[7]:


merge_cmd = 'python %s/cnmf.py combine --output-dir %s --name %s' % (cNMF_dir, output_dir, run_name)
print(merge_cmd)
os.system(merge_cmd)


# ## 2.4 绘制诊断图

# In[8]:


kselect_plot_cmd = 'python %s/cnmf.py k_selection_plot --output-dir %s --name %s' % (cNMF_dir, output_dir, run_name)
print('K selection plot command: %s' % kselect_plot_cmd)
os.system(kselect_plot_cmd)
print("print results @ tmp/step2/%s/%s.k_selection.png" %(run_name, run_name))

