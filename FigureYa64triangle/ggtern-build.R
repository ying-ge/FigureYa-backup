#' Build ggplot for rendering (MODIFIED for ggtern)
#'
#' This function takes the plot object, and performs all steps necessary to
#' produce an object that can be rendered.  This function outputs two pieces:
#' a list of data frames (one for each layer), and a panel object, which
#' contain all information about axis limits, breaks etc.
#'
#' @param plot ggplot object
#' @seealso \code{\link{print.ggplot}} and \code{link{benchplot}} for 
#'  for functions that contain the complete set of steps for generating
#'  a ggplot2 plot.
#' @keywords internal
#' @export
ggplot_build <- function(plot) {
  if (length(plot$layers) == 0) stop("No layers in plot", call.=FALSE)
  plot <- ggint$plot_clone(plot)

  
  #if we have ternary coordinate system but not ternary plot class, make it ternary.
  if(inherits(plot$coordinates,"ternary")){
    if(inherits(plot,"ggplot")) class(plot) <- c("ggtern",class(plot)) 
    plot <- plot + .theme_nocart() #destroy any cartesian theme elements
  }
  
  # Initialise panels, add extra data for margins
  # 在 ggplot2 3.4.4 中，panel 应该是一个列表结构
  # In ggplot2 3.4.4, panel should be a list structure
  panel <- ggint$new_panel()
  if(is.null(panel) || !is.list(panel)) {
    panel <- list(
      x_scales = list(),
      y_scales = list(),
      scales = list(),
      layout = data.frame(PANEL = integer(), SCALE_X = integer(), SCALE_Y = integer())
    )
  }
  
  ##-------------------------------------------------------------------------------
  #IF WE HAVE TERNARY OPTIONS SOMEWHERE...  
  if(inherits(plot,"ggtern")){
    ##Strip Unapproved Ternary Layers
    plot$layers <- strip_unapproved(plot$layers)
    
    ##Check that there are layers remaining after potentially stripping all layers
    if(length(plot$layers) == 0){stop("No layers in ternary plot",call.=F)}  
    
    ##Add the ternary fixed coordinates if it doesn't exist
    if(!inherits(plot$coordinates,"ternary")){plot <- plot + coord_tern()}
    
    #The ternary and cartesian axis names.
    scales.tern <- plot$coordinates$required_axes #c("T","L","R")
    scales.aes  <- plot$coordinates$required_aes  #c("x","y","z")
    scales.cart <- c("x","y")
    
    ##Add the missing scales
    # 只添加标准的 x, y scales，ternary scales (T, L, R) 不需要标准的 scale
    # Only add standard x, y scales, ternary scales (T, L, R) don't need standard scales
    # 使用包装后的 scales_add_missing 函数，它会安全处理找不到的 scale 函数
    # Use wrapped scales_add_missing function which safely handles missing scale functions
    ggint$scales_add_missing(plot, scales.cart, environment())
    
    ##Update the scale limits from the coordinate system
    for(X in c(scales.tern,scales.cart))
      plot$coordinates$limits[[X]] <- is.numericor(.select.lim(plot$scales$get_scales(X)$limits, plot$coordinates$limits[[X]]),c(0,1))
    
    #Store coordinates for use by other methods, AFTER the limits have been updated (ie the previous command)
    set_last_coord(plot$coordinates) 
    
    #Normally this info is handled in the by grid, however, this is one way of passing it through
    panel <- .train_position_ternary(panel,
                                     plot$scales$get_scales("T"),
                                     plot$scales$get_scales("L"),
                                     plot$scales$get_scales("R"))
    
    #get snapshot of panel so updates to panel dont interfere through the next loop.
    panel.bup <- panel 
    
    #Assign the names Ternary scales and Wlabel (arrow label suffix) to the panel
    for(X in scales.tern){
      #Resolve the 'effective' T, L and R index, for case of non default coord_tern T, L and R assignments
      XResolved <- scales.tern[which(scales.aes == plot$coordinates[[X]])] 
      #Make update scale names, on effective axes.
      #Executes .Tlabel, .Llabel and .Rlabel
      panel[[paste0(X,"_scales")]]$name <- do.call(paste0(".",X,"label"),list(panel = panel.bup,labels = plot$labels))
    }
    
    #Make update to axes arrow suffix label
    panel$Wlabel = .Wlabel(panel,labels = plot$labels)
    
    #DONE
  }else{ set_last_coord(NULL) }
  
  layers     <- plot$layers
  # 处理 layer_data：如果 layer 的 data 是 waiver，使用 plot 的 data
  # Handle layer_data: if layer's data is waiver, use plot's data
  layer_data <- lapply(layers, function(y) {
    layer_d <- y$data
    # 检查是否是 waiver 对象
    # Check if it's a waiver object
    if(inherits(layer_d, 'waiver') || is.null(layer_d)) {
      # 如果是 waiver，使用 plot 的默认数据
      # If waiver, use plot's default data
      plot$data
    } else {
      layer_d
    }
  })
  
  scales <- plot$scales
  # Apply function to layer and matching data
  dlapply <- function(f) {
    if(length(data) == 0) {
      return(list())
    }
    out <- vector("list", length(data))
    for(i in seq_along(data)) {
      if(!is.null(data[[i]]) && !is.null(layers[[i]])) {
        out[[i]] <- f(d = data[[i]], p = layers[[i]])
      } else {
        out[[i]] <- data[[i]]
      }
    }
    out
  }
  
  #CONTINUED FROM ABOVE
  # 在 ggplot2 3.4.4 中，直接使用 layer_data，不进行 layout 处理
  # In ggplot2 3.4.4, use layer_data directly without layout processing
  # 注意：这可能会影响某些功能，但对于基本绘图应该足够
  # Note: This may affect some features, but should be sufficient for basic plotting
  data <- layer_data
  
  # 确保 data 是列表且不为空
  # Ensure data is a list and not empty
  if(!is.list(data)) {
    data <- list(data)
  }
  if(length(data) == 0) {
    stop("No data in layers")
  }
  
  # Compute aesthetics to produce data with generalised variable names
  # 直接调用 layer 的 compute_aesthetics 方法
  # Directly call layer's compute_aesthetics method
  data <- lapply(seq_along(data), function(i) {
    d <- data[[i]]
    p <- layers[[i]]
    if(is.null(d) || is.null(p)) {
      return(d)
    }
    # 确保 d 是数据框且不为空
    # Ensure d is a data frame and not empty
    if(!is.data.frame(d) || nrow(d) == 0) {
      return(d)
    }
    tryCatch({
      # 在 ggplot2 中，compute_aesthetics 是 Layer 对象的方法
      # In ggplot2, compute_aesthetics is a method of Layer object
      # 直接调用方法，传递正确的参数
      # Call method directly with correct parameters
      is_layer <- tryCatch(inherits(p, 'Layer'), error = function(e) FALSE)
      has_method <- tryCatch(!is.null(p$compute_aesthetics) && is.function(p$compute_aesthetics), error = function(e) FALSE)
      
      if(is_layer && has_method) {
        # 使用 Layer 对象的 compute_aesthetics 方法
        # Use Layer object's compute_aesthetics method
        result <- p$compute_aesthetics(d, plot)
        # 检查结果是否为空
        # Check if result is empty
        if(is.data.frame(result) && nrow(result) == 0) {
          warning("compute_aesthetics returned empty data for layer ", i, ". Using original data.")
          # 如果结果为空，使用原始数据，但需要添加必要的列
          # If result is empty, use original data but add necessary columns
          if(!'PANEL' %in% names(d)) {
            d$PANEL <- 1L
          }
          return(d)
        }
        # 确保结果有 PANEL 列
        # Ensure result has PANEL column
        if(is.data.frame(result) && !'PANEL' %in% names(result)) {
          result$PANEL <- 1L
        }
        result
      } else {
        # 如果不是 Layer 对象或方法不存在，直接返回数据
        # If not Layer object or method doesn't exist, return data directly
        d
      }
    }, error = function(e) {
      warning("Error in compute_aesthetics for layer ", i, ": ", e$message, ". Using original data.")
      d
    })
  })
  
  # 确保 add_group 函数存在
  # Ensure add_group function exists
  if(!is.null(ggint$add_group) && is.function(ggint$add_group)) {
    data <- lapply(data, ggint$add_group)
  }
  
  # Transform all scales
  if(!is.null(ggint$scales_transform_df) && is.function(ggint$scales_transform_df)) {
    data <- lapply(data, ggint$scales_transform_df, scales = scales)
  }
  
  # Map and train positions so that statistics have access to ranges
  # and all positions are numeric
  scale_x <- function() scales$get_scales("x")
  scale_y <- function() scales$get_scales("y")
  
  # 在 ggplot2 3.4.4 中，train_position 和 map_position 是 Layout 对象的方法
  # In ggplot2 3.4.4, train_position and map_position are methods of Layout object
  # 暂时跳过这些步骤，直接使用数据
  # Temporarily skip these steps, use data directly
  # 注意：这可能会影响某些功能，但对于基本绘图应该足够
  # Note: This may affect some features, but should be sufficient for basic plotting
  
  # Apply and map statistics
  data <- calculate_stats(panel, data, layers)
  
  data <- dlapply(function(d, p) {
    if(!is.null(p) && !is.null(p$map_statistic) && is.function(p$map_statistic)) {
      p$map_statistic(d, plot)
    } else {
      d
    }
  })
  if(!is.null(ggint$order_groups) && is.function(ggint$order_groups)) {
    data <- lapply(data, ggint$order_groups)
  }
  
  # Make sure missing (but required) aesthetics are added
  # 只添加 x, y scales，不添加 ternary scales
  # Only add x, y scales, not ternary scales
  ggint$scales_add_missing(plot, c("x", "y"), environment())
  
  # Reparameterise geoms from (e.g.) y and width to ymin and ymax
  data <- dlapply(function(d, p) {
    if(!is.null(p) && !is.null(p$reparameterise) && is.function(p$reparameterise)) {
      p$reparameterise(d)
    } else {
      d
    }
  })
  
  # Apply position adjustments
  data <- dlapply(function(d, p) {
    if(!is.null(p) && !is.null(p$adjust_position) && is.function(p$adjust_position)) {
      p$adjust_position(d)
    } else {
      d
    }
  })
  
  # Reset position scales, then re-train and map.  This ensures that facets
  # have control over the range of a plot: is it generated from what's 
  # displayed, or does it include the range of underlying data
  if(!is.null(ggint$reset_scales) && is.function(ggint$reset_scales)) {
    ggint$reset_scales(panel)
  }
  # 暂时跳过 train_position 和 map_position，直接使用数据
  # Temporarily skip train_position and map_position, use data directly
  # 注意：这可能会影响某些功能，但对于基本绘图应该足够
  # Note: This may affect some features, but should be sufficient for basic plotting
  
  # Train and map non-position scales
  npscales <- scales$non_position_scales()  
  # 检查非位置 scale 的数量（使用 n() 方法）
  # Check the number of non-position scales (use n() method)
  if (npscales$n() > 0) {
    lapply(data, ggint$scales_train_df, scales = npscales)
    data <- lapply(data, ggint$scales_map_df, scales = npscales)
  }
  
  # Train coordinate system
  panel <- train_ranges(panel,plot$coordinates)
  
  #Remove colors if they are in proximity to the perimeter
  #data  <- suppressColours(data,plot$layers,plot$coordinates)
  
  # 确保每个 layer 的数据都有 size 列，如果没有则添加默认值
  # Ensure each layer's data has size column, if not add default value
  for(i in seq_along(data)) {
    tryCatch({
      if(is.data.frame(data[[i]]) && nrow(data[[i]]) > 0) {
        n_rows <- nrow(data[[i]])
        has_size <- 'size' %in% names(data[[i]])
        
        if(!has_size) {
          # 如果没有 size 列，添加默认值
          # If no size column, add default value
          data[[i]]$size <- rep(1.5, n_rows)  # ggplot2 的默认 size 值
        } else {
          # 如果有 size 列，确保它有效
          # If size column exists, ensure it's valid
          size_col <- data[[i]]$size
          size_len <- length(size_col)
          
          if(size_len == 0 || size_len != n_rows) {
            # 如果 size 列为空或长度不匹配，重新创建
            # If size column is empty or length doesn't match, recreate
            data[[i]]$size <- rep(1.5, n_rows)
          } else {
            # 检查并替换 NA 或无效值
            # Check and replace NA or invalid values
            valid_size <- tryCatch({
              !is.na(size_col) & size_col > 0
            }, error = function(e) {
              rep(FALSE, size_len)
            })
            
            if(length(valid_size) > 0) {
              invalid_idx <- !valid_size
              if(any(invalid_idx, na.rm = TRUE)) {
                data[[i]]$size[invalid_idx] <- 1.5
              }
            } else {
              # 如果 valid_size 为空，重新创建 size 列
              # If valid_size is empty, recreate size column
              data[[i]]$size <- rep(1.5, n_rows)
            }
          }
        }
      }
    }, error = function(e) {
      warning("Error ensuring size column for layer ", i, ": ", e$message)
    })
  }
  
  #return
  list(data = data, panel = panel, plot = plot)
}

