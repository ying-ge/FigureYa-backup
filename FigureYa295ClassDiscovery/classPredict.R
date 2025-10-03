#' Class prediction
#'
#' This function calculates multiple classifiers that are used to predict the class of a new sample.
#' It implements the class prediction tool with multiple methods in BRB-ArrayTools.
#'
#' Please see the BRB-ArrayTools manual (\url{https://brb.nci.nih.gov/BRB-ArrayTools/Documentation.html}) for details.
#'
#' @param exprTrain matrix of gene expression data for training samples. Rows are genes and columns are arrays. Its column names must be provided.
#' @param exprTest matrix of gene expression data for new samples. Its column names must be provided.
#' @param isPaired logical. If \code{TRUE}, samples are paired.
#' @param pairVar.train vector of pairing variables for training samples.
#' @param pairVar.test vector of pairing variables for new samples.
#' @param geneId matrix/data frame of gene IDs.
#' @param cls vector of training sample classes.
#' @param pmethod character string vector of prediction methods to be employed.
#'  \itemize{
#'    \item "ccp":  Compound Covariate Predictor
#'    \item "bcc":  Bayesian Compound Covariate Predictor
#'    \item "dlda": Diagonal Linear Discriminant Analysis
#'    \item "knn":  1-Nearest Neighbor/ 3-Nearest Neighbor
#'    \item "nc":   Nearest Centroid
#'    \item "svm":  Support Vector Machine
#'  }
#' @param geneSelect character string for gene selection method.
#'  \itemize{
#'    \item "igenes.univAlpha": select individual genes univariately significantly differentially expressed between the classes at the specified threshold significance level.
#'    \item "igenes.grid":      select individual genes that optimize over the grid of alpha levels.
#'    \item "igenes.univMcr":   select individual genes with univariate misclassification rate below a specified value.
#'    \item "gpairs":           select gene pairs bye the "greedy pairs" method.
#'    \item "rfe":              select genes by recursive feature elimination.
#'   }
#' @param univAlpha numeric for a significance level. Default is 0.001.
#' @param univMcr numeric for univariate misclassification rate. Default is 0.2.
#' @param foldDiff numeric for fold ratio of geometric means between two classes exceeding. 0 means not to enable this option. Default is 2.
#' @param rvm logical. If \code{TRUE}, random variance model will be employed. Default is \code{FALSE}.
#' @param filter vector of 1/0's of the same length as genes. 1 means to keep the gene while 0 means to exclude genes
#' from class comparison analysis. If \code{rvm = TRUE}, all genes will be used in random variance model estimation. Default is \code{FALSE}.
#' @param ngenePairs: numeric specifying the number of gene pairs selected by the greedy pairs method. Default is 25.
#' @param nfrvm numeric specifying the number of features selected by the support vector machine recursive feature elimination method. Default is 10.
#' @param cvMethod numeric for the cross validation method. Default is 1.
#'  \itemize{
#'    \item 1:  leave-one-out CV,
#'    \item 2:  k-fold CV,
#'    \item 3:  0.632+ bootstrap.
#'    }
#' @param kfoldValue numeric specifying the number of folds if K-fold method is selected. Default is 10.
#' @param bccPrior numeric specifying the prior probability option for the Baysian compound covariate prediction.
#'                 If \code{bccPrior == 1}, equal prior probabilities will be applied.
#'                 If \code{bccPrior == 2}, prior probabilities based on the proportions in training data are applied.
#'                 Default is 1.
#' @param bccThresh numeric specifying the uncertainty threshold for the Bayesian compound covariate prediction. Default is 0.8.
#' @param nperm numeric specifying the number of permutations for the significance test of cross-validated mis-classification rate.
#' It should be equal to zero or greater than 50. Default is 0.
#' @param svmCost numeric specifying the cost values for SVM. Default is 1.
#' @param svmWeight numeric specifying the weight values for SVM. Default is 1.
#' @param fixseed numeric. \code{fixseed == 1} if a fixed seed is used; otherwise, \code{fixseed == 0}. Default is 1.
#' @param prevalence vector for class prevalences. When prevalence is \code{NULL}, the proportional of samples in each class will be the estimate of class prevalence. Default is \code{NULL}.
#' Names of vector should be provided and consistent with classes in \code{cls}.
#' @param projectPath character string specifying the full project path.
#' @param outputName character string specifying the output folder name. Default is "ClassPrediction".
#' @param generateHTML logical. If \code{TRUE}, an HTML page will be generated with detailed class prediction results saved in <projectPath>/Output/<outputName>/<outputName>.html.
#' @return A list that may include the following objects:
#' \itemize{
#'    \item \code{performClass}: a data frame with the performance of classifiers during cross-validation:
#'    \item \code{percentCorrectClass}: a data frame with the mean percent of correct classification for each sample using
#'              different prediction methods.
#'    \item \code{predNewSamples}:s a data frame with predicted class for each
#'              new sample. `NC` means that a sample is not classified. In this example, there are four new samples.
#'    \item \code{probNew}: a data frame with the predicted probability of each new sample belonginG to the class (BRCA1) from the the Bayesian Compound Covariate method.
#'    \item \code{classifierTable}: a data frame with composition of classifiers such as geometric means of values in each class, p-values and Gene IDs.
#'    \item \code{probInClass}: a data frame with predicted probability of each training sample belonging to
#'              aclass during cross-validation from the Bayesian Compound Covariate
#'    \item \code{CCPSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                   negative prediction value) of the Compound Covariate Predictor Classifier.
#'    \item \code{LDASenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                                 negative prediction value) of the Diagonal Linear Discriminant Analysis Classifier.
#'    \item \code{K1NNSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                    negative prediction value) of the 1-Nearest Neighbor Classifier.
#'    \item \code{K3NNSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                                  negative prediction value) of the 3-Nearest Neighbor Classifier.
#'    \item \code{CentroidSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                                      negative prediction value) of the Nearest Centroid Classifierr.
#'    \item \code{SVMSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                                 negative prediction value) of the Support Vector Machine Classifier.
#'    \item \code{BCPPSenSpec}: a data frame with performance (i.e., sensitivity, specificity, positive prediction value,
#'                                                                  negative prediction value) of the Bayesian Compound Covariate Classifier.
#'    \item \code{weightLinearPred}: a data frame with gene weights for linear predictors such as Compound Covariate Predictor,
#'              Diagonal Linear Discriminat Analysis and Support Vector Machine.
#'    \item \code{thresholdLinearPred}: a numeric vector of the thresholds for the linear prediction rules related with \code{weightLinearPred}.
#'              Each prediction rule is defined by the inner sum of the weights (\eqn{w_i})
#'              and log expression values (\eqn{x_i}) of significant genes.
#'              In this case, a sample is classified to the class BRCA1 if
#'              the sum is greater than the threshold; that is, \eqn{\sum_i w_i x_i > threshold}.
#'    \item \code{GRPCentroid}: a data frame with centroid of each class for each predictor gene.
#'    \item \code{ppval}: a vector of permutation p-values of statistical significance tests of cross-validated estimate of misclassification rate from specified #'    prediction methods.
#'    \item \code{pmethod}: a vector of prediction methods that are specified.
#'    \item \code{workPath}: the path for fortran and other intermediate outputs.
#'    }
#' @export
#' @examples
#' dataset<-"Brca"
#' # gene IDs
#' geneId <- read.delim(system.file("extdata", paste0(dataset, "_GENEID.txt"),
#'                      package = "classpredict"), as.is = TRUE, colClasses = "character")
#' # expression data
#' x <- read.delim(system.file("extdata", paste0(dataset, "_LOGRAT.TXT"),
#'                 package = "classpredict"), header = FALSE)
#' # filter information, 1 - pass the filter, 0 - filtered
#' filter <- scan(system.file("extdata", paste0(dataset, "_FILTER.TXT"),
#'                package = "classpredict"), quiet = TRUE)
#' # class information
#' expdesign <- read.delim(system.file("extdata", paste0(dataset, "_EXPDESIGN.txt"),
#'                         package = "classpredict"), as.is = TRUE)
#' # training/test information
#' testSet <- expdesign[, 10]
#' trainingInd <- which(testSet == "training")
#' predictInd <- which(testSet == "predict")
#' ind1 <- which(expdesign[trainingInd, 4] == "BRCA1")
#' ind2 <- which(expdesign[trainingInd, 4] == "BRCA2")
#' ind <- c(ind1, ind2)
#' exprTrain <- x[, ind]
#' colnames(exprTrain) <- expdesign[ind, 1]
#' exprTest <- x[, predictInd]
#' colnames(exprTest) <- expdesign[predictInd, 1]
#' projectPath <- file.path(Sys.getenv("HOME"),"Brca")
#' outputName <- "ClassPrediction"
#' generateHTML <- TRUE
#' resList <- classPredict(exprTrain = exprTrain, exprTest = exprTest, isPaired = FALSE,
#'                         pairVar.train = NULL, pairVar.test = NULL, geneId,
#'                         cls = c(rep("BRCA1", length(ind1)), rep("BRCA2", length(ind2))),
#'                         pmethod = c("ccp", "bcc", "dlda", "knn", "nc", "svm"),
#'                         geneSelect = "igenes.univAlpha",
#'                         univAlpha = 0.001, univMcr = 0, foldDiff = 0, rvm = TRUE,
#'                         filter = filter, ngenePairs = 25, nfrvm = 10, cvMethod = 1,
#'                         kfoldValue = 10, bccPrior = 1, bccThresh = 0.8, nperm = 0,
#'                         svmCost = 1, svmWeight =1, fixseed = 1, prevalence = NULL,
#'                         projectPath = projectPath, outputName = outputName, generateHTML)
#' if (generateHTML)
#'   browseURL(file.path(projectPath, "Output", outputName,
#'             paste0(outputName, ".html")))
#'
#'
classPredict <- function(exprTrain,
                         exprTest = NULL,
                         isPaired = FALSE,
                         pairVar.train = NULL,
                         pairVar.test = NULL,
                         geneId,
                         #singleChannel,
                         cls,
                         pmethod = c("ccp", "bcc", "dlda", "knn", "nc", "svm"),
                         geneSelect = "igenes.univAlpha",
                         univAlpha = 0.001,
                         univMcr = 0.2,
                         foldDiff = 2,
                         rvm = FALSE,
                         filter = NULL,
                         ngenePairs = 25,
                         nfrvm = 10,
                         cvMethod = 1,
                         kfoldValue = 10,
                         bccPrior = 1,
                         bccThresh = 0.8,
                         nperm = 0,
                         svmCost = 1,
                         svmWeight = 1,
                         fixseed = 1,
                         prevalence = NULL,
                         projectPath,
                         outputName = "ClassPrediction",
                         generateHTML = FALSE) {
  
  if (isPaired && any(pmethod == "bcc"))
    stop("The Bayesian compound covariate predictor cannot be used if you have paired data. Please select other prediction methods. \n")
  
  # when prevlaence is NULL, the proportion of patients in each class will be calculated as the estimate of class prevalences.
  # Note that the names of prevalence should be re-ordered in alphabetical order.
  if (is.null(prevalence)){
    classNames <- sort(unique(cls))
    prevalence <- rep(0,length(classNames))
    for (i in 1:length(classNames))
      prevalence[i] <- length(which(cls == classNames[i]))/length(cls)
    names(prevalence) <- classNames
  } else {
    if (any(sort(names(prevalence)) != sort(unique(cls))))
      stop("Please provide correct dimension or names for argument prevalence. \n")
    prevalence <- prevalence[sort(names(prevalence), index.return=TRUE)$ix]
  }
  
  
  # ArrayToolsVersion <- '4.6.0 - Beta (July 2017)'
  ArrayToolsPath <- path.package("classpredict")  # ArrayToolsPath <-'C:/Program Files (x86)/ArrayTools'
  # eventually we can remove this parameter in all R code
  
  # projectPath <- 'C:/Program Files (x86)/ArrayTools/Sample datasets/Pomeroy/Pomeroy -Project5'
  WorkPath <- file.path(projectPath, "Fortran", outputName)
  if (!file.exists(WorkPath)) dir.create(WorkPath, recursive = TRUE)
  
  successfile <- paste(WorkPath, '/success.txt', sep='')
  fortranerrorfile <- paste(WorkPath, '/fortranerror.txt', sep='')
  unlink(successfile); unlink(fortranerrorfile)
  
  # create <class_perm_params.txt>, <LR_data.txt> etc.
  prepareClassPredict(exprTrain, geneId, isPaired, pairVar.train, pairVar.test, cls, pmethod, geneSelect,
                      univAlpha, univMcr, foldDiff, rvm , filter, ngenePairs, nfrvm,
                      cvMethod, kfoldValue, bccPrior, bccThresh,
                      nperm, svmCost, svmWeight, fixseed, WorkPath, exprTest)
  # create <RunFortran.bat> file
  createfortran.classpredict(ArrayToolsPath, WorkPath)
  
  # run <RunFortrn.bat>
  system(paste0("\"", WorkPath, "/RunFortran.bat", "\""), wait = TRUE)
  
  DoGOOvE <- F
  MinObserved <- 5
  MinRatio <- 2
  RedoExpectedTable <- F
  ClassVariable <- paste(unique(cls), collapse = " vs ")
  AnalysisType <- 'ClassPrediction'
  GeneListFileName <- 'ClassPrediction.txt'
  #  ArrayToolsVersion <- '4.6.0 - Stable (August 2016)'
  LogBase <- 2
  paired <- ifelse(isPaired, TRUE, FALSE)
  GenesTotal <- nrow(exprTrain)
  nspot <- ifelse(missing(rvm) || !rvm, nrow(exprTrain), sum(filter))
  CcpParam <- ifelse("ccp" %in% pmethod, TRUE, FALSE)
  KnnParam <- ifelse("knn" %in% pmethod, TRUE, FALSE)
  CentroidParam <- ifelse("nc" %in% pmethod, TRUE, FALSE)
  SvmParam <- ifelse("svm" %in% pmethod, TRUE, FALSE)
  LDAParam <- ifelse("dlda" %in% pmethod, TRUE, FALSE)
  ProjectFileName <- ""  # XXX.xls
  
  #  cat('Getting analysis results ...\n', file=stderr())
  cat('Getting analysis results ...\n')
  resList <- GetPredictionResults(projectPath, outputName, GeneListFileName,
                                  paired, CcpParam, LDAParam, KnnParam, CentroidParam, SvmParam,
                                  #singleChannel,
                                  AnalysisType, LogBase, ArrayToolsPath,
                                  nspot, ClassVariable, DoGOOvE, GenesTotal, prevalence, generateHTML)
  #  gpr.out <- try(GetPredictionResults(projectPath, outputName, GeneListFileName,
  #                                      paired, CcpParam, LDAParam, KnnParam, CentroidParam,
  #                                      SvmParam, singleChannel, AnalysisType, LogBase, ArrayToolsPath,
  #                                     nspot, ClassVariable, DoGOOvE, GenesTotal))
  # if (class(gpr.out)=='try-error') {
  #   cat(geterrmessage())
  #   if (exists('last.warning')) cat(attributes(last.warning)$names)
  #  stop()
  #  }
  
  return(c(resList,list(pmethod=pmethod, workPath=WorkPath)))
  
}

