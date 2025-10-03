# coding: utf-8

from s2_run_cNMF_config import *


# ## 3. Downstream analysis after cNMF
# ### 3.1 Normalize usage matrix

# In[29]:


selected_K = 16
density_threshold = 0.20
density_threshold_str = ('%.2f' % density_threshold).replace('.', '_')
ngenes = 100 # top N genes extract from GEP spectra matrix

# In[30]:


usage = pd.read_csv("tmp/step2/%s/%s.usages.k_%s.dt_%s.consensus.txt" % (run_name, run_name, selected_K, density_threshold_str), sep='\t', index_col=0)
usage.columns = ["Usage_%s" % i for i in usage.columns]
usage.head()


# In[31]:


usage_norm = usage.div(usage.sum(axis=1), axis=0)
usage_norm.head()


# In[32]:


usage_norm.to_csv("tmp/step2/%s/%s.usages.k_%s.dt_%s.consensus.normalized.txt" % (run_name, run_name, selected_K, density_threshold_str), sep="\t")


# ### 3.2 Extract genes with high loadings in each GEP (top100)

# In[33]:


gene_scores = pd.read_csv("tmp/step2/%s/%s.gene_spectra_score.k_%s.dt_%s.txt" % (run_name, run_name, selected_K, density_threshold_str), sep="\t", index_col=0).T
gene_scores.head()


# In[34]:


## Obtain the top 300 genes for each GEP in sorted order and combine them into a single dataframe

top_genes = []

for gep in gene_scores.columns:
    top_genes.append(list(gene_scores.sort_values(by=gep, ascending=False).index[:ngenes]))
    
top_genes = pd.DataFrame(top_genes, index=gene_scores.columns).T
top_genes.columns = ["program_%s" % i for i in top_genes.columns]
top_genes.head()


# In[35]:


gene_scores.columns = ["program_%s" % i for i in gene_scores.columns]
gene_scores.head()


# In[36]:


top_genes.to_csv("tmp/step2/%s/%s.top%s_genes.k_%s.dt_%s.txt" % (run_name, run_name, ngenes, selected_K, density_threshold_str), sep="\t", index=0)
gene_scores.to_csv("tmp/step2/%s/%s.gene_spectra_score.k_%s.dt_%s.T.txt" % (run_name, run_name, selected_K, density_threshold_str), sep="\t", index=1)


# In[ ]:




