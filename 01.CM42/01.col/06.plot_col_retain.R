# 加载必要包 
library(ggplot2)
library(gridExtra)

# 定义函数用于读取文件并绘制线段图
generate_lineplot <- function(input_dir, output_pdf, x_label) {
  # 获取文件夹中所有 .coord.txt 文件
  coord_files <- list.files(input_dir, pattern = "\\.filtered_coords\\.txt$", full.names = TRUE)

  # 初始化存储所有图的列表
  plot_list <- list()

  for (file in coord_files) {
    # 检查文件是否为空
    if (file.info(file)$size == 0) {
      cat("Skipping empty file:", file, "\n")
      next
    }

    # 读取文件内容
    data <- read.table(file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

    # 提取文件名作为标题（去掉路径和后缀）
    title <- gsub("\\.filtered_coords\\.txt$", "", basename(file))

    # 提取区块长度并计算 X 轴范围
    region <- as.character(data$V9[1])
    range_start <- as.numeric(sub(".*:(\\d+)-\\d+$", "\\1", region))
#    range_end <- as.numeric(sub(".*-\\d+$", "", region))
#    region_length <- range_end - range_start
    range_end <- as.numeric(sub(".*-(\\d+)$", "\\1", region))
    region_length <- range_end - range_start

    # 绘制线段图
    plot <- ggplot(data, aes(x = V3, xend = V4, 
                            y = V1, yend = V2)) +
      geom_segment(color = "blue", linewidth = 0.3, alpha = 0.7) +  # 使用 linewidth
      labs(title = title, x = x_label, y = "CS") +                  # 添加轴标题
      scale_x_continuous(limits = c(0, region_length),               # 固定 X 轴范围
        labels = function(x) sprintf("%.1fM", x / 1e6)             # 转换为 Mb 格式，保留一位小数
      ) +          
      theme_minimal() +                                             # 简约主题
      theme(
        panel.border = element_rect(color = "black", fill = NA, linewidth = 1),  # 添加边框
        panel.grid = element_blank(),                                            # 移除网格线
        plot.title = element_text(size = 8, hjust = 0.5),                        # 标题居中
        axis.title = element_text(size = 10),                                    # 坐标轴标题字体
        axis.text = element_text(size = 8)                                       # 坐标轴刻度字体
      )


    # 将图存储到列表中
    plot_list <- append(plot_list, list(plot))
  }

  # 每页 5 行 x 4 列的布局
  num_plots <- length(plot_list)
  num_per_page <- 5 * 4
  num_pages <- ceiling(num_plots / num_per_page)

  # 创建 PDF，纵向 A4
  pdf(output_pdf, width = 8.5, height = 11)  # 纵向 A4

  # 分页绘制
  for (page in seq_len(num_pages)) {
    start_idx <- (page - 1) * num_per_page + 1
    end_idx <- min(page * num_per_page, num_plots)

    grid.arrange(
      grobs = plot_list[start_idx:end_idx],
      ncol = 4, nrow = 5
    )
  }

  # 关闭 PDF
  dev.off()
}

# 定义输入输出路径
sample_dirs <- c("./06.retain")
output_pdfs <- c("./plot/retain_col_CS.pdf")
sample_labels <- c("target_genome")

# 遍历样本文件夹并生成 PDF
for (i in seq_along(sample_dirs)) {
  generate_lineplot(input_dir = sample_dirs[i], 
                    output_pdf = output_pdfs[i], 
                    x_label = sample_labels[i])
}
