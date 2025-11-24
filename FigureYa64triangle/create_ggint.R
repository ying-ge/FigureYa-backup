# 创建 ggint 对象（ggplot2 内部函数的包装）
# Create ggint object (wrapper for ggplot2 internal functions)

# 注意：在新版本的 ggplot2 中，这些函数是直接导出的或作为内部函数存在
# Note: In newer versions of ggplot2, these functions are directly exported or exist as internal functions

ggint <- list()

# 尝试从 ggplot2 命名空间中获取这些函数
# Try to get these functions from ggplot2 namespace
ggint_names <- c(
  'plot_clone', 
  'new_panel', 
  'train_layout', 
  'map_layout', 
  'add_group', 
  'scales_transform_df', 
  'train_position', 
  'map_position', 
  'order_groups', 
  'scales_add_missing', 
  'reset_scales', 
  'scales_train_df', 
  'scales_map_df',
  'ggname',
  'coord_transform.cartesian',
  'train_cartesian',
  'expand_default',
  '.all_aesthetics',
  'is.rel',  # Added for theme element size calculation
  'scale_clone',  # Added for cloning scale objects
  'coord_train',  # Added for training coordinate system
  'find_global'  # Added for finding global functions
)

for (n in ggint_names) {
  fn <- tryCatch({
    get(n, envir = asNamespace('ggplot2'))
  }, error = function(e) {
    # 如果找不到，尝试其他名称
    # If not found, try alternative names
    NULL
  })
  
  if (!is.null(fn)) {
    ggint[[n]] <- fn
  } else {
    # 对于某些函数，可能需要创建包装器或使用替代方法
    # For some functions, may need to create wrappers or use alternative methods
    if (n == '.all_aesthetics') {
      # .all_aesthetics 可能是内部变量
      # .all_aesthetics may be an internal variable
      tryCatch({
        ggint[[n]] <- get('.all_aesthetics', envir = asNamespace('ggplot2'), inherits = TRUE)
      }, error = function(e) {
        # 如果不存在，使用默认值
        # If doesn't exist, use default value
        ggint[[n]] <- c("x", "y", "group", "colour", "fill", "size", "linetype", "shape", "weight", "alpha", "angle", "hjust", "vjust", "family", "fontface", "lineheight")
      })
    } else if (n == 'new_panel') {
      # new_panel 应该创建一个新的 Panel 对象
      # new_panel should create a new Panel object
      # 在 ggplot2 中，Panel 是一个 ggproto 对象，我们可以直接创建基本结构
      # In ggplot2, Panel is a ggproto object, we can create a basic structure directly
      ggint[[n]] <- function() {
        list(
          x_scales = list(),
          y_scales = list(),
          scales = list(),
          layout = data.frame(PANEL = integer(), SCALE_X = integer(), SCALE_Y = integer())
        )
      }
    } else if (n == 'scale_clone') {
      # scale_clone 应该克隆一个 Scale 对象
      # scale_clone should clone a Scale object
      tryCatch({
        Scale <- get('Scale', envir = asNamespace('ggplot2'), inherits = TRUE)
        # Scale 是一个 ggproto 对象，clone 是方法
        # Scale is a ggproto object, clone is a method
        ggint[[n]] <- function(scale) {
          if(is.null(scale)) return(NULL)
          # 如果 scale 是 ggproto 对象，调用其 clone 方法
          # If scale is a ggproto object, call its clone method
          if(inherits(scale, 'ggproto')) {
            scale$clone()
          } else {
            # 否则直接返回
            # Otherwise return directly
            scale
          }
        }
      }, error = function(e) {
        # 如果找不到，创建一个基本的克隆函数
        # If not found, create a basic clone function
        ggint[[n]] <- function(scale) {
          if(is.null(scale)) return(NULL)
          # 简单返回原对象（可能在后续版本中需要真正的克隆）
          # Simply return the original object (may need true cloning in later versions)
          scale
        }
      })
    } else if (n == 'train_cartesian') {
      # train_cartesian 应该训练一个 scale 对象并返回范围、breaks 等信息
      # train_cartesian should train a scale object and return range, breaks, etc.
      # 尝试从 ggplot2 获取原函数
      # Try to get original function from ggplot2
      tryCatch({
        # 可能在内部函数或方法中
        # May be in internal functions or methods
        ggint[[n]] <- get('train_cartesian', envir = asNamespace('ggplot2'), inherits = TRUE)
      }, error = function(e) {
        # 如果找不到，使用自定义实现
        # If not found, use custom implementation
        ggint[[n]] <- function(scale, limits, name) {
          if(is.null(scale)) return(list())
          
          # 返回结果 - 简化版本，避免调用可能不存在的方法
          # Return results - simplified version, avoid calling methods that may not exist
          result <- list()
          if(!is.null(limits) && length(limits) == 2) {
            result[[paste0(name, ".range")]] <- limits
          } else {
            tryCatch({
              result[[paste0(name, ".range")]] <- scale$get_limits()
            }, error = function(e) {
              result[[paste0(name, ".range")]] <- c(0, 1)
            })
          }
          
          tryCatch({
            result[[paste0(name, ".major_source")]] <- scale$get_breaks()
          }, error = function(e) {
            result[[paste0(name, ".major_source")]] <- NULL
          })
          
          tryCatch({
            result[[paste0(name, ".minor_source")]] <- scale$get_breaks_minor()
          }, error = function(e) {
            result[[paste0(name, ".minor_source")]] <- NULL
          })
          
          tryCatch({
            result[[paste0(name, ".labels")]] <- scale$get_labels()
          }, error = function(e) {
            result[[paste0(name, ".labels")]] <- NULL
          })
          
          result
        }
      })
    } else if (n == 'scales_add_missing') {
      # 创建包装函数，确保在找不到函数时不会出错
      # Create wrapper function to ensure no error when function not found
      original_fn <- tryCatch({
        get('scales_add_missing', envir = asNamespace('ggplot2'))
      }, error = function(e) NULL)
      
      if(!is.null(original_fn)) {
        ggint[[n]] <- function(plot, aesthetics, env) {
          aesthetics <- setdiff(aesthetics, plot$scales$input())
          find_global_fn <- tryCatch({
            get('find_global', envir = asNamespace('ggplot2'))
          }, error = function(e) NULL)
          
          if(is.null(find_global_fn)) {
            # 如果找不到 find_global，使用原始函数
            # If find_global not found, use original function
            return(original_fn(plot, aesthetics, env))
          }
          
          for (aes in aesthetics) {
            scale_name <- paste("scale", aes, "continuous", sep = "_")
            scale_f <- find_global_fn(scale_name, env, mode = "function")
            # 检查 scale_f 是否为函数，避免错误
            # Check if scale_f is a function to avoid errors
            if (!is.null(scale_f) && is.function(scale_f)) {
              plot$scales$add(scale_f())
            }
          }
          plot
        }
      }
    } else if (n %in% c('plot_clone', 'train_layout', 'map_layout', 'add_group', 
                       'scales_transform_df', 'train_position', 'map_position', 'order_groups',
                       'reset_scales', 'scales_train_df', 'scales_map_df',
                       'ggname', 'coord_transform.cartesian', 'expand_default')) {
      # 这些是 ggplot2 的内部函数，尝试直接访问
      # These are internal ggplot2 functions, try to access directly
      # 如果找不到，可能需要从 ggproto 方法中获取
      # If not found, may need to get from ggproto methods
    }
  }
}

