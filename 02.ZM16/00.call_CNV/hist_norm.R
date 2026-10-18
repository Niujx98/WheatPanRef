# 创建输出文件夹
output_dir <- "./plot"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# 设置输出 PDF 文件
pdf(file = file.path(output_dir, "hist_norm.pdf"), width = 11, height = 8.5)

# 设置多图布局：4列5行
par(mfrow = c(5, 4), mar = c(4, 4, 2, 1))

# 循环遍历每个w值并绘图
for (w in c("win_1Mb_step_200k", "win_500k_step_100k", "win_200k_step_40k", "win_100k_step_20k", 
            "win_50k_step_10k", "win_40k_step_8k", "win_30k_step_6k", "win_20k_step_4k", "win_10k_step_2k")) {
  
  # 读取文件数据
  file_name <- paste0("com.", w, ".norm")
  data <- scan(file_name)  # 使用 scan 读取文件并自动转换为向量
  
  # 筛选 <= 2.0 的值
  data <- data[data <= 2.0]  # 直接对向量进行过滤
  
  # 绘制直方图
  hist(data, breaks = 50, main = paste("Histogram: ", w), xlab = "Value", col = "lightblue", border = "black")
}

# 关闭 PDF 输出
dev.off()

