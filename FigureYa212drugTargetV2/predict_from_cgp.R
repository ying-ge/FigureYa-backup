#' Calculates phenotype from microarray data.
#' 修复版 calcPhenotype 函数 - 修复了 R 4.0+ 的矩阵检查问题
#'
#' @param trainingExprData The training data. A matrix of expression levels, rows contain genes and columns contain samples, "rownames()" must be specified and must contain the same type of gene ids as "testExprData"
#' @param trainingPtype The known phenotype for "trainingExprData". A numeric vector which MUST be the same length as the number of columns of "trainingExprData".
#' @param testExprData The test data where the phenotype will be estimted. It is a matrix of expression levels, rows contain genes and columns contain samples, "rownames()" must be specified and must contain the same type of gene ids as "trainingExprData".
#' @param batchCorrect How should training and test data matrices be homogenized. Choices are "eb" (default) for ComBat, "qn" for quantiles normalization or "none" for no homogenization.
#' @param powerTransformPhenotype Should the phenotype be power transformed before we fit the regression model? Default to TRUE, set to FALSE if the phenotype is already known to be highly normal.
#' @param removeLowVaryingGenes What proportion of low varying genes should be removed? 20 percent be default
#' @param minNumSamples How many training and test samples are requried. Print an error if below this threshold
#' @param selection How should duplicate gene ids be handled. Default is -1 which asks the user. 1 to summarize by their or 2 to disguard all duplicates.
#' @param printOutput Set to FALSE to supress output
#' @param removeLowVaringGenesFrom From where to remove low varying genes
#'
#' @return A vector of the estimated phenotype, in the same order as the columns of "testExprData".
#'
#' @export
calcPhenotype <- function(trainingExprData, trainingPtype, testExprData, batchCorrect = "eb", powerTransformPhenotype = TRUE, removeLowVaryingGenes = 0.2, minNumSamples = 10, selection = -1, printOutput = TRUE, removeLowVaringGenesFrom = "homogenizeData") {
  
  # 检查必要的包是否已加载
  if (!requireNamespace("sva", quietly = TRUE)) {
    stop("请安装 sva 包: install.packages('sva')")
  }
  if (!requireNamespace("ridge", quietly = TRUE)) {
    stop("请安装 ridge 包: install.packages('ridge')")
  }
  if (!requireNamespace("car", quietly = TRUE)) {
    stop("请安装 car 包: install.packages('car')")
  }
  
  # 修复的矩阵检查 - 使用 is.matrix() 而不是 class() == "matrix"
  if (!is.matrix(testExprData)) stop("ERROR: \"testExprData\" must be a matrix.")
  if (!is.matrix(trainingExprData)) stop("ERROR: \"trainingExprData\" must be a matrix.")
  if (!is.numeric(trainingPtype)) stop("ERROR: \"trainingPtype\" must be a numeric vector.")
  if (ncol(trainingExprData) != length(trainingPtype)) stop("The training phenotype must be of the same length as the number of columns of the training expression matrix.")
  
  # check if an adequate number of training and test samples have been supplied.
  if ((ncol(trainingExprData) < minNumSamples) || (ncol(testExprData) < minNumSamples)) {
    stop(paste("There are less than", minNumSamples, "samples in your test or training set. It is strongly recommended that you use larger numbers of samples in order to (a) correct for batch effects and (b) fit a reliable model. To supress this message, change the \"minNumSamples\" parameter to this function."))
  }

  # 需要确保 homogenizeData 函数可用
  # 如果 homogenizeData 不在全局环境，可能需要从 pRRophetic 包中获取或自己实现
  if (!exists("homogenizeData")) {
    # 简化的 homogenizeData 实现
    homogenizeData <- function(testExpr, trainExpr, batchCorrect, selection, printOutput) {
      # 这里使用简单的 ComBat 实现
      common_genes <- intersect(rownames(testExpr), rownames(trainExpr))
      if (length(common_genes) == 0) stop("No common genes between test and training data")
      
      testExpr <- testExpr[common_genes, , drop = FALSE]
      trainExpr <- trainExpr[common_genes, , drop = FALSE]
      
      if (batchCorrect == "eb") {
        combined <- cbind(testExpr, trainExpr)
        batch <- factor(c(rep("test", ncol(testExpr)), rep("train", ncol(trainExpr))))
        corrected <- sva::ComBat(combined, batch = batch)
        return(list(test = corrected[, 1:ncol(testExpr)], train = corrected[, (ncol(testExpr)+1):ncol(corrected)]))
      } else {
        return(list(test = testExpr, train = trainExpr))
      }
    }
  }
  
  # Get the homogenized data
  homData <- homogenizeData(testExprData, trainingExprData, batchCorrect = batchCorrect, selection = selection, printOutput = printOutput)
  
  # 需要确保 doVariableSelection 函数可用
  if (!exists("doVariableSelection")) {
    # 简化的变量选择实现
    doVariableSelection <- function(data, removeLowVaryingGenes) {
      gene_vars <- apply(data, 1, function(x) sd(x) / mean(x))
      n_keep <- round(nrow(data) * (1 - removeLowVaryingGenes))
      return(order(gene_vars, decreasing = TRUE)[1:n_keep])
    }
  }
  
  # Do variable selection if specified.
  keepRows <- seq(1:nrow(homData$train))
  if (removeLowVaryingGenes > 0 && removeLowVaryingGenes < 1) {
    if (removeLowVaringGenesFrom == "homogenizeData") {
      keepRows <- doVariableSelection(cbind(homData$test, homData$train), removeLowVaryingGenes = removeLowVaryingGenes)
      numberGenesRemoved <- nrow(homData$test) - length(keepRows)
      if (printOutput) cat(paste("\n", numberGenesRemoved, "low variabilty genes filtered."))
    } else if (removeLowVaringGenesFrom == "rawData") {
      evaluabeGenes <- rownames(homData$test)
      keepRowsTrain <- doVariableSelection(trainingExprData[evaluabeGenes, ], removeLowVaryingGenes = removeLowVaryingGenes)
      keepRowsTest <- doVariableSelection(testExprData[evaluabeGenes, ], removeLowVaryingGenes = removeLowVaryingGenes)
      keepRows <- intersect(keepRowsTrain, keepRowsTest)
      numberGenesRemoved <- nrow(homData$test) - length(keepRows)
      if (printOutput) cat(paste("\n", numberGenesRemoved, "low variabilty genes filtered."))
    }
  }
  
  # PowerTransform phenotype if specified.
  offset <- 0
  if (powerTransformPhenotype) {
    if (min(trainingPtype) < 0) {
      offset <- -min(trainingPtype) + 1
      trainingPtype <- trainingPtype + offset
    }
    
    transForm <- car::powerTransform(trainingPtype)[[6]]
    trainingPtype <- trainingPtype^transForm
  }
  
  # create the Ridge Regression model
  if (printOutput) cat("\nFitting Ridge Regression model... ")
  trainFrame <- data.frame(Resp = trainingPtype, t(homData$train[keepRows, ]))
  rrModel <- ridge::linearRidge(Resp ~ ., data = trainFrame)
  if (printOutput) cat("Done\n\nCalculating predicted phenotype...")
  
  # predict the new phenotype
  # 修复的矩阵检查 - 使用 is.matrix() 而不是 class() == "matrix"
  if (!is.matrix(homData$test)) {
    n <- names(homData$test)
    homData$test <- matrix(homData$test, ncol = 1)
    rownames(homData$test) <- n
    testFrame <- data.frame(t(homData$test[keepRows, ]))
    preds <- predict(rrModel, newdata = rbind(testFrame, testFrame))[1]
  } else {
    testFrame <- data.frame(t(homData$test[keepRows, ]))
    preds <- predict(rrModel, newdata = testFrame)
  }
  
  # if the response variable was transformed, untransform it now...
  if (powerTransformPhenotype) {
    preds <- preds^(1/transForm)
    preds <- preds - offset
  }
  if (printOutput) cat("Done\n\n")
  
  return(preds)
}