# 获取 ggplot2 的 .element_tree 并添加 ggtern 的自定义元素
# Get ggplot2's .element_tree and add ggtern's custom elements
tryCatch({
  base_tree <- get('.element_tree', envir = asNamespace('ggplot2'), inherits = TRUE)
  ggint$.element_tree <- base_tree
  
  # 添加 ggtern 的自定义主题元素
  # Add ggtern's custom theme elements
  tern_elements <- list(
    # Panel backgrounds
    "tern.panel.background" = list(class = "element_rect", inherit = "panel.background"),
    "tern.plot.background" = list(class = "element_rect", inherit = "plot.background"),
    "tern.plot.latex" = list(class = "logical", inherit = NULL),
    
    # Axis lines
    "tern.axis.line" = list(class = "element_line", inherit = "axis.line"),
    "tern.axis.line.T" = list(class = "element_line", inherit = "tern.axis.line"),
    "tern.axis.line.L" = list(class = "element_line", inherit = "tern.axis.line"),
    "tern.axis.line.R" = list(class = "element_line", inherit = "tern.axis.line"),
    "tern.axis.line.ontop" = list(class = "logical", inherit = NULL),
    
    # Axis titles
    "tern.axis.title" = list(class = "element_text", inherit = "axis.title"),
    "tern.axis.title.T" = list(class = "element_text", inherit = "tern.axis.title"),
    "tern.axis.title.L" = list(class = "element_text", inherit = "tern.axis.title"),
    "tern.axis.title.R" = list(class = "element_text", inherit = "tern.axis.title"),
    "tern.axis.title.show" = list(class = "logical", inherit = NULL),
    
    # Axis text
    "tern.axis.text" = list(class = "element_text", inherit = "axis.text"),
    "tern.axis.text.T" = list(class = "element_text", inherit = "tern.axis.text"),
    "tern.axis.text.L" = list(class = "element_text", inherit = "tern.axis.text"),
    "tern.axis.text.R" = list(class = "element_text", inherit = "tern.axis.text"),
    "tern.axis.text.show" = list(class = "logical", inherit = NULL),
    
    # Arrows
    "tern.axis.arrow" = list(class = "element_line", inherit = "axis.line"),
    "tern.axis.arrow.T" = list(class = "element_line", inherit = "tern.axis.arrow"),
    "tern.axis.arrow.L" = list(class = "element_line", inherit = "tern.axis.arrow"),
    "tern.axis.arrow.R" = list(class = "element_line", inherit = "tern.axis.arrow"),
    "tern.axis.arrow.text" = list(class = "element_text", inherit = "axis.text"),
    "tern.axis.arrow.text.T" = list(class = "element_text", inherit = "tern.axis.arrow.text"),
    "tern.axis.arrow.text.L" = list(class = "element_text", inherit = "tern.axis.arrow.text"),
    "tern.axis.arrow.text.R" = list(class = "element_text", inherit = "tern.axis.arrow.text"),
    "tern.axis.arrow.sep" = list(class = "numeric", inherit = NULL),
    "tern.axis.arrow.show" = list(class = "logical", inherit = NULL),
    "tern.axis.arrow.start" = list(class = "numeric", inherit = NULL),
    "tern.axis.arrow.finish" = list(class = "numeric", inherit = NULL),
    
    # Ticks
    "tern.axis.ticks" = list(class = "element_line", inherit = "axis.ticks"),
    "tern.axis.ticks.major" = list(class = "element_line", inherit = "tern.axis.ticks"),
    "tern.axis.ticks.major.T" = list(class = "element_line", inherit = "tern.axis.ticks.major"),
    "tern.axis.ticks.major.L" = list(class = "element_line", inherit = "tern.axis.ticks.major"),
    "tern.axis.ticks.major.R" = list(class = "element_line", inherit = "tern.axis.ticks.major"),
    "tern.axis.ticks.length.major" = list(class = "unit", inherit = NULL),
    "tern.axis.ticks.length.minor" = list(class = "unit", inherit = NULL),
    "tern.axis.ticks.outside" = list(class = "logical", inherit = NULL),
    "tern.axis.ticks.primary.show" = list(class = "logical", inherit = NULL),
    "tern.axis.ticks.secondary.show" = list(class = "logical", inherit = NULL),
    "tern.axis.ticks.minor" = list(class = "element_line", inherit = "tern.axis.ticks"),
    "tern.axis.ticks.minor.T" = list(class = "element_line", inherit = "tern.axis.ticks.minor"),
    "tern.axis.ticks.minor.L" = list(class = "element_line", inherit = "tern.axis.ticks.minor"),
    "tern.axis.ticks.minor.R" = list(class = "element_line", inherit = "tern.axis.ticks.minor"),
    
    # Grids
    "tern.panel.grid.major" = list(class = "element_line", inherit = "panel.grid.major"),
    "tern.panel.grid.major.T" = list(class = "element_line", inherit = "tern.panel.grid.major"),
    "tern.panel.grid.major.L" = list(class = "element_line", inherit = "tern.panel.grid.major"),
    "tern.panel.grid.major.R" = list(class = "element_line", inherit = "tern.panel.grid.major"),
    "tern.panel.grid.major.show" = list(class = "logical", inherit = NULL),
    "tern.panel.grid.minor" = list(class = "element_line", inherit = "panel.grid.minor"),
    "tern.panel.grid.minor.T" = list(class = "element_line", inherit = "tern.panel.grid.minor"),
    "tern.panel.grid.minor.L" = list(class = "element_line", inherit = "tern.panel.grid.minor"),
    "tern.panel.grid.minor.R" = list(class = "element_line", inherit = "tern.panel.grid.minor"),
    "tern.panel.grid.minor.show" = list(class = "logical", inherit = NULL),
    "tern.panel.grid.ontop" = list(class = "logical", inherit = NULL),
    "tern.panel.mask.show" = list(class = "logical", inherit = NULL),
    "tern.panel.expand" = list(class = "numeric", inherit = NULL),
    "tern.panel.rotate" = list(class = "numeric", inherit = NULL),
    
    # Other axis options
    "tern.axis.hshift" = list(class = "numeric", inherit = NULL),
    "tern.axis.vshift" = list(class = "numeric", inherit = NULL),
    "tern.axis.clockwise" = list(class = "logical", inherit = NULL)
  )
  
  # 合并到 .element_tree
  # Merge into .element_tree
  ggint$.element_tree <- c(base_tree, tern_elements)
  
}, error = function(e) {
  warning("Failed to get .element_tree from ggplot2: ", e$message)
})

# 确保 ggint 被加载到全局环境
# Ensure ggint is loaded into global environment
assign('ggint', ggint, envir = .GlobalEnv)

cat("Created ggint object with", length(ggint), "items (including .element_tree)\n")

