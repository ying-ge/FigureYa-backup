# coord() 工厂函数 - 用于创建 Coord 对象
# coord() factory function - for creating Coord objects

# 注意：在 ggplot2 中，coord() 用于创建坐标系对象
# Note: In ggplot2, coord() is used to create coordinate system objects

# 从 ggplot2 获取 Coord 类
# Get Coord class from ggplot2
Coord <- get("Coord", envir = asNamespace("ggplot2"))

# 创建 coord() 函数
# Create coord() function
coord <- function(..., subclass = NULL) {
  # 创建一个 ggproto 对象
  # Create a ggproto object
  if (!is.null(subclass)) {
    p <- ggproto(paste0("Coord", paste(subclass, collapse = "")), Coord, ...)
    class(p) <- c(subclass, class(p))
  } else {
    p <- ggproto("Coord", Coord, ...)
  }
  p
}

# 将 coord 函数加载到全局环境
# Load coord function into global environment
assign('coord', coord, envir = .GlobalEnv)

cat("coord() function created\n")

