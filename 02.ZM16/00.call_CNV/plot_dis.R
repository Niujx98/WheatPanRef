# 创建输出目录
output_dir <- "./plot"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# 定义绘图函数
plot_boundary_distance <- function(data, output_pdf) {
  # 设置 PDF 输出
  pdf(output_pdf, width = 12, height = 15, family = "GB1")
  par(mfrow = c(5, 4), mar = c(4, 4, 2, 1)) # 设置每页布局为5行4列，调整边距
  
  # 定义窗口标签
  window_labels <- colnames(data)[6:ncol(data)] # 使用列名作为窗口标签
  
  # 绘制每一行数据
  for (i in 1:nrow(data)) {
    row <- data[i, ]
    boundary_distance_sum <- as.numeric(row[6:ncol(data)]) # 提取数值列
    main_title <- paste(row[1:3], collapse = "_")          # 拼接标题为"chrom_start_end"
    
    # 绘制折线图
    plot(seq_along(boundary_distance_sum), boundary_distance_sum, type = "b", pch = 19,
         xlab = "", ylab = "",  # 坐标轴名称先留空
         xaxt = "n", col = "green4", lwd = 2, main = main_title, cex.main = 1.2)
    
    # 设置刻度标签
    axis(1, at = seq_along(boundary_distance_sum), labels = window_labels, cex.axis = 1)
    
    # 添加中文坐标轴名称
    mtext("窗口大小", side = 1, line = 2.5, family = "GB1", cex = 0.8) # X轴名称
    mtext("边界距离和", side = 2, line = 2.5, family = "GB1", cex = 0.8) # Y轴名称
  }
  
  dev.off() # 关闭 PDF
}

# 文件路径
input_file <- file.path("com_boundary_distances.txt")

# 检查输入文件是否存在
if (!file.exists(input_file)) {
  stop(paste("Input file not found:", input_file))
}

# 读取数据
data <- read.table(input_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# 检查数据格式是否符合要求
if (ncol(data) < 6) {
  stop("Data file must contain at least 6 columns: 'chrom', 'start', 'end', and numeric data.")
}

# 输出 PDF 文件路径
output_pdf <- file.path(output_dir, "com_boundary_distance_plots.pdf")

# 绘制图表
plot_boundary_distance(data, output_pdf)
cat(paste("Plots saved to:", output_pdf, "\n"))