prepareClassPredict<- function(exprTrain, geneId, isPaired, pairVar.train, pairVar.test, cls, pmethod, geneSelect,
                               univAlpha, univMcr, foldDiff, rvm , filter, ngenePairs, nfrvm,
                               cvMethod, kfoldValue, bccPrior, bccThresh,
                               nperm, svmCost, svmWeight, fixseed, outputpath, exprTest) {
  # Purpose:
  #   Create <LR_data.txt>, <class_perm_params.txt>, <experiments.rda>, <geneIdNames.rda> <geneIdX.rda>
  # See <WriteDataToFilesPrediction.R>.
  
  # experiments.rda (originally created from WriteDataToFilesPrediction.R)
  if (any(is.na(exprTrain))) {
    exprTrain[is.na(exprTrain)] <- -9999999
  }
  if (!is.null(exprTest) && any(is.na(exprTest)))
    exprTest[is.na(exprTest)] <- -9999999
  
  if (isPaired) {
    if (is.null(exprTest)) {
      experiments <- data.frame(ExpId=colnames(exprTrain), ClassVariable=cls, PairingVariable=pairVar.train)
      experiments <- experiments[order(cls, pairVar.train), , drop = FALSE]
      ClassVariable0 <- cls[order(cls, pairVar.train)]
      arr1 <- exprTrain
      arr1 <- arr1[ ,order(cls, pairVar.train), drop=FALSE]
      
    } else {
      ZZZZZZZ <-  "ZZZZZZZ"
      ZZZZZZZ.1 <-"ZZZZZZZ.1"
      ZZZZZZZ.2 <-"ZZZZZZZ.2"
      predict <- "predict"
      
      clsNew <- c(cls,rep("predict",ncol(exprTest)))
      pairVarNew <- c(pairVar.train, pairVar.test)
      experiments <- data.frame(ExpId=c(colnames(exprTrain),colnames(exprTest)), ClassVariable=clsNew, PairingVariable=pairVarNew)
      ntests <- length(experiments$PairingVariable[experiments$ClassVariable == predict])/2
      arr1 <- cbind(exprTrain, exprTest)
      if (ntests != round(ntests)) {  #e.g., if ntests is not an integer.
        tempvec <- as.character(experiments$PairingVariable[experiments$ClassVariable != predict])
        temptable <- table(tempvec)
        tempnames <- names(temptable)[temptable != 2]
        tempnameslen <- length(tempnames)
        tempnames <- paste(rep("'", tempnameslen), tempnames, rep("'", tempnameslen), sep="")
        tempnames <- paste(tempnames, collapse=", ")
        stop("ERROR: The following values of the pairing variable cannot be designed as both 'training' and 'predict': ", tempnames, sep="")
      }
      TempClassVariable <- as.character(experiments$ClassVariable)
      TempClassVariable[TempClassVariable == predict] <- ZZZZZZZ
      arr1 <- arr1[ ,order(TempClassVariable,experiments$PairingVariable), drop=FALSE]
      experiments <- experiments[order(TempClassVariable,experiments$PairingVariable), ]
      ClassVariable0 <- clsNew
      ClassVariable0 <- ClassVariable0[order(TempClassVariable,experiments$PairingVariable)]
      
      TempClassVariable <- TempClassVariable[order(TempClassVariable,experiments$PairingVariable)]
      TempClassVariable[TempClassVariable == ZZZZZZZ] <- rep(c(ZZZZZZZ.1,ZZZZZZZ.2),ntests)
      arr1 <- arr1[ ,order(TempClassVariable,experiments$PairingVariable), drop=FALSE]
      experiments <- experiments[order(TempClassVariable,experiments$PairingVariable), ]
      ClassVariable0 <- ClassVariable0[order(TempClassVariable,experiments$PairingVariable)]
      
      
      #      experiments <- experiments[order(clsNew, pairVarNew), , drop = FALSE]
    }
  } else {
    if (is.null(exprTest)) {
      experiments <- data.frame(ExpId=colnames(exprTrain), ClassVariable=cls)
      experiments <- experiments[order(cls), ]
      arr1 <- exprTrain[, order(cls), drop=FALSE]
      ClassVariable0 <- cls[order(cls)]
    } else {
      ZZZZZZZ <-  "ZZZZZZZ"
      predict <- "predict"
      experiments <- data.frame(ExpId=colnames(exprTrain), ClassVariable=cls)
      experimentsTest <- data.frame(ExpId=colnames(exprTest), ClassVariable=rep("predict",ncol(exprTest)))
      experiments <- rbind(experiments, experimentsTest)
      arr1 <- cbind(exprTrain, exprTest)
      TempClassVariable <- as.character(experiments$ClassVariable)
      TempClassVariable[TempClassVariable == predict] <- ZZZZZZZ
      arr1 <- arr1[, order(TempClassVariable), drop=FALSE]
      experiments <- experiments[order(TempClassVariable), ]
      ClassVariable0 <- experiments$ClassVariable
      
    }
  }
  
  if (rvm){
    arr1 <- cbind(arr1, filter)
  }
  #  if (is.null(exprTest)) {
  #    ClassVariable0 <- cls
  #  } else {
  #    ClassVariable0 <- c(cls,rep("predict",ncol(exprTest)))
  #  }
  
  
  save(experiments, ClassVariable0, file=file.path(outputpath, "experiments.rda"))
  
  # geneIdNames.rda (originally created from Utilities.bas)
  GeneIdNames <- colnames(geneId)
  save(GeneIdNames, file = file.path(outputpath, "GeneIdNames.rda"))
  for(i in 1:length(GeneIdNames)) {
    assign(paste0("GeneId", i), geneId[, i])
    save(list = paste0("GeneId", i), file = file.path(outputpath, paste0("GeneId", i, ".rda")))
  }
  if (isPaired) {
    exprTrain <- exprTrain[, order(cls, pairVar.train)]
    npairs <- length(cls)/2
    arr.current <- exprTrain[, 1:npairs] - exprTrain[, (npairs + 1):length(cls)]
    meandiff <- rowMeans(arr.current, na.rm=T)
    save(meandiff, file = file.path(outputpath, "meandiff.rda"))
  } else {
    ucls <- unique(sort(cls))
    # meanLR1.rda, meanLR2.rda ... (originally created from WriteDataToFilesPrediction.R)
    for (i in 1:length(ucls)) {
      arr.current <- exprTrain[ , cls == ucls[i], drop = FALSE]
      meanLR <- rowMeans(arr.current, na.rm=T)
      # if (NumClassLevels == 2 & i == 1) meanLR1 <- meanLR
      # if (NumClassLevels == 2 & i == 2) meanLR2 <- meanLR
      save(meanLR, file = file.path(outputpath, paste0("meanLR", i , ".rda")))
    }
  }
  # pairwiseCC.rda
  
  # LR_data.txt (originally created from writeDataToFilesPrediction.R)
  if (is.null(exprTest) | missing(exprTest)) {
    numpredictions <- 0
  } else {
    numpredictions <- ncol(exprTest)
  }
  ncls <- paste(table(cls), collapse=' ')
  cat(paste(length(unique(cls)), numpredictions, nrow(exprTrain), ifelse(isPaired, 1, 0)),
      ifelse(isPaired, paste(rep(npairs,2),collapse=' '), ncls),
      file=paste(outputpath, "/LR_data.txt", sep=""), sep="\n", append=F)
  
  write.table(round(arr1, 7), file=file.path(outputpath, "LR_data.txt"),
              sep="\t", quote=F, row.names=F, col.names=F, append=T)
  
  #  class_perm_params.txt (originally created from ClassPrediction.bas)
  geneorpairs <- ifelse(geneSelect == "gpairs", 2, 1)
  geneSelectionmethod <- switch(geneSelect,
                                igenes.univAlpha = 1,
                                igenes.grid = 2,
                                gpairs = 2, #Lori 9/6/2017
                                igenes.univMcr = 3)
  classperm <- c(paste0(nperm, "\tNPermutations"),
                 paste0(geneorpairs, "\tGeneOrPairs"),
                 paste0(geneSelectionmethod, "\tgeneSelectionMenthod"),
                 paste0(ifelse(foldDiff > 0, 1, 0), "\tUsefoldDiff"),
                 paste0(cvMethod, "\tCrossValidation"),
                 paste0(univAlpha, "\tAlpha"),
                 paste0(univMcr,"\tMisClassLevel"),
                 paste0(ifelse(foldDiff > 0, foldDiff, 1), "\tfoldDiffLevel"),
                 paste0(ifelse("ccp" %in% pmethod, 1, 0), "\t", ifelse("knn" %in% pmethod, 1, 0), "\t", ifelse("nc" %in% pmethod, 1, 0),
                        "\t", ifelse("svm" %in% pmethod, 1, 0), "\t", ifelse("dlda" %in% pmethod, 1, 0), "\tCCP,\tKNN,\tCentroid,\tSVM,\tLDA"),
                 paste0(ifelse("bcc" %in% pmethod, 1, 0), "\t", bccPrior, "\t", bccThresh, "\tBCCP,\tPriorValue,\tBCCPThreshhold"),
                 paste0(svmCost, "\t", svmWeight, "\tSVMCost,\tSVMWeight"),
                 paste0(ifelse(fixseed, 1, 0), "\tRandomSeed"),
                 paste0(ifelse(rvm, 1, 0), "\tRandomVariance"),
                 paste0(ngenePairs, "\tNPairs"),
                 paste0(1,"\t", kfoldValue, "\tKFoldTimes,\tkfoldValue"),
                 paste0(ifelse(geneSelect == "rfe", 1, 0), "\t", nfrvm, "\tRFE,\tNFeatures"))
  cat(classperm, file=file.path(outputpath, "class_perm_params.txt"), sep = "\n")
  
}

createfortran.classpredict <- function(ArrayToolsPath, outputpath) {
  # Purpose: create <RunFortran.bat>
  
  # replace one forward slash with one backward slash for running in COMMAND PROMPT
  outputpath2 <- gsub("/", "\\\\", outputpath)
  ArrayToolsPath <- normalizePath(ArrayToolsPath)
  out <- c(substring(ArrayToolsPath, 1, 2),
           paste0("cd \"", ArrayToolsPath, "\\Fortran\""),
           paste0("ClassPrediction3_5.exe^\n \"",
                  outputpath2, "\"^\n 1> \"",
                  outputpath2, "\\FortranOutput.txt\"^\n 2> \"",
                  outputpath2, "\\FortranError.txt\""))
  cat(out, file = file.path(outputpath, "RunFortran.bat"), sep = "\n")
}

