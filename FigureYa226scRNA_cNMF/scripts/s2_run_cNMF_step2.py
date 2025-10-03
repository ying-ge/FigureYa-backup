# coding: utf-8

from s2_run_cNMF_config import *

step2_1 = True
step2_2 = True


# ## 2.5 确定components的数量

selected_K = 16
density_threshold = 2.00


consensus_cmd = 'python %s/cnmf.py consensus --output-dir %s --name %s --local-density-threshold %.2f --components %d --show-clustering' % (
    cNMF_dir, output_dir, run_name, density_threshold, selected_K)

if step2_1:
    print('Consensus command for K=%s:\n%s' % (selected_K, consensus_cmd))
    os.system(consensus_cmd)
    density_threshold_str = ('%.2f' % density_threshold).replace('.', '_')
    print("print results @ tmp/step2/%s/%s.clustering.k_%d.dt_%s.png" % (run_name, run_name, selected_K, density_threshold_str) )   


# ## 2.6 过滤program outliers

density_threshold = 0.20

consensus_cmd = 'python %s/cnmf.py consensus --output-dir %s --name %s --local-density-threshold %.2f --components %d --show-clustering' % (
    cNMF_dir, output_dir, run_name, density_threshold, selected_K)

if step2_2:
    print('Consensus command for K=%s:\n%s' % (selected_K, consensus_cmd))
    os.system(consensus_cmd)
    density_threshold_str = ('%.2f' % density_threshold).replace('.', '_')
    print("print results to tmp/step2/%s/%s.clustering.k_%d.dt_%s.png" % (run_name, run_name, selected_K, density_threshold_str) )


