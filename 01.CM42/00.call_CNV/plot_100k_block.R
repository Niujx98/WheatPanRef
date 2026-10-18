# 配置参数
base_dir <- "./"  # 当前目录
window_combinations <- c(
                         "win_100k_step_20k", "win_50k_step_10k", "win_40k_step_8k",
                         "win_30k_step_6k", "win_20k_step_4k", "win_10k_step_2k")  # 窗口组合，从大到小

# 定义函数：读取区块文件
read_blocks <- function(file_path) {
  if (!file.exists(file_path)) {
    cat("File not found:", file_path, "\n")
    return(NULL)
  }
  blocks <- read.table(file_path, header = FALSE, sep = "\t", 
                       col.names = c("chrom", "start", "end"), 
                       stringsAsFactors = FALSE)  # 将 chrom 列读取为字符类型
  return(blocks)
}

# 定义函数：筛选与基准区块重叠的区块
get_overlapping_blocks <- function(base_block, compare_blocks) {
  if (is.null(compare_blocks)) {
    return(data.frame(chrom = character(), start = numeric(), end = numeric()))
  }
  overlapping <- subset(compare_blocks,
                        chrom == base_block$chrom & 
                        end >= base_block$start & 
                        start <= base_block$end)
  return(overlapping)
}

# 确保绘图输出目录存在
output_dir <- "./plot"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# 输出PDF文件
pdf(file = file.path(output_dir, "block_100k_distribution.pdf"), width = 8.27, height = 11.69)  # A4 大小

# 设置页面布局：每页5行，每行4列
par(mfrow = c(5, 4), mar = c(4, 4, 2, 1), mgp = c(2.5, 1, 0))  # 设置布局和边距, mgp 控制 x 轴位置

# 读取 1Mb 窗口的区块
base_file <- file.path(base_dir, paste0("com_", window_combinations[1], "_del_block.txt"))
cat("Looking for file:", base_file, "\n")
base_blocks <- read_blocks(base_file)
if (is.null(base_blocks)) {
  cat("No 1Mb blocks found. Exiting.\n")
  dev.off()
  stop("No base blocks found.")
}

# 遍历每个 1Mb 区块
for (i in 1:nrow(base_blocks)) {
  base_block <- base_blocks[i, ]
  
  # 初始化绘图区域
  plot(0, 0, type = "n", xlab = "Genomic Position (Mb)", ylab = "Window size",
       xlim = c(base_block$start, base_block$end), ylim = c(0, 6),
       main = paste(base_block$chrom, base_block$start, base_block$end), cex.main = 0.8,
       bty = "n", yaxt = "n", xaxt = "n")  # 去除边框和y轴刻度
  
  # 自定义x轴，显示Mb单位
  axis(1, at = seq(base_block$start, base_block$end, by = 1000000), 
       labels = seq(base_block$start / 1e6, base_block$end / 1e6, by = 1), 
       las = 1, cex.axis = 0.8)
  
  # 自定义Y轴，间距为1，刻度标签为窗口大小
  axis(2, at = 0:6, labels = c("0",  "100k", "50k", "40k", "30k", "20k", "10k"), cex.axis = 0.8, las = 1)
  
  # 绘制重叠的区块
  for (j in seq_along(window_combinations)) {
    current_window <- window_combinations[j]
    compare_file <- file.path(base_dir, paste0("com_", current_window, "_del_block.txt"))
    cat("Looking for file:", compare_file, "\n")
    compare_blocks <- read_blocks(compare_file)
    
    # 获取与当前基准区块重叠的区块
    overlapping <- get_overlapping_blocks(base_block, compare_blocks)
    if (nrow(overlapping) == 0) {
      next
    }
    
    # 绘制重叠的区块，使用指定的颜色和无边框
    for (k in 1:nrow(overlapping)) {
      rect(overlapping$start[k], j - 0.4, overlapping$end[k], j + 0.4, col = "#104e8b", border = NA)
    }
  }
}

# 关闭PDF输出
dev.off()
cat("Saved PDF: block_distribution.pdf\n")