GetPredictionResults <- function(ProjectPath,
                                 AnalysisName,
                                 GeneListFileName,
                                 paired,
                                 CcpParam, LDAParam, KnnParam, CentroidParam, SvmParam,
                                 #                                 IsSingleChannel, # GetGenesHTML
                                 AnalysisType, # GetGenesHTML
                                 LogBase,
                                 ArrayToolsPath,
                                 nspot,
                                 ClassVariable,
                                 DoGOOvE,
                                 GenesTotal,
                                 prevalence,
                                 generateHTML) {
  WorkPath <- file.path(ProjectPath, "Fortran", AnalysisName)
  
  #Must create each level of path in a separate dir.create() function call.
  
  if (generateHTML){
    OutPath <- paste(ProjectPath, "/Output/", AnalysisName, sep="") # 'ExternalFileName' will be used in <Input_to_output_function.R> too
    # Make sure the definition is the same in both places
    dir.create(OutPath, showWarnings = FALSE, recursive = TRUE)
    ExternalFileName <- paste(OutPath, "/", AnalysisName, ".html", sep="")
    unlink(ExternalFileName)
    #ExternalFileNamePair <- file.path(OutPath, "genetablepair.html")
    #unlink(ExternalFileNamePair)
  }
  #
  
  #  ChromDistFile <- paste(OutPath, "/", AnalysisName, " -ChromDist.jpg", sep="")
  
  #Create genelist folder.
  #  if (!file.exists(paste(ProjectPath, "/Genelists/AnalysisResults", sep="")))
  #    dir.create(paste(ProjectPath, "/Genelists/AnalysisResults", sep=""), showWarnings=F, recursive = TRUE)
  
  
  #  unlink(ChromDistFile)
  
  #delete the existing genelist file with the same name. GeneListFileName defined in RunR.R. Yong 2/1/07
  curgenelistfile<-paste(ProjectPath, "/Genelists/AnalysisResults/", GeneListFileName, sep="")
  if (file.exists(curgenelistfile)) unlink(curgenelistfile)
  
  ngrp <- scan(paste(WorkPath, "lr_data.txt", sep="/"), nmax=1, quiet=T)
  groupsize <- scan(paste(WorkPath, "lr_data.txt", sep="/"), n=4+ngrp, quiet=T)[5:(4+ngrp)]
  
  paramfile <- paste(WorkPath, "/class_perm_params.txt", sep="")
  NumPermutations       <- scan(paramfile, n=1, skip=0, quiet=TRUE)
  GenesOrPairs          <- scan(paramfile, n=1, skip=1, quiet=TRUE)
  GeneSelectionMethod   <- scan(paramfile, n=1, skip=2, quiet=TRUE)
  UseFoldDiff           <- scan(paramfile, n=1, skip=3, quiet=TRUE)
  CrossValidationMethod <- scan(paramfile, n=1, skip=4, quiet=TRUE)
  tAlpha                <- scan(paramfile, n=1, skip=5, quiet=TRUE)
  MisClassLevel         <- scan(paramfile, n=1, skip=6, quiet=TRUE)
  FoldDiffLevel         <- scan(paramfile, n=1, skip=7, quiet=TRUE)
  methods <- double(7)
  # Modified Ming-Chung 6/26/2005
  # methods               <- params[c(9,10,10,11,12,13,14)]
  methods               <- scan(paramfile, n=5, skip=8, quiet=TRUE)[c(1,2,2,3,4,5)]
  methods <- c(methods, scan(paramfile, n=1, skip=9, quiet=TRUE))
  poption <- scan(paramfile, n=2, skip=9, quiet=TRUE)[2]
  pthresh <- scan(paramfile, n=3, skip=9, quiet=TRUE)[3]
  BccpParam <- ifelse(methods[7] == 1, TRUE, FALSE) # not know why others defined in RunPrediction.R
  c                     <- scan(paramfile, n=1, skip=10, quiet=TRUE)
  w                     <- scan(paramfile, n=2, skip=10, quiet=TRUE)[2]
  ISEED                 <- scan(paramfile, n=1, skip=11, quiet=TRUE)
  codeReg                   <- scan(paramfile, n=1, skip=12, quiet=TRUE)
  NPairs                <- scan(paramfile, n=1, skip=13, quiet=TRUE)
  KFoldTimes            <- scan(paramfile, n=1, skip=14, quiet=TRUE)
  KFoldValue            <- scan(paramfile, n=2, skip=14, quiet=TRUE)[2]
  Rfe                   <- scan(paramfile, n=1, skip=15, quiet=TRUE)
  Rfe <- as.integer(Rfe)
  nfeatures             <- scan(paramfile, n=2, skip=15, quiet=TRUE)[2]
  UniquePrediction <- CrossValidationMethod == 1 |
    (CrossValidationMethod == 2 & KFoldTimes == 1)
  
  SampleErrorP <- read.table(paste(WorkPath, "/SampleErrorP.txt", sep=""), header=T)[,-1]
  MeanErrorRate <- read.table(paste(WorkPath, "/MeanErrorRate.txt", sep=""), header=T)
  nDEGmean <- read.table(paste(WorkPath, "/nDEGmean.txt", sep=""), header=T)[,-1]
  # Reorder methods as needed for tables:
  BCCPProb <- SampleErrorP[,8]
  SampleErrorP  <- SampleErrorP[,c(1,6,2,3,4,5,7)]
  MeanErrorRate <- MeanErrorRate[c(1,6,2,3,4,5,7)]
  nDEGmean      <- nDEGmean[,c(1,6,2,3,4,5,7)]
  # methods0      <- methods
  methods       <- methods[c(1,6,2,3,4,5,7)]
  # methods: 1=CCP, 2=DLDA, 3,4=KNN, 5=NC, 6=SVM, 7=BCCP
  SameN <- T
  methodsBoolean <-  methods == 1
  
  if (ngrp > 2) methodsBoolean[c(1, 6, 7)] <- FALSE
  
  # Modified by Ming-Chung 3/14/2005
  #  SampleErrorP.selected <- SampleErrorP[,methodsBoolean]
  SampleErrorP.selected <- SampleErrorP[,methodsBoolean,drop = FALSE]
  #  nDEGmean.selected <- nDEGmean[,methodsBoolean]
  nDEGmean.selected <- nDEGmean[,methodsBoolean,drop = FALSE]
  #  MeanErrorRate.selected <- MeanErrorRate[,methodsBoolean]
  MeanErrorRate.selected <- MeanErrorRate[,methodsBoolean,drop = FALSE]
  
  Nmethods <- sum(methodsBoolean)
  if (Nmethods > 1) for (i in 2:Nmethods) {
    if(any(nDEGmean.selected[,i] != nDEGmean.selected[,1]) ) SameN <- F
  }
  
  # methods order: CPP  LDA k1  k3  centroid  SVM
  # experiments.rda is a data frame with 2 columns [ExpId, ClassVariable]
  # It includes both training and predict arrays.
  # For the predict arrays, ClassVariable will be 'training', 'predict' or 'exclude'.
  load(paste(WorkPath, "/experiments.rda", sep="")) #use load/save method, Yong 12/6/06. Use WorkPath, Yong 12/15/06
  experimentsRow <- experiments
  experiments <- experimentsRow[tolower(as.character(experimentsRow$ClassVariable)) != "predict",]
  TrainingExpId <- experiments$ExpId # Created for BCCP
  groupid <- as.character(experiments$ClassVariable)
  experimentsNew <- experimentsRow[tolower(as.character(experimentsRow$ClassVariable)) == "predict",]
  ClassVariable0 <- ClassVariable0[tolower(as.character(experimentsRow$ClassVariable)) == "predict"]
  #  ClassVariable0[ClassVariable0 == "-9999999"] <- ""
  PredictExpId <- experimentsNew$ExpId
  
  ntest <-  sum(tolower(as.character(experimentsRow$ClassVariable)) == "predict")
  pred.test <- ntest > 0
  classlabels <- unique(sort(as.character(experiments$ClassVariable)))
  ngroup <- length(classlabels)
  twogroup <- ngroup == 2
  
  if (paired) {
    npairs <- nrow(experiments)/2
    # modified Ming-Chung 3/14/2005; Add seqnum colname
    experiments <- cbind(seqnum = 1:npairs, as.character(experiments$PairingVariable[1:npairs]))
    IdName <- "Pair ID"
  } else {
    experiments <- cbind(seqnum = 1:nrow(experiments), experiments)
    IdName <- "Array id"
  }
  if(SameN) {
    #  modified Ming-Chung 3/14/2005; add ndeg colname
    experiments <- cbind(experiments,ndeg = round(nDEGmean.selected[,1]))
  } else {
    NTable <- cbind(experiments,ndeg = round(nDEGmean.selected))
  }
  # experiments <- cbind(experiments,round(100-100*SampleErrorP.selected))
  printNA <- FALSE
  if (UniquePrediction) {
    correctrate <- matrix("YES", nr=nrow(experiments), nc=ncol(SampleErrorP.selected))
    correctrate[SampleErrorP.selected != 0] <- "NO"
    correctrate[SampleErrorP.selected < 0] <- "NA"
    if (any(SampleErrorP.selected < 0)) printNA <- TRUE
    
  } else {
    correctrate <- round(100-100*SampleErrorP.selected) # data frame
    correctrate <- sapply(correctrate, as.character) # Fixed 5/30/2007 MLI
    correctrate[SampleErrorP.selected < 0] <- "NA"
    if (any(SampleErrorP.selected < 0)) printNA <- TRUE
  }
  PercentCorrect <- round(100-100*MeanErrorRate.selected)
  
  #// added by Ting 8/16/17
  experiments2 <- as.data.frame(cbind(experiments[,-1], correctrate))
  #  experiments2 <- as.matrix(experiments)
  namesExp2 <- NULL
  if (paired) {
    namesExp2 <- c(namesExp2, IdName)
  } else {
    namesExp2 <- c(namesExp2, IdName, "Class label")
  }
  if (SameN) namesExp2 <- c(namesExp2, "Mean Number of genes in classifier")
  tmp <- NULL
  if (CcpParam & twogroup)  tmp <- "CCP" #"Compound Covariate Predictor"
  if (CcpParam & UniquePrediction & twogroup) tmp <- "CCP Correct?" #"Compound Covariate Predictor Correct?"
  namesExp2 <- c(namesExp2, tmp)
  tmp <- NULL
  if (LDAParam) tmp <- "DLDA" #"Diagonal Linear Discriminant Analysis"
  if (LDAParam & UniquePrediction) tmp <- "DLDA Correct?" #"Diagonal Linear Discriminant Analysis Correct?"
  namesExp2 <- c(namesExp2, tmp)
  tmp <- NULL
  if (KnnParam) tmp <- c("1NN", "3NN") #c("1-Nearest Neighbor", "3-Nearest Neighbors")
  if (KnnParam & UniquePrediction) tmp <- c("1NN Correct?", "3NN Correct?") #c("1-Nearest Neighbor Correct?", "3-Nearest Neighbors Correct?")
  namesExp2 <- c(namesExp2, tmp)
  tmp <- NULL
  if (CentroidParam) tmp <- "Nearest Centroid"
  if (CentroidParam & UniquePrediction) tmp <- "Nearest Centroid Correct?"
  namesExp2 <- c(namesExp2, tmp)
  tmp <- NULL
  if (SvmParam & twogroup) tmp <- "SVM" #"Support Vector Machines"
  if (SvmParam & UniquePrediction & twogroup) tmp <- "SVM Correct?" #"Support Vector Machines Correct?"
  namesExp2 <- c(namesExp2, tmp)
  tmp <- NULL
  if (BccpParam & twogroup) tmp <- "BCCP" #"Bayesian Compound Covariate Predictor"
  if (BccpParam & UniquePrediction & twogroup) tmp <- "BCCP Correct?" #"Bayesian Compound Covariate Predictor Correct?"
  namesExp2 <- c(namesExp2, tmp)
  names(experiments2) <- namesExp2
  percentCorrectClass <- PercentCorrect
  colnames(percentCorrectClass) <- namesExp2[-(1:(ncol(experiments2)-length(PercentCorrect)))]
  resList <- list(performClass=experiments2,percentCorrectClass=percentCorrectClass)
  # //end by Ting 8/16/17
  
  if (generateHTML){
    experiments <- cbind(experiments, correctrate)
    experiments <- as.matrix(experiments) # convert into character matrix
    experiments[,1] <- paste("<TR ALIGN=center><TH>", experiments[,1])
    ExpClassified <- rep( "", nrow(experiments)+2 )
    if (paired) {
      ExpClassified[1] <- paste("<TR><TH>&nbsp;<TH>", IdName) #Qian 6/2/09
    } else {
      ExpClassified[1] <- paste("<TR><TH>&nbsp;<TH>", IdName,"<TH>Class label") #Qian 6/2/09
    }
    if (SameN) ExpClassified[1] <- paste(ExpClassified[1],"<TH WIDTH=65>Mean Number of genes in classifier")
    if (CcpParam & twogroup) ExpClassified[1] <- paste(ExpClassified[1], "<TH>Compound<BR>Covariate<BR>Predictor", sep="")
    if (CcpParam & UniquePrediction & twogroup) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    if (LDAParam) ExpClassified[1] <- paste(ExpClassified[1],"<TH>Diagonal Linear<BR>Discriminant<BR>Analysis", sep="")
    if (LDAParam & UniquePrediction) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    if (KnnParam) ExpClassified[1] <- paste(ExpClassified[1], "<TH>1-Nearest<BR>Neighbor<TH>3-Nearest<BR>Neighbors", sep="")
    if (KnnParam & UniquePrediction) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    if (CentroidParam) ExpClassified[1] <- paste(ExpClassified[1], "<TH>Nearest<BR>Centroid", sep="")
    if (CentroidParam & UniquePrediction) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    if (SvmParam & twogroup) ExpClassified[1] <- paste(ExpClassified[1],"<TH>Support<BR>Vector<BR>Machines", sep="")
    if (SvmParam & UniquePrediction & twogroup) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    if (BccpParam & twogroup) ExpClassified[1] <- paste(ExpClassified[1],"<TH>Bayesian<BR>Compound<BR>Covariate<BR>Predictor", sep="")
    if (BccpParam & UniquePrediction & twogroup) ExpClassified[1] <- paste(ExpClassified[1],"<BR> Correct?",sep="")
    for (i in 1:(nrow(experiments))) {
      ExpClassified[i+1] <- paste(experiments[i,], collapse="<TD>")
    }
    ExpClassified[nrow(experiments)+2] <- paste(c("<tfoot>","<TR ALIGN=center><TH>Mean percent<BR>of correct<BR>classification:",
                                                  rep("&nbsp;",ifelse(SameN,ifelse(paired,2,3),ifelse(paired,1,2))), PercentCorrect, "</tfoot>"), collapse="<TH>")
    
    PrintNTable <- F
    if(!SameN & PrintNTable) {
      NTable <- as.matrix(NTable)
      NTable[,1] <- paste("<TR ALIGN=center><TH>", NTable[,1])
      NTableHTML <- rep( "", nrow(NTable)+1 )
      if(paired) {
        NTableHTML[1] <- paste("<TR><TD><BR><TH>", IdName)
      } else {
        NTableHTML[1] <- paste("<TR><TD><BR><TH>", IdName,"<TH>Class label")
      }
      if (CcpParam & twogroup) NTableHTML[1] <- paste(NTableHTML[1], "<TH>Compound<BR>Covariate<BR>Predictor", sep="")
      if (LDAParam) NTableHTML[1] <- paste(NTableHTML[1],"<TH>Diagonal Linear<BR>Discriminant<BR>Analysis", sep="")
      if (KnnParam) NTableHTML[1] <- paste(NTableHTML[1], "<TH>1-Nearest<BR>Neighbor<TH>3-Nearest<BR>Neighbors", sep="")
      if (CentroidParam) NTableHTML[1] <- paste(NTableHTML[1], "<TH>Nearest<BR>Centroid", sep="")
      if (SvmParam & twogroup) NTableHTML[1] <- paste(NTableHTML[1],"<TH>Support<BR>Vector<BR>Machines", sep="")
      if (BccpParam & twogroup) NTableHTML[1] <- paste(NTableHTML[1],"<TH>Bayesian<BR>Compound<BR>Covariate<BR>Predictor", sep="")
      for (i in 1:(nrow(experiments))) {
        NTableHTML[i+1] <- paste(NTable[i,], collapse="<TD>")
      }
    }
    
  } # end of if (generateHTML)
  
  if(NumPermutations > 0) {
    ClassifySignif <- scan(paste(WorkPath, "/PermErrorRate.txt", sep=""), what="", quiet=T,skip=1)
    ClassifySignif <- round(as.numeric(ClassifySignif), 3)
    ClassifySignif <- ClassifySignif[c(1,6,2,3,4,5,7)]
  }
  # Added Ming-chung Li 12/16/2011. Include RVM option in html
  KSwarning <- FALSE
  regparfile <- paste(WorkPath,"/RegPar.txt", sep="")
  if(codeReg && file.exists(regparfile) && length(readLines(regparfile)) > 1) {
    RegPar <- scan(regparfile,skip=1,nlines=1,quiet=T)
    RegParA <- RegPar[1]
    RegParB <- RegPar[2]
    RegParKS <- RegPar[3]
    KSwarning <- RegParKS > 0.05
  } else if (codeReg) {
    KSwarning <- TRUE
  }
  UseRVM <- 0 ; if (codeReg & !KSwarning){ UseRVM <- 1 }
  
  #
  DEGsFileName <- paste(WorkPath,"/DEGs.txt",sep="")
  BestAlphaIndex <- as.numeric(scan(DEGsFileName, nlines=1, what="", quiet=T))
  # the following happens if the method is not chosen.
  BestAlphaIndex[BestAlphaIndex == 0] <- 1
  nDEGbyMethod <- as.numeric(scan(DEGsFileName, skip=1,nlines=1, what="", quiet=T))
  # Ming-Chung 7/22/05. reorder is necessary
  BestAlphaIndex <- BestAlphaIndex[c(1,6,2,3,4,5,7)]
  nDEGbyMethod   <- nDEGbyMethod[c(1,6,2,3,4,5,7)]
  numDEGs <- max(nDEGbyMethod[methods == 1])
  
  # Predictions for new samples:
  if(numDEGs > 0 & pred.test) {
    # modified Ming-Chung Li 7/22/2005. Keep reorder
    predictions<- read.table(paste(WorkPath,
                                   "/new_prediction.txt", sep=""), header=T, comment.char="")
    BCCPProbNew <- predictions[,8]
    predictions <- predictions[,c(1,6,2,3,4,5,7)]
    # modified by Ming-Chung 3/14/2005
    #predictions.selected <- predictions[,methodsBoolean, drop = FALSE]
    predictions <- predictions[,methodsBoolean, drop = FALSE]
    AddTrueClassLabel <- FALSE
    if(paired) {
      ntests <- length(predictions[[1]])
      predictions <- predictions[rep(1:ntests,2),]
      for(i in 1:Nmethods) {
        predictions[[i]][(ntests+1):(2*ntests)]  <- (3- predictions[[i]])[(ntests+1):(2*ntests)]
        predictions[[i]][predictions[[i]] == 4] <- -1
      }
      prediction.table <- data.frame(experimentsNew$ExpId,experimentsNew$PairingVariable)
    } else {
      prediction.table <- data.frame(experimentsNew$ExpId)
    }
    if (any(ClassVariable0 != "")) {
      AddTrueClassLabel <- TRUE
      prediction.table <- cbind(data.frame(prediction.table, ClassVariable0))
    }
    for(i in 1:Nmethods) {
      predictions.current <- as.character(predictions[[i]])
      predictions.current[predictions.current == "-1"] <- "NC"
      for(gr in 1:ngroup) {
        predictions.current[predictions.current == as.character(gr)] <-
          classlabels[gr]
      }
      prediction.table <- cbind(prediction.table,predictions.current)
    }
    
    if(paired) {
      prediction.table.names <- c("ExpID","PairID",if (AddTrueClassLabel) "TrueClass","CCP","LDA","K1","K3","Centroid","SVM","BCCP")
      code <- c(T,T,if (AddTrueClassLabel) T, CcpParam & twogroup, LDAParam, KnnParam, KnnParam, CentroidParam, SvmParam & twogroup,
                BccpParam & twogroup)
    } else {
      prediction.table.names <- c("ExpID", if (AddTrueClassLabel) "TrueClass","CCP","LDA", "K1","K3","Centroid","SVM","BCCP")
      code <- c(T,if (AddTrueClassLabel) T, CcpParam & twogroup, LDAParam, KnnParam, KnnParam, CentroidParam, SvmParam & twogroup,
                BccpParam & twogroup)
    }
    names(prediction.table) <- prediction.table.names[code]
    resList <- c(resList, list(predNewSamples=prediction.table))
    
    if (generateHTML){
      prediction.table$ExpID <- paste("<TR ALIGN=center><TH>", prediction.table$ExpID )
      ntests <- length(prediction.table$ExpID)
      ExpClassifiedNew <- rep( "", ntests+1 )
      if(paired){
        ExpClassifiedNew[1] <- paste("<BR><TH> Array ID <TH>", IdName)
      }else{
        ExpClassifiedNew[1] <- paste("<BR><TH>", IdName)
      }
      if (AddTrueClassLabel) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1], "<TH>True Class", sep="")
      # Keep the prediction order the same as in the CV. Ming-Chung
      if (CcpParam & twogroup) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1], "<TH>Compound<BR>Covariate<BR>Predictor", sep="")
      if (LDAParam) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1],"<TH>Linear<BR>Discriminant<BR>Analysis", sep="")
      if (KnnParam) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1], "<TH>1-Nearest<BR>Neighbor<TH>3-Nearest<BR>Neighbors", sep="")
      if (CentroidParam) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1], "<TH>Nearest<BR>Centroid", sep="")
      if (SvmParam & twogroup) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1],"<TH>Support<BR>Vector<BR>Machines", sep="")
      if (BccpParam & twogroup) ExpClassifiedNew[1] <- paste(ExpClassifiedNew[1],"<TH>Bayesian<BR>Compound<BR>Covariate<BR>Predictor", sep="")
      
      if(ntests > 1) {
        prediction.table <- as.matrix(prediction.table)
        for (i in 1:ntests) {
          ExpClassifiedNew[i+1] <- paste(prediction.table[i,], collapse="<TD>")
        }
      } else {
        for(i in 1:length(prediction.table) ) {
          prediction.table[[i]] <- as.character(prediction.table[[i]])
        }
        ExpClassifiedNew[2] <- paste(prediction.table, collapse="<TD>")
      }
    } # end of html
  } # End of if(pred.test) part
  
  GoodRun <- T
  if (numDEGs == 0) {
    cat("No genes were selected;  predictors are undefined.",file=ExternalFileName)
    GoodRun <- F
  } else {
    classifiers <- read.table(file=DEGsFileName,header=F, skip=2)
    #if (Rfe == 1) {
    #   featlist <- read.table(paste(WorkPath,"/featlist.txt", sep=""), header = FALSE)
    #   # classifiers <- classifiers[match(featlist[,1], classifiers[,1]), , drop = FALSE]
    #}
    names(classifiers) <- c("index","t","pvalue","GeneCode")
    classifiers <- classifiers[,c(1,4,2,3)]
    CVsupport <- read.table(file=paste(WorkPath,"/CVsupport.txt",sep=""),header=F,skip=1)
    if(any(CVsupport[,1] != classifiers$index) ){
      winDialog(type="ok",
                message="R ERROR: CVsupport and nDEG files have different index column.")
      cat("R ERROR: CVsupport.txt and nDEG.txt files have different index column.",
          file=ExternalFileName)
      GoodRun <- F
    }
    if(any(CVsupport[,2] != classifiers$GeneCode) ){
      winDialog(type="ok",
                message="R ERROR: CVsupport and nDEG files have different GeneCode column.")
      cat("R ERROR: CVsupport.txt and nDEG.txt files have different GeneCode column.",
          file=ExternalFileName)
      GoodRun <- F
    }
    CVsupport <- CVsupport[,c(3,8,4,5,6,7,9)]
    # Modified by Ming-Chung 3/14/2005
    CVsupport.selected <- CVsupport[,methodsBoolean, drop = FALSE]
    if (nrow(classifiers) != numDEGs) {
      winDialog(type="ok",
                message="R ERROR: Error reading classifiers from Fortran output.")
      cat("R ERROR: Error reading classifiers from Fortran output.",
          file=ExternalFileName)
      GoodRun <- F
    }
  } # end of if (numDEGs == 0)
  
  # Write tables
  if (GoodRun) {
    ## WRITE OUTPUT:
    if (GenesOrPairs == 2) {
      genepairIndex <- read.table(paste(WorkPath, "/genepair.txt", sep=""), header = FALSE)
      genepairIndex <- as.vector(t(genepairIndex))
    } else genepairIndex <- NULL
    # genepairIndex will be implicitly passed to GetGenesHTML().
    GetGenesHTMLOutput <- classpredict:::GetGenesHTML(index=classifiers$index,
                                       classlabels=classlabels,
                                       paired=paired, WorkPath=WorkPath,
                                       #                                      IsSingleChannel = IsSingleChannel,
                                       AnalysisType = AnalysisType,
                                       SameN = SameN,
                                       classifiers = classifiers,
                                       LogBase = LogBase,
                                       methods = methods,
                                       CVsupport = CVsupport,
                                       GeneListFileName = GeneListFileName,
                                       ProjectPath = ProjectPath,
                                       AnalysisName = AnalysisName,
                                       ArrayToolsPath = ArrayToolsPath,
                                       genepairIndex = genepairIndex)
    # Added by Ting
    classifierTable <- GetGenesHTMLOutput$GeneIdForIngenuity
    names(classifierTable) <- gsub("<NOBR>|</NOBR>|<BR>","",names(classifierTable))
    # replace class i with correpsonding class labels for better understanding
    for (i in 1:length(classlabels)){
      names(classifierTable) <- gsub(paste("class  ", i, sep = ''), classlabels[i], names(classifierTable))
    }
    rownames(classifierTable) <- as.character(1:nrow(classifierTable))
    resList <- c(resList, list(classifierTable=classifierTable))
    # End by Ting
    
    if (generateHTML) {
      
      cat(
        "<!-- This is an HTML document.  Please make sure the filename has either"
        , "     an .htm or .html extension, and view this file in a web browser. -->"
        , ""
        , "<HTML>"
        , "<HEAD>"
        , "<TITLE>Class Prediction Results</TITLE>"
        , "<STYLE>"
        , "P {font-size: 9pt}"
        , "TABLE {font-size: 9pt}"
        , "</STYLE>"
        , paste("<script src='file:///", "sorttable.js'></script>", sep="") #Qian 5/29/09 sortable
        , "</HEAD>"
        , "<BODY>"
        , "<SCRIPT>"
        , "function popUp(text) {"
        , "   var prop ="
        , "   \"location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes\";"
        , "   popup = window.open(\"\",\"mywin\",prop);"
        , "   popup.document.open();"
        , "   popup.document.write(text);"
        , "   popup.document.close();"
        , "   popup.focus();"
        , "   }"
        , "   </SCRIPT>"
        , "<script language='JavaScript' type='text/javascript'>"
        , "function check_value(fieldvalue)"
        , "{    "
        , "switch(fieldvalue)"
        , "	{"
        , "   case 1:"
        , "       document.getElementById('imagedest').innerHTML = \"<img src='roc_all.png'>\";"
        , "           break;"
        , "   case 2:"
        , "       document.getElementById('imagedest').innerHTML = \"<img src='roc_ccp.png'>\";"
        , "           break;"
        , "   case 3:"
        , "       document.getElementById('imagedest').innerHTML = \"<img src='roc_dlda.png'>\";"
        , "           break;"
        , "   case 4:"
        , "       document.getElementById('imagedest').innerHTML = \"<img src='roc_bccp.png'>\";"
        , "           break;"
        , "	}"
        , "}"
        , "</script>"
        , "<H2 align=\"center\"> Class Prediction using Multiple Methods</H2>"
        #      , "<H3>Contents </H3>"
        #      , "<ul>"
        #      , "<li><a href=\"#Description\"><b>Description of the problem</b></a></li>"
        #      , "<li><a href=\"#performance\"><b>Performance of classifiers during cross-validation</b></a></li>"
        #      , if (BccpParam & UniquePrediction & twogroup) "<li><a href=\"#predprob\"><b>Predicted probability of samples during CV from the Bayesian Compound Covariate</b></a></li>"
        #      , if (!paired & (CentroidParam | (SvmParam & twogroup) | (BccpParam & twogroup) | KnnParam | LDAParam | (CcpParam & twogroup))) "<li><a href=\"#sensitivity\"><b>Sensitivity and specificity during cross-validation</b></a></li>"
        #      , "<li><a href=\"#classifier\"><b>Composition of classifier</b></a></li>"
        #      , if (ngroup == 2 & !paired & (CcpParam | LDAParam | SvmParam)) "<li><a href=\"#rule\"><b>Prediction rule from the linear predictors</b></a></li>"
        #      , "<li><a href=\"#centroid\"><b>Centroid of each class</b></a></li>"
        #      , "<li><a href=\"#roc\"><b>Cross-validation ROC curves</b></a></li>"
        #      , "</ul>"
        , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
        , "<P>"
        , paste("<P><a name=\"Description\"><H3><B><U>Description of the problem:</U></B></H3>")
        , "<P>"
        , paste("Number of classes:",ngroup)
        , ifelse(codeReg & !KSwarning, paste("<BR>Number of genes used for random variance estimation:",GenesTotal, "<BR>"), "<BR>")
        , paste("Number of genes that passed filtering criteria:",nspot )
        , "<BR>"
        , paste("Column of the Experiment Descriptors sheet that defines class variable: ",ClassVariable)
        , "<BR>"
        , if (!paired) paste("Number of arrays in each class: ", paste(groupsize, "in class label<I>", classlabels, "</I>", collapse=", "))
        # Ming-chung add a statement if RVM was not selected. 12/16/2011
        , if (!codeReg) paste("<BR>Random variance model for univariate tests: OFF")
        , ifelse(codeReg & !KSwarning, "<BR> Random Variance Model was used <BR>", "<BR>")
        , if (KSwarning) paste("WARNING: Distribution assumptions underlying the random variance model are not satisfied. Random variance model was not used. ", if (exists("RegParKS")) paste("Kolmogorov-Smirnov statistic=", RegParKS), sep=" ")
        , if (any(methods[c(1,6,7)] == 1) & ngrp > 2)
          c(paste(c("Compound covariate", "SVM", "Bayesian compound covaraite")[methods[c(1,6,7)]==1], collapse=", "),
            if (sum(methods[c(1,6,7)]) == 1) "method was" else "methods were",
            "not performed since there are more than 2 classes in the class variable")
        , paste("<P><B><U>Feature selection criteria:</U></B>")
        ," ", file=ExternalFileName, sep="\n", append=F)
      
      if(GenesOrPairs == 1) {
        if(GeneSelectionMethod == 1) cat(paste("<BR>Genes significantly",
                                               "different between the classes at", tAlpha,"significance level",
                                               "were used for class prediction.")
                                         ," ", file=ExternalFileName, sep="\n", append=T)
        if(GeneSelectionMethod == 2) {
          cat(paste("<BR>Genes significantly",
                    "different between the classes at the 0.01, 0.005, 0.001 and 0.0005",
                    "significance levels were used to build four predictors. The predictor",
                    "with the lowest cross-validation mis-classification rate",
                    "was selected.")
              ," ", file=ExternalFileName, sep="\n", append=T)
          AlphaGrid <- c(0.01,0.005,0.001,0.0005)
          SameBestLevel <- length(unique(BestAlphaIndex[methodsBoolean])) == 1
          if(SameBestLevel) {
            cat(paste("The best predictor consisted of genes significantly",
                      "different between the classes at the",
                      AlphaGrid[unique(BestAlphaIndex[methodsBoolean])],
                      "significance level.")
                ," ", file=ExternalFileName, sep="\n", append=T)
            
          } else {
            if (CcpParam & twogroup)
              cat(paste("The best compound covariate classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[1]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (LDAParam)
              cat(paste("The best diagonal linear discriminant analysis classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[2]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (KnnParam )
              cat(paste("The best 1-nearest neighbor classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[3]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (KnnParam )
              cat(paste("The best 3-nearest neighbors classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[4]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (CentroidParam)
              cat(paste("The best nearest centroid classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[5]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (SvmParam & twogroup)
              cat(paste("The best support vector machines classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[6]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
            if (BccpParam & twogroup)
              cat(paste("The best Bayesian compound covariate classifier consisted of ",
                        "genes significantly different between the classes at the",
                        AlphaGrid[BestAlphaIndex[7]],"significance level.")
                  ," ", file=ExternalFileName, sep="\n", append=T)
          }
        }
        if(GeneSelectionMethod == 3) cat(paste("<BR>Genes with univariate mis-classfication",
                                               "rate below", MisClassLevel, "were used for class prediction.")
                                         ," ", file=ExternalFileName, sep="\n", append=T)
        if(UseFoldDiff== 1) cat(paste("<BR>Only genes with the fold-difference between the",
                                      "two classes exceeding", FoldDiffLevel, "were used for class prediction.")
                                ," ", file=ExternalFileName, sep="\n", append=T)
        
      } else if(GenesOrPairs == 2) {
        cat(paste("<BR>Greedy pairs algorithm was used to select",
                  NPairs, "pairs of genes.")
            ," ", file=ExternalFileName, sep="\n", append=T)
      } else if (Rfe == 1) {
        cat(paste("<BR>Recursive Feature Elimination method was used to select", nfeatures,
                  "genes.")," ", file=ExternalFileName, sep="\n", append=T)
      }
      
      cat("<P><B><U>Cross-validation method:</U></B>"
          ," ", file=ExternalFileName, sep="\n", append=T)
      
      if(CrossValidationMethod == 1) cat(paste("<BR>Leave-one-out cross-validation",
                                               "method was used to compute mis-classification rate.")
                                         ," ", file=ExternalFileName, sep="\n", append=T)
      if(CrossValidationMethod == 2) cat(paste("<BR>Repeated",KFoldTimes,"times K-fold",
                                               "(K=", KFoldValue, ") cross-validation",
                                               "method was used to compute mis-classification rate.")
                                         ," ", file=ExternalFileName, sep="\n", append=T)
      if(CrossValidationMethod == 3) cat(paste("<BR>0.632+ bootstrap cross-validation",
                                               "method was used to compute mis-classification rate.")
                                         ," ", file=ExternalFileName, sep="\n", append=T)
      
      if (NumPermutations > 0) {
        ppval <- NULL
        namesppval <- NULL
        cat("<BR><BR>", paste("Based on", NumPermutations, "random permutations,")
            ," ", file=ExternalFileName, sep="\n", append=T)
        if (CcpParam & twogroup){ cat(
          "<BR>", paste("the compound covariate predictor has p-value of",
                        format.pval(ClassifySignif[1], eps=1/NumPermutations))
          ," ", file=ExternalFileName, sep="\n", append=T)
          ppval <- c(ppval, ClassifySignif[1])
          namesppval <- c(namesppval, "CCP")
        }
        if (LDAParam){ cat(
          "<BR>",paste("the diagonal linear discriminant analysis classifier has p-value of",
                       format.pval(ClassifySignif[2], eps=1/NumPermutations))
          ," ", file=ExternalFileName, sep="\n", append=T)
          ppval <- c(ppval, ClassifySignif[2])
          namesppval <- c(namesppval, "DLDA")
        }
        if (KnnParam){ cat(
          "<BR>",paste("the 1-nearest neighbor classifier has p-value of",
                       format.pval(ClassifySignif[3], eps=1/NumPermutations))
          , "<BR>"
          , paste("the 3-nearest neighbors classifier has p-value of",
                  format.pval(ClassifySignif[4], eps=1/NumPermutations))
          , " ",file=ExternalFileName, sep="\n", append=T)
          
          ppval <- c(ppval, ClassifySignif[3])
          namesppval <- c(namesppval, "1NN")
          
          ppval <- c(ppval, ClassifySignif[4])
          namesppval <- c(namesppval, "3NN")
          
        }
        if (CentroidParam){ cat(
          "<BR>",paste("the nearest centroid classifier has p-value of",
                       format.pval(ClassifySignif[5], eps=1/NumPermutations))
          ," ", file=ExternalFileName, sep="\n", append=T)
          ppval <- c(ppval, ClassifySignif[5])
          namesppval <- c(namesppval, "NC")
        }
        if (SvmParam & twogroup){ cat(
          "<BR>",paste("the support vector machines classifier has p-value of",
                       format.pval(ClassifySignif[6], eps=1/NumPermutations))
          ," ", file=ExternalFileName, sep="\n", append=T)
          ppval <- c(ppval, ClassifySignif[6])
          namesppval <- c(namesppval, "SVM")
        }
        if (BccpParam & twogroup){ cat(
          "<BR>",paste("the Bayesian compound covariate classifier has p-value of",
                       format.pval(ClassifySignif[7], eps=1/NumPermutations))
          ," ", file=ExternalFileName, sep="\n", append=T)
          ppval <- c(ppval, ClassifySignif[7])
          namesppval <- c(namesppval, "BCCP")
        }
        names(ppval) <- namesppval
        resList <- c(resList, list(ppval=ppval))
      }
      if ((CcpParam | BccpParam) & twogroup) {
        cat("<BR><BR>Note<BR>T-values used for the (Bayesian) compound covariate predictor were truncated at abs(t)=10 level.<BR>"
            , file=ExternalFileName, sep="\n", append=T)
      }
      if (BccpParam & twogroup) {
        if (poption == 1) {
          cat(
            "Equal class prevalences is used in the Bayesian compound covariate predictor.<BR>"
            , file=ExternalFileName, sep="\n", append=T)
        } else  cat(
          "Class prevalences shown as in the training set is used in the Bayesian compound covariate predictor.<BR>"
          , file=ExternalFileName, sep="\n", append=T)
        cat("Threshold of predicted probability for a sample being predicted to a class from the Bayesian compound covariate predictor", pthresh, ".<BR>"
            , file=ExternalFileName, sep="\n", append=T)
      }
      if (paired) # TING 11/1/2017
        cat("Prediction results are based on data for each pair ID.<BR>", file=ExternalFileName, sep="\n", append=T)
      cat("</P>"
          , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
          , "<P><a name=\"performance\"><H3><B><U>Performance of classifiers during cross-validation.</U></B></H3>"
          , ifelse(UniquePrediction,"<BR>",
                   paste("<BR>Presented are percents of correct predictions among ",
                         "all cross-validation predictions for each sample"))
          , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
          , ExpClassified
          , "</TABLE>"
          , file=ExternalFileName, sep="\n", append=T)
      if (printNA) cat("</BR>Note: NA denotes the sample is unclassified. These samples are excluded in the compuation of the mean percent of correct classification", file=ExternalFileName, sep="\n", append=T)
      # added GenesOrPairs==1, Yong 07/27/2006
      # Comment: GeneSelectionMethod keeps the most recent value while it should be
      # reset to the default when [Individual genes] NOT being selected
      if(GenesOrPairs == 1 && GeneSelectionMethod == 2) {
        ErrorRateAlpha <- read.table(paste(WorkPath,
                                           "/errorRateAlpha.txt", sep=""), header=T)
        ErrorRateAlpha  <- t(ErrorRateAlpha[,c(1,6,2,3,4,5,7)])
        ErrorRateAlphaComb <- cbind(ErrorRateAlpha,t(MeanErrorRate))
        ErrorRateAlphaComb <- as.matrix(round(ErrorRateAlphaComb,3))
        
        ErrorRateTable.first <- paste( "<TR ALIGN=center><TH>",
                                       c("<TH>Compound<BR>Covariate<BR>Predictor",
                                         "<TH>Diagonal Linear<BR>Discriminant<BR>Analysis",
                                         "<TH>1-Nearest<BR>Neighbor",
                                         "<TH>3-Nearest<BR>Neighbors",
                                         "<TH>Nearest<BR>Centroid",
                                         "<TH>Support<BR>Vector<BR>Machines",
                                         "<TH>Bayesian<BR>CCP"), sep="")
        ErrorRateAlphaComb <- cbind(ErrorRateTable.first,ErrorRateAlphaComb,
                                    AlphaGrid[BestAlphaIndex])
        ErrorRateHTML <-rep("",8)
        # Add 'Optimized level' column, Ming-Chung Li 11/9/2004
        ErrorRateHTML[1] <- paste( "<TR ALIGN=center><TH>","<B>Significance Level:</B>",
                                   "<B>0.01</B>", "<B>0.005</B>", "<B>0.001</B>", "<B>0.0005</B>",
                                   "<B>Optimized error rate</B>", "<B>Optimal level</B>", sep="<TD>")
        for (i in 1:7) {
          ErrorRateHTML[i+1] <- paste(ErrorRateAlphaComb[i,], collapse="<TD>")
        }
        ErrorRateHTML<- ErrorRateHTML[c(T,methods == 1)]
        cat("</P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , "<P><B><U>Cross-Validation Error Rate (for the grid of signifciance levels and optimized):</U></B></P>"
            , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
            , ErrorRateHTML
            , "</TABLE>"
            , file=ExternalFileName, sep="\n", append=T)
        
      }
      
      if(!SameN & PrintNTable) {
        cat("</P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , "<P><B><U>Mean number of genes in the classifiers during cross-validation:</U></B></P>"
            , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
            , NTableHTML
            , "</TABLE>"
            , file=ExternalFileName, sep="\n", append=T)
      }
    } # end of html
    
    # Add the probability of classifying the training set in each class for the Bayesian CCP
    if (BccpParam & UniquePrediction & twogroup) {
      if (generateHTML){
        ProbHTML <- rep("", nrow(experiments)+1)
        ProbHTML[1] <- paste("<TR><TH><BR><TH>", IdName, "<TH>Class label<TH>Probability</TH></TR>\n")
        for(i in 1:nrow(experiments)) {
          ProbHTML[i+1] <- paste("<TR><TD><B>", i, "</B></TD><TD>", TrainingExpId[i], "</TD><TD>",
                                 groupid[i], "</TD><TD>",
                                 ifelse(BCCPProb[i] >= 10^(-3), round(BCCPProb[i],3), "p < 1.0e-3"),
                                 "</TD></TR>\n")
        }
        cat("</P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , paste("<P><a name=\"predprob\"><H3><B><U>Predicted probability of each sample belonging to the class ",
                    paste("(", classlabels[1], ")", sep = ""),
                    "during cross-validation from the Bayesian Compound Covariate:</U></B></H3></P>")
            , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
            , ProbHTML
            , "</TABLE>"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      
      probInClass <- data.frame(TrainingExpId,groupid, ifelse(BCCPProb >= 10^(-3), round(BCCPProb,3), "p < 1.0e-3"))
      names(probInClass) <- c("Array id", "Class label", "Probability")
      resList <- c(resList, list(probInClass=probInClass))
      
    }
    
    #   Output separate performance tables, one per each of the prediction methods:
    if(paired == 0) {
      SensitivityData <- read.table(paste(WorkPath,"/SensitivityData.txt", sep=""), header=T)
      #     Reorder methods as needed for tables:
      
      SensitivityData  <- SensitivityData[,c(1,2,7,3,4,5,6,8)]
      if (generateHTML){
        cat("</P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , paste("<P><a name=\"sensitivity\"><H3><B>Sensitivity and specificity during cross-valudation:</B></H3></P>")
            , "<P>Let, for some class A,"
            , "<BR>&nbsp; &nbsp; &nbsp; n11 = number of class A samples predicted as A"
            , "<BR>&nbsp; &nbsp; &nbsp; n12 = number of class A samples predicted as non-A "
            , "<BR>&nbsp; &nbsp; &nbsp; n21 = number of non-A samples predicted as A"
            , "<BR>&nbsp; &nbsp; &nbsp; n22 = number of non-A samples predicted as non-A"
            , "<BR> Then the following parameters can characterize performance of classifiers:"
            , "<BR> &nbsp; &nbsp; &nbsp; Sensitivity = n11/(n11+n12)"
            , "<BR> &nbsp; &nbsp; &nbsp; Specificity = n22/(n21+n22)"
            #      , "<BR> &nbsp; &nbsp; &nbsp; Positive Predictive Value (PPV) =  n11/(n11+n21)"
            #      , "<BR> &nbsp; &nbsp; &nbsp; Negative Predictive Value (NPV) =  n22/(n12+n22)"
            , "<BR> &nbsp; &nbsp; &nbsp; Positive Predictive Value (PPV) =  Sensitivity*Prevalence/(Sensitivity*Prevalence+(1-Specificity)*(1-Prevalence))"
            , "<BR> &nbsp; &nbsp; &nbsp; Negative Predictive Value (NPV) =  Specificity*(1-Prevalence)/((1-Sensitivity)*Prevalence+Specificity*(1-Prevalence))"
            , "<BR> Sensitivity is the probability for a class A sample to be correctly predicted as class A,"
            , "<BR> Specificity is the probability for a non class A sample to be correctly predicted as non-A,"
            , "<BR> PPV is the probability that a sample predicted as class A actually belongs to class A,"
            , "<BR> NPV is the probability that a sample predicted as non class A actually does not belong to class A."
            , "<BR> Note that positive and negative predictive values are influenced by class prevalences. "
            , paste("<BR> Prevalence for class ",paste(classlabels, sep=",")," are ",paste(round(prevalence,6), sep=","), ".",sep="")
            , "<BR>For each classification method and each class, these parameters are listed in the tables below"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      
      if (CcpParam & twogroup) {
        
        # PPV and NPV are influenced by the prevalence of disease.
        for (i in 1:2){
          SensitivityData[i+4,2] <- SensitivityData[i,2]*prevalence[i]/(SensitivityData[i,2]*prevalence[i]+(1-SensitivityData[i+2,2])*(1-prevalence[i])) #PPV
          SensitivityData[i+6,2] <- SensitivityData[i+2,2]*(1-prevalence[i])/((1-SensitivityData[i,2])*prevalence[i]+SensitivityData[i+2,2]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,2)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the Compound Covariate Predictor Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        
        CCPSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,2)],classlabels,groupid)$table
        CCPSenSpec$Class <- classlabels[CCPSenSpec$Class]
        resList <- c(resList, list(CCPSenSpec=CCPSenSpec))
      }
      if (LDAParam) {
        
        # PPV and NPV are influenced by the prevalence of disease.
        for (i in 1:ngroup){
          SensitivityData[i+ngroup*2,3] <- SensitivityData[i,3]*prevalence[i]/(SensitivityData[i,3]*prevalence[i]+(1-SensitivityData[i+ngroup,3])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,3] <- SensitivityData[i+ngroup,3]*(1-prevalence[i])/((1-SensitivityData[i,3])*prevalence[i]+SensitivityData[i+ngroup,3]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,3)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the Diagonal Linear Discriminant Analysis Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } #end of html
        LDASenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,3)],classlabels,groupid)$table
        LDASenSpec$Class <- classlabels[LDASenSpec$Class]
        resList <- c(resList, list(LDASenSpec=LDASenSpec))
      }
      if (KnnParam) {
        
        for (i in 1:ngroup){
          SensitivityData[i+ngroup*2,4] <- SensitivityData[i,4]*prevalence[i]/(SensitivityData[i,4]*prevalence[i]+(1-SensitivityData[i+ngroup,4])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,4] <- SensitivityData[i+ngroup,4]*(1-prevalence[i])/((1-SensitivityData[i,4])*prevalence[i]+SensitivityData[i+ngroup,4]*(1-prevalence[i])) #NPV
          SensitivityData[i+ngroup*2,5] <- SensitivityData[i,5]*prevalence[i]/(SensitivityData[i,5]*prevalence[i]+(1-SensitivityData[i+ngroup,5])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,5] <- SensitivityData[i+ngroup,5]*(1-prevalence[i])/((1-SensitivityData[i,5])*prevalence[i]+SensitivityData[i+ngroup,5]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,4)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the 1-Nearest Neighbor Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
          
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,5)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the 3-Nearest Neighbors Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        
        K1NNSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,4)],classlabels,groupid)$table
        K1NNSenSpec$Class <- classlabels[K1NNSenSpec$Class]
        resList <- c(resList, list(K1NNSenSpec=K1NNSenSpec))
        
        K3NNSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,5)],classlabels,groupid)$table
        K3NNSenSpec$Class <- classlabels[K3NNSenSpec$Class]
        resList <- c(resList, list(K3NNSenSpec=K3NNSenSpec))
      }
      if (CentroidParam) {
        
        for (i in 1:ngroup){
          SensitivityData[i+ngroup*2,6] <- SensitivityData[i,6]*prevalence[i]/(SensitivityData[i,6]*prevalence[i]+(1-SensitivityData[i+ngroup,6])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,6] <- SensitivityData[i+ngroup,6]*(1-prevalence[i])/((1-SensitivityData[i,6])*prevalence[i]+SensitivityData[i+ngroup,6]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,6)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the Nearest Centroid Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        
        CentroidSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,6)],classlabels,groupid)$table
        CentroidSenSpec$Class <- classlabels[CentroidSenSpec$Class]
        resList <- c(resList, list(CentroidSenSpec=CentroidSenSpec))
      }
      if (SvmParam & twogroup) {
        
        for (i in 1:length(classlabels)){
          SensitivityData[i+ngroup*2,7] <- SensitivityData[i,7]*prevalence[i]/(SensitivityData[i,7]*prevalence[i]+(1-SensitivityData[i+ngroup,7])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,7] <- SensitivityData[i+ngroup,7]*(1-prevalence[i])/((1-SensitivityData[i,7])*prevalence[i]+SensitivityData[i+ngroup,7]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <-classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,7)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the Support Vector Machine Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        SVMSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,7)],classlabels,groupid)$table
        SVMSenSpec$Class <- classlabels[SVMSenSpec$Class]
        resList <- c(resList, list(SVMSenSpec=SVMSenSpec))
      }
      if (BccpParam & twogroup) {
        
        for (i in 1:length(classlabels)){
          SensitivityData[i+ngroup*2,8] <- SensitivityData[i,8]*prevalence[i]/(SensitivityData[i,8]*prevalence[i]+(1-SensitivityData[i+ngroup,8])*(1-prevalence[i])) #PPV
          SensitivityData[i+ngroup*3,8] <- SensitivityData[i+ngroup,8]*(1-prevalence[i])/((1-SensitivityData[i,8])*prevalence[i]+SensitivityData[i+ngroup,8]*(1-prevalence[i])) #NPV
        }
        
        if (generateHTML){
          PerfTable <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,8)],classlabels,groupid)$HTMLtable
          cat("</P>"
              , "<P><B><U>Performance of the Bayesian Compound Covariate Classifier:</U></B></P>"
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , PerfTable
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        BCPPSenSpec <- classpredict:::Create.Class.Description.Table(SensitivityData[,c(1,8)],classlabels,groupid)$table
        BCPPSenSpec$Class <- classlabels[BCPPSenSpec$Class]
        resList <- c(resList, list(BCPPSenSpec=BCPPSenSpec))
      }
    } # end of if(paired == 0)
    
    
    if(pred.test) {
      if (generateHTML){
        cat("</P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , "<P><B><U>Predictions of classifiers for new samples:</U></B></P>"
            , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
            , ExpClassifiedNew
            , "</TABLE>"
            , "<P>NC = Not Classified</P>"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      if (BccpParam & UniquePrediction & twogroup) {
        if (generateHTML){
          ProbHTMLNew <- rep("", ntests + 1)
          ProbHTMLNew[1] <- paste("<TR><TH>", IdName, "<TH>Probability</TH></TR>\n")
          for(i in 1:ntests) {
            ProbHTMLNew[i+1] <- paste("<TR><TD><B>", PredictExpId[i], "</B></TD><TD>",
                                      ifelse(BCCPProbNew[i] >= 10^(-3), round(BCCPProbNew[i],3), "p < 1.0e-3"),
                                      "</TD></TR>\n")
          }
          cat("</P>"
              , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
              , paste("<P><B><U>Predicted probability of each new sample belonging to the class ",
                      paste("(", classlabels[1], ")", sep = ""),
                      "from the Bayesian Compound Covariate:</U></B></P>")
              , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
              , ProbHTMLNew
              , "</TABLE>"
              , file=ExternalFileName, sep="\n", append=T)
        } # end of html
        
        probNew <- data.frame(PredictExpId, rep(classlabels[1], length(PredictExpId)), ifelse(BCCPProbNew >= 10^(-3), round(BCCPProbNew,3), "p < 1.0e-3"))
        names(probNew) <- c("Array id", "Class", "Probability")
        resList <- c(resList, list(probNew = probNew))
      }
    } # end of if (pred.test)
    
    ####### BEGIN SECTION TO WRITE NETAFFX BATCH QUERY LINKS
    if (generateHTML){
      CreateNetAffxBatchQuery <- F
      
      if (CreateNetAffxBatchQuery) {
        ProbeSets <- GetGenesHTMLOutput$ProbeSets
        if ( sum(!is.na(ProbeSets)) > 0 ) {
          #INSERT LINKS FOR BATCH QUERY OF NETAFFX.
          NumProbeSets <- length(ProbeSets)
          ChunkSize <- 50
          NumChunks <- ceiling(NumProbeSets/ChunkSize)
          
          cat("<P>",  file=ExternalFileName, sep="\n", append=T)
          if (NumChunks==1) {
            CreateNetAffxBatchLinks(1, NumProbeSets, T)
          } else {
            for (i in 1:(NumChunks-1)) CreateNetAffxBatchLinks((i-1)*ChunkSize+1, i*ChunkSize, F)
            CreateNetAffxBatchLinks((NumChunks-1)*ChunkSize+1, NumProbeSets, T)
          }
          cat("</P>",  file=ExternalFileName, sep="\n", append=T)
        }
      }
      ####### END SECTION TO WRITE NETAFFX BATCH QUERY LINKS
      if(SameN) {
        cat("<P></P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , paste("<P><a name=\"classifier\"><H3><B><U>Composition of classifier:</U></B></H3></P>", sep="")
            #, if (is.null(genepairIndex)) {
            , paste("<P><B><U>Table</U> - Sorted by",ifelse(paired | ngroup==2,"t","p"),"-value:</B></P>") #Lori 09/08/2017
            #} else {
            #paste("<P><B><U>Table</U> - Sorted by", ifelse(paired | ngroup==2,"t","p"), "-value:",
            #      "<a href=\"", ExternalFileNamePair, "\">(Sorted by gene pairs)</a>",
            #      "</B></P>")
            #}
            , ifelse(!paired, classpredict:::outputClassname(classlabels), "") # Yong added 12/15/06
            , GetGenesHTMLOutput$GeneId1 #Qian 6/2/09
            , file=ExternalFileName, sep="\n", append=T)
        #
        # # create gene table sorted by t or p
        # if (!is.null(genepairIndex)) {
        #    cat("<HTML>"
        #    , "<HEAD>"
        #    , "<TITLE>Class Prediction</TITLE>"
        #    , "<STYLE>"
        #    , "P {font-size: 9pt}"
        #    , "TABLE {font-size: 9pt}"
        #    , "</STYLE>"
        #    , paste("<script src='file:///", "sorttable.js'></script>", sep="") #Qian 5/29/09 sortable
        #    , "</head>" #Qian 5/29/09
        #    , paste("<P><B><U>Composition of classifier from Class Prediction Analysis:</U></B></P>", sep="")
        #    , paste("<P><B><U>Table</U> - Sorted by gene pairs:</B></P>")
        #    , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
        #    , "<CAPTION ALIGN=left></CAPTION>"
        #    , GetGenesHTMLOutput$GeneIdPair
        #    , "</TABLE>\n</Body>\n</HTML>"
        #    , file=ExternalFileNamePair, sep="\n", append= FALSE)
        # }
        #
        # if(paired) { cat(
        #       paste("<P><B><U>Table</U> - Sorted by mean difference:</B></P>")
        #    , "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
        #    , "<CAPTION ALIGN=left></CAPTION>"
        #    , GetGenesHTMLOutput$GeneId2
        #    , "</TABLE>"
        #    , file=ExternalFileNamePair, sep="\n", append=T)
        # }
      } else {
        cat("<P></P>"
            , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , paste("<P><a name=\"classifier\"><B><U>Composition of classifier:</U></B></P>", sep="")
            , paste("<P><B><U>Table</U> - Sorted by p-value:</B>")
            , file=ExternalFileName, sep="\n", append=T)
        if (CcpParam & twogroup) cat("<BR>"
                                     , paste("The first",nDEGbyMethod[1],
                                             "genes were used to build the Compound Covariate Predictor",
                                             "(based on", AlphaGrid[BestAlphaIndex[1]],"significance level).")
                                     , file=ExternalFileName, sep="\n", append=T)
        if (LDAParam) cat("<BR>"
                          , paste("The first",nDEGbyMethod[2],
                                  "genes were used to build the Diagonal Linear Discriminant Analysis Predictor",
                                  "(based on", AlphaGrid[BestAlphaIndex[2]],"significance level).")
                          , file=ExternalFileName, sep="\n", append=T)
        if (KnnParam) cat("<BR>"
                          , paste("The first",nDEGbyMethod[3],
                                  "genes were used to build the 1-Nearest Neighbor Predictor",
                                  "(based on", AlphaGrid[BestAlphaIndex[3]],"significance level).")
                          , file=ExternalFileName, sep="\n", append=T)
        if (KnnParam) cat("<BR>"
                          , paste("The first",nDEGbyMethod[4],
                                  "genes were used to build the 3-Nearest Neighbors Predictor",
                                  "(based on", AlphaGrid[BestAlphaIndex[4]],"significance level).")
                          , file=ExternalFileName, sep="\n", append=T)
        if (CentroidParam) cat("<BR>"
                               , paste("The first",nDEGbyMethod[5],
                                       "genes were used to build the Nearest Centroid Predictor",
                                       "(based on", AlphaGrid[BestAlphaIndex[5]],"significance level).")
                               , file=ExternalFileName, sep="\n", append=T)
        # Fix the next line 6/26/06
        if (SvmParam & twogroup) cat("<BR>"
                                     , paste("The first",nDEGbyMethod[6],
                                             "genes were used to build the Support Vector Machines Predictor",
                                             "(based on", AlphaGrid[BestAlphaIndex[6]],"significance level).")
                                     , file=ExternalFileName, sep="\n", append=T)
        if (BccpParam & twogroup) cat("<BR>"
                                      , paste("The first",nDEGbyMethod[7],
                                              "genes were used to build the Bayesian Compound Covariate Predictor",
                                              "(based on", AlphaGrid[BestAlphaIndex[7]],"significance level).")
                                      , file=ExternalFileName, sep="\n", append=T)
        cat("<table border='1' class='sortable'>" #Qian 5/29/09 sortable
            , "<CAPTION ALIGN=left></CAPTION>"
            , GetGenesHTMLOutput$GeneId1
            , "</TABLE>"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of if (SameN)
      
      if (DoGOOvE & length(GetGenesHTMLOutput$OEhtml) > 1){   #LG modified 11/7/03.
        cat( "<P></P>"
             , "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
             , "<P></P><B><U>"
             , paste("'Observed v. Expected' table of GO classes and parent classes,",
                     "in list of", length(classifiers$Index), "genes shown above:")
             , "</U></B><P></P>"
             , GetGenesHTMLOutput$OEhtml
             , file=ExternalFileName, sep="\n", append=T
        )
      }
      
    } # end of html
    
    # add weights to the html output
    if (ngroup == 2 & !paired & (CcpParam | LDAParam | SvmParam))  {
      wccp <- scan(paste(WorkPath, "Weights.txt", sep="/"), nlines=1, skip=0, quiet=T)
      wdlda <- scan(paste(WorkPath, "Weights.txt", sep="/"), nlines=1, skip=2, quiet=T)
      wsvm <- scan(paste(WorkPath, "Weights.txt", sep="/"), nlines=1, skip=4, quiet=T)
      numDEGsmall <- max(length(wccp), length(wdlda), length(wsvm))
      # weightm <- matrix(0, nr=numDEGsmall, nc=3) not used later
      # weightm[1:length(wccp), 1] <- wccp
      # weightm[1:length(wdlda), 2] <- wdlda
      # weightm[1:length(wsvm), 3] <- wsvm
      thresh <- rep(NA, 3)
      for(i in 1:3) thresh[i] <- scan(paste(WorkPath, "Weights.txt", sep="/"), n=1, skip=2*i-1, quiet=T)
      # cat the weights to the html
      if (generateHTML){
        cat("<P></P><HR SIZE=5 WIDTH=\"100%\" NOSHADE>",
            "<P><a name=\"rule\"><H3><B><U>Prediction rule from the linear predictors:</U></B></H3></P>",
            "<P>The prediction rule is defined by the inner sum of the weights (<var>w<sub>i</sub></var>)
          and expression (<var>x<sub>i</sub></var>) of significant genes. The expression is the log ratios for dual-channel data and log intensities for single-channel data. ",
            "<P>A sample is classified to the class ",
            "<B>", classlabels[1],"</B>", "if the sum is greater than the threshold; that is,",
            "&#8721;<sub><var>i</var></sub><var>w<sub>i</sub></var>
          <var>x<sub>i</sub> > </var>threshold.</P>",
            "<P>",
            if (CcpParam & length(wccp)>0) paste("The threshold for the Compound Covariate predictor is ", round(thresh[1],3), "<BR>"),
            if (LDAParam & length(wdlda)>0) paste("The threshold for the Diagonal Linear Discriminant predictor is ", round(thresh[2],3), "<BR>"),
            if (SvmParam & length(wsvm)>0) paste("The threshold for the Support Vector Machine predictor is ", round(thresh[3], 3), "<BR>")
            ,"</P>"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      WriteExpressionData <- file.exists(paste(WorkPath, "/GeneExpData.txt", sep="")) &&
        length(scan(paste(WorkPath, "/GeneExpData.txt", sep=""),nmax=1,quiet=T)) > 0
      
      load(paste(WorkPath, "/experiments.rda", sep=""))
      load(paste(WorkPath, "/GeneId1.rda", sep=""))
      Experiments <- experiments
      ExpressionCode <- Experiments$ClassVariable != "predict"
      Experiments <- Experiments[ExpressionCode ,]
      
      ExpressionData.raw <- read.table(paste(WorkPath, "/GeneExpData.txt", sep=""))
      ExpressionData.geneid <- ExpressionData.raw[1:nrow(ExpressionData.raw),1]
      
      #if (IsSingleChannel) {
      #  medianLR <- scan(file = paste(WorkPath, "medianLR.txt", sep="/"))
      #}
      
      if (generateHTML){
        WeightTable.H1 <- paste("<TR><TH>&nbsp;<TH>Genes",
                                if (CcpParam) "<TH>Compound<BR>Covariate<BR>Predictor",
                                if (LDAParam) "<TH>Diagonal Linear<BR>Discriminant<BR>Analysis",
                                if (SvmParam) "<TH>Support<BR>Vector<BR>Machines",
                                #if (IsSingleChannel) "<TH>Median<BR>across<BR>arrays",
                                "</TR>")
        TableTitle <- "Gene Weights"
        nHeaderLines  <- 1
        
        load(paste(WorkPath, "/GeneId1.rda", sep="")) # load "GeneId1" object
        # find the number of genes for different classifiers
        # nDEGbyMethod[1], et al
        WeightTable <- character(nHeaderLines+numDEGsmall )
        WeightTable[1] <- WeightTable.H1
        for( i in 1:numDEGsmall) {
          WeightTable[i+nHeaderLines] <- paste("<TR><TH>",i,"<TH>",
                                               GeneId1[ExpressionData.geneid[i] ],
                                               if (CcpParam) paste("<TD>", round(wccp[i],4)),
                                               if (LDAParam) paste("<TD>", round(wdlda[i],4)),
                                               if (SvmParam) paste("<TD>", round(wsvm[i],4)))
          #if (IsSingleChannel) paste("<TD>", round(medianLR[i],4)))
        }
        
        
        cat( "<table border='1' class='sortable'>" #Qian 5/29/09 sortable
             , paste("<P><U>Table.</U>",TableTitle,"</P>")
             , "<CAPTION ALIGN=left></CAPTION>"
             , WeightTable
             , "</TABLE>"
             , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      
      
      # added by Ting
      
      weightTable2 <- data.frame(GeneId1[ExpressionData.geneid[1:numDEGsmall]])
      if (CcpParam) weightTable2 <- cbind(weightTable2,round(wccp[1:numDEGsmall],4))
      if (LDAParam) weightTable2 <- cbind(weightTable2,round(wdlda[1:numDEGsmall],4))
      if (SvmParam) weightTable2 <- cbind(weightTable2,round(wsvm[1:numDEGsmall],4))
      names(weightTable2) <- c("Genes", if (CcpParam) "CCP", if (LDAParam) "LDA", if (SvmParam) "SVM")
      threshold <- NULL
      if (CcpParam & length(wccp)>0) threshold <- c(threshold, round(thresh[1],3))
      if (LDAParam & length(wdlda)>0) threshold <- c(threshold, round(thresh[2],3))
      if (SvmParam & length(wsvm)>0) threshold <- c(threshold, round(thresh[3],3))
      names(threshold) <- c(if (CcpParam) paste("CCP (", classlabels[1],")",sep=''),
                            if (LDAParam) paste("LDA (", classlabels[1],")",sep=''),
                            if (SvmParam) paste("SVM (", classlabels[1],")",sep=''))
      resList <- c(resList, list(weightLinearPred=weightTable2, thresholdLinearPred=threshold))
      
      
      # end by Ting
      
    } # end of adding weights to html
    
    if (CentroidParam & !paired) {
      load(paste(WorkPath, "/GeneId1.rda", sep=""))
      lr2 <- read.table(file.path(WorkPath, "/GeneExpData.txt"))[, -1,drop=FALSE]
      # Fixed computing group mean in 1 gene. MLI 3/3/2011
      grp.mean <- t(aggregate(t(lr2), list(rep(1:ngrp, groupsize)), function(x){mean(x,na.rm=TRUE)})[, -1])
      if (generateHTML){
        GrpCentroidHTML <- rep("", nrow(lr2) + ngrp)
        GrpCentroidHTML[1] <- paste("<TR><TH><BR><TH>Genes", paste("<TH>", classlabels, collapse=""), "</TH></TR>\n")
        for(i in 1:nrow(lr2)) {
          GrpCentroidHTML[i+1] <- paste("<TR><TH><B>", i, "</B></TH><TH>", GeneId1[classifiers$index[i]], "</TH>",
                                        paste("<TD>", round(grp.mean[i,], 4), "</TD>", collapse=""),
                                        "</TR>\n") # GeneId1 definition in classpredict is different from AT, MLI
        }
        cat("<P></P>", "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>"
            , "<P><a name=\"centroid\"><H3><B><U>Centroid of each class:</U></B></H3></P>"
            , "<table border='1' class='sortable'>"
            , GrpCentroidHTML
            , "</TABLE>"
            , file=ExternalFileName, sep="\n", append=T)
      } # end of html
      
      GRPCentroid <- data.frame(GeneId1[classifiers$index[1:nrow(lr2)]],round(grp.mean[1:nrow(lr2),], 4))
      names(GRPCentroid) <- c("Genes", classlabels)
      resList <- c(resList, list(GRPCentroid=GRPCentroid))
    }
    
    if (generateHTML){
      if (!paired & (BccpParam | CcpParam | LDAParam) & twogroup & UniquePrediction) {
        # If ROC package can't be installed, we will skip creating ROC curve.
        # if (LoadRPackage("ROC", isBioconductor=T)) {
        if (TRUE) {
          cat("<P></P>", "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>",file=ExternalFileName, sep="\n", append=T)
          # Create a plot containing all curves
          ROCFile <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_all.png", sep="")
          add2plot <- FALSE
          mdlroc <- rep(FALSE, 3)
          aucobs <- double(3)
          png(ROCFile, width=480, height=480, pointsize=10)
          if (CcpParam | LDAParam) {
            predval <- read.table(file.path(WorkPath, "Predval.txt"), header=T)
            truth <- rep(1:2, groupsize)
            if (CcpParam) {
              roco <- myroc(truth, predval[, 2], myrule)
              aucobs[1] <- ROC::AUC(roco)
              ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=1,
                        type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
              # points(1-roco@spec, roco@sens)
              add2plot <- TRUE
              mdlroc[1] <- TRUE
            }
            if (LDAParam) {
              roco <- myroc(truth, predval[, 3], myrule)
              aucobs[2] <- ROC::AUC(roco)
              if (add2plot) par(new=TRUE)
              ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=2,
                        type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
              add2plot <- TRUE
              mdlroc[2] <- TRUE
            }
          }
          if (add2plot) par(new=TRUE)
          if (BccpParam) {
            mdlroc[3] <- TRUE
            BCCPProb <- read.table(paste(WorkPath, "/SampleErrorP.txt", sep=""), header=T)[,9]
            truth <- rep(1:2, groupsize)
            roco <- myroc(truth, BCCPProb, myrule)
            aucobs[3] <- ROC::AUC(roco)
            ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=3,
                      type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
            # points(1-roco@spec, roco@sens)
          }
          # See Risk.R for coding
          abline(0, 1, col="gray")
          aucval <- paste("AUC=", paste(round(aucobs[mdlroc], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc], collapse=",", sep=""))
          title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
          legend("bottomright", lty = seq(1,3)[mdlroc], c("CCP", "DLDA", "BCCP")[mdlroc])
          dev.off()
          # Create a plot for ccp only
          if (CcpParam) {
            ROCFile.ccp <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_ccp.png", sep="")
            png(ROCFile.ccp, width=480, height=480, pointsize=10)
            predval <- read.table(file.path(WorkPath, "Predval.txt"), header=T)
            roco <- myroc(truth, predval[, 2], myrule)
            aucobs[1] <- ROC::AUC(roco)
            ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=1,
                      type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
            abline(0, 1, col="gray")
            mdlroc2 <- c(TRUE, FALSE, FALSE)
            aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
            title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
            legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
            dev.off()
          }
          # Create a plot for dlda only
          if (LDAParam) {
            ROCFile.dlda <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_dlda.png", sep="")
            png(ROCFile.dlda, width=480, height=480, pointsize=10)
            roco <- myroc(truth, predval[, 3], myrule)
            aucobs[2] <- ROC::AUC(roco)
            ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=2,
                      type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
            abline(0, 1, col="gray")
            mdlroc2 <- c(FALSE, TRUE, FALSE)
            aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
            title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
            legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
            dev.off()
          }
          # Create a plot for bccp only
          if (BccpParam) {
            ROCFile.bccp <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_bccp.png", sep="")
            png(ROCFile.bccp, width=480, height=480, pointsize=10)
            BCCPProb <- read.table(paste(WorkPath, "/SampleErrorP.txt", sep=""), header=T)[,9]
            roco <- myroc(truth, BCCPProb, myrule)
            aucobs[3] <- ROC::AUC(roco)
            ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=3,
                      type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
            abline(0, 1, col="gray")
            mdlroc2 <- c(FALSE, FALSE, TRUE)
            aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
            title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
            legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
            dev.off()
          }
          if (file.access(ROCFile, mode=4)==0) {  #If file is read-accessible.
            cat("<P><a name=\"roc\"><H3><B><U>Cross-validation ROC curves</U></B></H3><BR>\n",
                "<form name='test'>",
                "<input type='radio' name='field' value='one' onclick='check_value(1)' checked='checked'>All",
                if (mdlroc[1]) "<input type='radio' name='field' value='two' onclick='check_value(2)'>CCP",
                if (mdlroc[2]) "<input type='radio' name='field' value='three' onclick='check_value(3)'>DLDA",
                if (mdlroc[3]) "<input type='radio' name='field' value='four' onclick='check_value(4)'>BCCP",
                "</form>",
                "<div id='imagedest'>",
                "<img src='roc_all.png'>",
                "</div>",
                "</P>", file=ExternalFileName, sep="\n", append=T)
            cat("<P>Note: <BR>1. ROC curve for Bayesian Compound Covariate Predictor does not use uncertainty threshold.",
                "<BR>2. Internet Explorer users need to enable ActiveX control for the radio buttons to work.",
                "Click the HELP button at the top about the instruction.",
                "</P>", file=ExternalFileName, sep="\n", append=T)
          }
        } # if (LoadRPackage("ROC", isBioconductor=T))
      } # end of if (!paired & (BccpParam | CcpParam | LDAParam) & twogroup & UniquePrediction)
      cat("<P></P>", "<HR SIZE=5 WIDTH=\"100%\" NOSHADE>",
          "classpredict package version", packageDescription("classpredict", fields = "Version"), "</P>", file=ExternalFileName, append=TRUE)
      
      cat( "<P></P>", "</BODY>", "</HTML>", file=ExternalFileName, sep="\n", append=T)
    } # end of html
  } # end of if(GoodRun)
  
  #  return(list(numDEGs=numDEGs))
  return(resList)
  
}

#' Test classpredict() function
#'
#' This function will load a test dataset to run \code{classPredict} function.
#'
#' If the random variance model is enabled, all genes will be used for the model estimation.
#'
#' @param dataset character string specifying one of "Brca", "Perou" or "Pomeroy" datasets.
#' @param projectPath characteer string specifying the project path. Default is C:/Users/UserName/Documents/$dataset.
#' @param outputName character string for the output folder name.
#' @param generateHTML logical. If \code{TRUE}, an html page will be generated with detailed prediction results.
#' @return A list as returned by \code{classPredict}.
#' @export
#' @seealso \code{\link{classPredict}}
#' @examples
#' test.classPredict("Pomeroy")
#' @importClassesFrom ROC rocc
test.classPredict <- function(dataset = c("Brca", "Perou", "Pomeroy"), projectPath, outputName = "ClassPrediction",
                              generateHTML = FALSE) {
  dataset <- match.arg(dataset)
  if (missing(projectPath))  projectPath <- file.path(Sys.getenv("R_USER"), dataset)
  # reading data
  geneId <- read.delim(system.file("extdata", paste0(dataset, "_GENEID.txt"), package = "classpredict"), as.is = TRUE, colClasses = "character")
  singleChannel <- ifelse(dataset == "Pomeroy", TRUE, FALSE)
  if (singleChannel) {
    x <- read.delim(system.file("extdata", paste0(dataset, "_NORMALIZEDLOGINTENSITY.TXT"), package = "classpredict"), header = FALSE)
  } else {
    x <- read.delim(system.file("extdata", paste0(dataset, "_LOGRAT.TXT"), package = "classpredict"), header = FALSE)
  }
  filter <- scan(system.file("extdata", paste0(dataset, "_FILTER.TXT"), package = "classpredict"), quiet = TRUE)
  expdesign <- read.delim(system.file("extdata", paste0(dataset, "_EXPDESIGN.txt"), package = "classpredict"), as.is = TRUE)
  
  # ad-hoc process to make the result compatible with BRB-AT
  #  geneId <- geneId[filter == 1, ]
  #  x <- x[filter == 1, ]
  #  filter <- rep(1, sum(filter))
  
  # For simplicity, I assume the samples are ordered as the class labels; 'AT/RT' < 'Medulloblasta'.
  if (dataset == "Brca") {
    testSet <- expdesign[, 10]
    trainingInd <- which(testSet == "training")
    predictInd <- which(testSet == "predict")
    ind1 <- which(expdesign[trainingInd, 4] == "BRCA1")
    ind2 <- which(expdesign[trainingInd, 4] == "BRCA2")
    ind <- c(ind1, ind2)
    exprTrain <- x[, ind]
    colnames(exprTrain) <- expdesign[ind, 1]
    exprTest <- x[, predictInd]
    colnames(exprTest) <- expdesign[predictInd, 1]
    # specify the actual project folder
    resList <- classPredict(exprTrain = exprTrain, exprTest = exprTest, isPaired = FALSE, pairVar.train = NULL, pairVar.test = NULL, geneId,
                            #singleChannel = FALSE,
                            cls = c(rep("BRCA1", length(ind1)), rep("BRCA2", length(ind2))),
                            pmethod = c("ccp", "bcc", "dlda", "knn", "nc", "svm"), geneSelect = "igenes.univAlpha",
                            univAlpha = 0.001, univMcr = 0, foldDiff = 0, rvm = TRUE, filter = filter, ngenePairs = 25, nfrvm = 10,
                            cvMethod = 1, kfoldValue = 10, bccPrior = 1, bccThresh = 0.8,
                            nperm = 0, svmCost = 1, svmWeight =1, fixseed = 1, prevalence = NULL,
                            projectPath = projectPath,
                            outputName = outputName,
                            generateHTML)
  } else if (dataset == "Perou") {
    exprTrain <- x
    colnames(exprTrain) <- expdesign[, 1]
    pairVar <- expdesign[, 2]
    cls <- expdesign[ ,3]
    
    resList <-  classPredict(exprTrain = exprTrain, exprTest = NULL, isPaired = TRUE,
                             pairVar.train = pairVar, pairVar.test = NULL, geneId, cls = cls,
                             pmethod = c("ccp", "dlda", "knn", "nc", "svm"), geneSelect = "igenes.univAlpha",
                             univAlpha = 0.001, univMcr = 0, foldDiff = 0, rvm = TRUE, filter = filter, ngenePairs = 25, nfrvm = 10,
                             cvMethod = 1, kfoldValue = 10, bccPrior = 1, bccThresh = 0.8,
                             nperm = 0, svmCost = 1, svmWeight =1, fixseed = 1, prevalence = NULL,
                             projectPath = projectPath,
                             outputName = outputName,
                             generateHTML)
  } else if (dataset == "Pomeroy") {
    ind1 <- which(expdesign[, 18] == "AT/RT")
    ind2 <- which(expdesign[, 18] == "Medulloblastoma")
    ind <- c(ind1, ind2)
    exprTrain <- x[, ind]
    colnames(exprTrain) <- expdesign[ind, 1]
    # specify the actual project folder
    resList <- classPredict(exprTrain = exprTrain, exprTest = NULL, isPaired = FALSE, pairVar.train = NULL,
                            pairVar.test = NULL, geneId,
                            cls = c(rep("AT/RT", length(ind1)), rep("Medulloblastoma", length(ind2))),
                            pmethod = c("ccp", "bcc", "dlda", "knn", "nc", "svm"), geneSelect = "igenes.univAlpha",
                            univAlpha = 0.001, univMcr = 0, foldDiff = 0, rvm = TRUE, filter = filter, ngenePairs = 25, nfrvm = 10,
                            cvMethod = 1, kfoldValue = 10, bccPrior = 1, bccThresh = 0.8,
                            nperm = 0, svmCost = 1, svmWeight =1, fixseed = 1, prevalence = NULL,
                            projectPath = projectPath,
                            outputName = outputName,
                            generateHTML)
  }
  if (generateHTML)
    browseURL(file.path(projectPath, "Output", outputName,
                        paste0(outputName, ".html")))
  
  return(resList)
}

.myrule <- function(x, thresh, modified) {
  # Input:
  #   x: the posterior probability from the BCCP
  # Rule:
  #   If x > thresh then class = 1
  #      x <= thresh then class = 2
  # Note: the rule is different from what we have implemented in Class Prediction
  #
  if (modified) {
    res <- rep(NA, length(x))
    res[x > thresh] <- 1
    res[(1-x) > thresh] <- 2
  } else {
    res <- rep(2, length(x))
    res[x > thresh] <- 1
  }
  res
}

########################################################################################
##                                                                                    ##
## FUNCTION:  myroc                                                                   ##
##                                                                                    ##
## This function Calculates sensitivity and specificity on new data                   ##
## Input:                                                                             ##
##    xd is a one dimensional decison function value.                                 ##
##    truth (=1,2) should correspond to myrule().                                     ##
##    rule: decision rule depends on the prediction method and                        ##
##          the decision function values                                              ##
##    cutpts: cut points. If NA, see the code how to generate them.                   ##
## Output: a list of                                                                  ##
##    sens - sensitivity                                                              ##
##    spec - specificity                                                              ##
##    cuts - cutpoints                                                                ##
##                                                                                    ##
########################################################################################

myrule <- function(x, thresh) .myrule(x, thresh, FALSE)
myrule.m <- function(x, thresh) .myrule(x, thresh, TRUE)

myroc <- function (truth, xd, rule = NULL, cutpts,  markerLabel = "unnamed marker",
                   caseLabel = "unnamed diagnosis") {
  
  if (!all(sort(unique(truth)) == c(1, 2)))
    stop("'truth' variable must take values 1 or 2")
  if (missing(cutpts)) {
    udata <- unique(sort(xd))
    delta <- min(diff(udata))/2
    cutpts <- c(udata - delta, udata[length(udata)] + delta)
  }
  np <- length(cutpts)
  sens <- rep(NA, np)
  spec <- rep(NA, np)
  for (i in 1:np) {
    pred <- rule(xd, cutpts[i])
    sens[i] = sum(pred[truth == 1]==1, na.rm = TRUE) / sum(truth == 1)
    spec[i] = sum(pred[truth == 2]==2, na.rm = TRUE) / sum(truth == 2)
  }
  # list(spec = spec, sens = sens, cuts = cutpts)
  new("rocc", spec = spec, sens = sens, rule = rule, cuts = cutpts,
      markerLabel = markerLabel, caseLabel = caseLabel)
}

########################################################################################
##                                                                                    ##
## FUNCTION:  CreatePath                                                              ##
##                                                                                    ##
## THIS FUNCTION CONSTRUCTS THE FOLDERS FOR A GIVEN PATH,                             ##
## IF THE GIVEN PATH DOES NOT YET EXIST.                                              ##
##                                                                                    ##
########################################################################################

CreatePath <- function(FolderPath) {
  ## Create FolderPath if it doesn't yet exist.
  Folders <- unlist(strsplit(FolderPath, split="/"))
  Folders <- unlist(strsplit(Folders, split="\\\\"))
  FolderPath <- Folders[1]
  if (length(Folders) > 1) {
    for (i in 2:length(Folders)) {
      FolderPath <- paste(FolderPath, Folders[i], sep="/")
      if (file.access(FolderPath)==-1) dir.create(FolderPath)
    }
  }
}

#' Plot ROC curves
#'
#' This function plots ROC curves for compound covariate predictor,
#' diagonal linear discriminant analysis and Bayesian compound covariate predictor methods.
#'
#' @param list list returned by function \code{classPredic}.
#' @param method character string of a prediction method.
#' \itemize{
#'    \item "ccp":  compound covariate predictor
#'    \item "dlda": diagonal linear discriminant analysis
#'    \item "bcc":  Bayesian compound covariate predictor
#' }
#' @export
#' @examples
#' res <- test.classPredict("Brca")
#' plotROCCurve(res, "ccp")
#' plotROCCurve(res, "dlda")
#' plotROCCurve(res, "bcc")
plotROCCurve <- function (list,method){
  
  if (!any(method==c("ccp","dlda","bcc"))) stop("Prediction method should be 'ccp', 'dlda' or 'bcc'.\n")
  if (!any(method==list$pmethod)) stop("Please run class prediction for the specified prediction method.\n")
  CcpParam <- ifelse(method == "ccp", TRUE, FALSE)
  LDAParam <- ifelse(method == "dlda", TRUE, FALSE)
  BccpParam <- ifelse(method == "bcc", TRUE, FALSE)
  workPath <- list$workPath
  ngrp <- scan(paste(workPath, "lr_data.txt", sep="/"), nmax=1, quiet=T)
  groupsize <- scan(paste(workPath, "lr_data.txt", sep="/"), n=4+ngrp, quiet=T)[5:(4+ngrp)]
  truth <- rep(1:2, groupsize)
  aucobs <- double(3)
  predval <- read.table(file.path(workPath, "Predval.txt"), header=T)
  if (CcpParam) {
    #    ROCFile.ccp <- paste(outputPath, "/roc_ccp.png", sep="")
    #    png(ROCFile.ccp, width=480, height=480, pointsize=10)
    roco <- myroc(truth, predval[, 2], myrule)
    aucobs[1] <- ROC::AUC(roco)
    ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=1,
              type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
    abline(0, 1, col="gray")
    mdlroc2 <- c(TRUE, FALSE, FALSE)
    aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
    title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
    legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
    #   dev.off()
  }
  # Create a plot for dlda only
  if (LDAParam) {
    #  ROCFile.dlda <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_dlda.png", sep="")
    #  png(ROCFile.dlda, width=480, height=480, pointsize=10)
    roco <- myroc(truth, predval[, 3], myrule)
    aucobs[2] <- ROC::AUC(roco)
    ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=2,
              type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
    abline(0, 1, col="gray")
    mdlroc2 <- c(FALSE, TRUE, FALSE)
    aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
    title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
    legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
    #  dev.off()
  }
  # Create a plot for bccp only
  if (BccpParam) {
    #  ROCFile.bccp <- paste(ProjectPath, "/Output/", AnalysisName, "/", "roc_bccp.png", sep="")
    #  png(ROCFile.bccp, width=480, height=480, pointsize=10)
    BCCPProb <- read.table(paste(workPath, "/SampleErrorP.txt", sep=""), header=T)[,9]
    roco <- myroc(truth, BCCPProb, myrule)
    aucobs[3] <- ROC::AUC(roco)
    ROC::plot(1-roco@spec, roco@sens, xlab="", ylab="", lty=3,
              type="l", pty="s", xlim=c(0,1), ylim=c(0,1), main="ROC curve")
    abline(0, 1, col="gray")
    mdlroc2 <- c(FALSE, FALSE, TRUE)
    aucval <- paste("AUC=", paste(round(aucobs[mdlroc2], 3), c("(CCP)", "(DLDA)", "(BCCP)")[mdlroc2], collapse=",", sep=""))
    title(xlab=paste( "1 - specificity", "\n", aucval), ylab="sensitivity")
    legend("bottomright", lty = seq(1,3)[mdlroc2], c("CCP", "DLDA", "BCCP")[mdlroc2])
    #  dev.off()
  }
}
