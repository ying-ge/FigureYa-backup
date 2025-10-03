# Algorithm Workflow

- Calculate variance (var), one-sided chi-square test p-value (pvalue), and robust coefficient of variation (rCV, CV after removing max and min values) for each probe
- Filter low-quality probes based on pvalue < 0.01 and rCV < 10
- Screen probes using different quantile thresholds (0.6, 0.7, 0.8, 0.9, 0.95, 0.975, 0.99, 0.995) based on rCV, feature sets stored in `probe.stat$sets`

## 2: Generate Clustering Trees

- Generate 24 clustering trees based on 8 thresholds and 3 clustering methods (average, complete, ward), results stored in `Dends` object, clustering tree diagrams stored in `Dendrograms.pdf`

## 3: Tree Stability Assessment

- Perturbation: Generate noise matrix `noise` with mean 0 and variance 1.5 times the median variance of probes
- Resampling: Add noise matrix to original samples (for re-clustering)
- Use `RF.dist` function to assess similarity between clustering trees
- Since this step did not affect downstream clustering results and the paper did not provide tree stability assessment results, only the methods for perturbation, resampling, and similarity scoring are listed here

## 4: Identify Robust Clusters

- `IsCoClass`: Under a specified clustering tree (dend), if a pair of samples (sampleA, sampleB) are grouped together when clustered into k classes, and the group size is at least 4, then this clustering tree identifies the pair as the same class
- For different k values, calculate clustering consensus matrices separately (number of clustering trees that identify a pair of samples as the same class at specified k)
- Clustering consensus matrices stored in `mat.list` object, consensus heatmaps stored in `ConsensusMatrix.pdf`
- Select appropriate k (here k=3 is selected), treat samples identified as the same class by at least 22 clustering trees as one class (cutree, h=24-22), obtain preliminary clustering results stored in the `PrimaryCluster` column of `sampleInfo` object
- For each class in `PrimaryCluster`, treat classes identified as the same by an average of at least 18 clustering trees as one class (cutree, h=24-18), obtain final clustering results stored in the `FinalCluster` column of `sampleInfo` object

## 5: Select Differential Genes to Build Classifier

- Since the clustering results from step 4 slightly differ from the original paper, the rC1 and rC2 grouping results from the original paper are used here
- Use limma for differential analysis of rC1-rC2, select probes with padj < 0.001 to build the classifier

## 6: Classification using classpredict package

- The classpredict package is the R version of BRB ArrayTools. Since the Compound Covariate Predictor (CCP) used in the original paper does not have a corresponding package, the classpredict package is used here for class prediction
- Prediction results are in `resList$predNewSamples` and saved in `ClassPrediction.txt`

---

# 算法流程

## 1：筛选探针，结果储存在`probe.stat`对象中

- 计算各探针的方差(var)、卡方检验单侧p值(pvalue)和稳健变异系数(rCV，去除最大值和最小值后的变异系数)
- 根据pvalue<0.01和rCV<10过滤低质量探针
- 根据rCV使用不同分位数阈值(0.6, 0.7, 0.8, 0.9, 0.95, 0.975, 0.99, 0.995)，对探针进行筛选，特征集储存在`probe.stat$sets`中

## 2：生成聚类树

- 根据8个阈值和3种聚类方法(average, complete, ward)，生成24种聚类树，结果储存在`Dends`对象中，聚类树图储存在`Dendrograms.pdf`中

## 3：树稳定性评估

- 扰动：生成均值为0，方差为1.5倍探针中位方差的噪声矩阵`noise`
- 重抽样：将添加噪声矩阵的样本加入到原样本中（进行重新聚类）
- 使用`RF.dist`函数评估聚类树间的相似性
- 因为本步骤并未对下游聚类结果产生影响，文中也没有给出树稳定性评估的结果，故此处仅列出扰动、重抽样，相似性得分的计算方法

## 4：识别robust cluster

- `IsCoClass`：在指定聚类树(dend)下，一对样本(sampleA, sampleB)在聚为k类时，出现在同一组中，且该组样本量不小于4，则认为本聚类树将该对样本识别为一类
- 对不同的k，分别计算聚类共识矩阵（在指定的k下，将一对样本识别为一类的聚类树数目）
- 聚类共识矩阵储存在`mat.list`对象中，共识热图储存在`ConsensusMatrix.pdf`中
- 选取合适的k（此处选取k为3），将至少22棵聚类树识别为同类的样本视为一类(cutree, h=24-22)，得到初步的聚类结果，储存在`sampleInfo`对象的`PrimaryCluster`列中
- 对`PrimaryCluster`中的每一类，将平均至少有18棵聚类树识别为同类的类别视为一类(cutree, h=24-18)，得到最终聚类结果，储存在`sampleInfo`对象的`FinalCluster`列中

## 5：选取差异基因构建分类器

- 由于第4步得到的聚类结果与原文略有出入，此处使用的是原文中rC1和rC2的分组结果
- 使用limma对rC1-rC2做差异分析，选取padj<0.001的探针构建分类器

## 6：使用classpredict包进行分类

- classpredict包是BRB ArrayTools的R版本，由于原文使用的Compound Covariate Predictor(CCP)没有对应的包，所以此处使用classpredict包进行类别预测
- 预测结果在`resList$predNewSamples`中，保存在`ClassPrediction.txt`中
