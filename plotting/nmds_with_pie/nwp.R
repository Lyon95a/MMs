library(tidyr)
library(dplyr)

data=read.csv("/Users/a1-6/Project-helsinki/M_Ms/plotting/nmds_with_pie/timeseries.csv",header = T)
tax=as.data.frame(t(data[1,]))
otu=data[-1,-1]
otu1=otu[,-1]
otu1 = as.data.frame(apply(otu1, 2, as.numeric))
rownames(otu1)=otu$Sample
otu1=otu1[-c(253,254,255),]

treat=data[,c(1,2)]
treat <- separate(treat, ID,into =c("treat","time","hive"), sep = "_")[-c(1,253,254,255),]
rownames(treat)=treat$Sample
treat=treat[,-4]
#####
#subset
treat_sub=treat[treat$treat == "TreatDFM",]
treat_sub_otu=otu1[row.names(otu1) %in% row.names(treat_sub),]
treat_sub_otu1=cbind(treat_sub$time,treat_sub_otu)
df1=data.frame()
for (i in 1:length(treat_sub_otu1[-1])){
  x=as.data.frame(aggregate(treat_sub_otu1[i+1], by=list(type=treat_sub_otu1$`treat_sub$time`),mean))
  df1$i=x[,2]
}
x=aggregate(treat_sub_otu1[2], by=list(type=treat_sub_otu1$`treat_sub$time`),mean)
str(x)
###################










library(vegan)
library(ggplot2)

set.seed(222322)
n_samples <- 10
n_dimensions <- 1
data <- data.frame(rnorm(n_samples * n_dimensions), ncol = n_dimensions)

# 使用 NMDS 对数据进行降维
nmds_result <- metaMDS(data)

plot(nmds_result$points)
# 根据 NMDS 结果将数据聚类成4个簇
cluster <- kmeans(nmds_result$points, centers = 4)

# 输出每个样本所属的簇
print(cluster$cluster)

data1=data.frame(nmds_result$points)
data1$timestep=paste0("ts", 1:10)
data1$cluster=cluster$cluster

segments_data <- data.frame(
  x = c(data1$MDS1[-10]),
  xend = c(data1$MDS1[-1]),
  y = c(data1$MDS2[-10]),
  yend = c(data1$MDS2[-1])
)

mid_points <- data.frame(
  x = (data1$MDS1[-10] + data$MDS1[-1]) / 2,
  y = (data$MDS2[-10] + data$MDS2[-1]) / 2
)


plot <- ggplot(data1,aes(x=MDS1,y=MDS2))+
  geom_point() +
  geom_curve(data = segments_data, aes(x = x, y = y, xend = xend, yend = yend),
             arrow = arrow(length = unit(0.1, "inches"),ends="first"), curvature = 0.4,angle=160)

plot_range <- layer_scales(plot)$x
x_range <- layer_scales(plot)$x$range$range
y_range <- layer_scales(plot)$y$range$range
x_center <- mean(x_range)
y_center <- mean(y_range)

ggplot(data1,aes(x=MDS1,y=MDS2))+
  geom_point() +
  geom_curve(data = segments_data, aes(x = x, y = y, xend = xend, yend = yend),
             arrow = arrow(length = unit(0.1, "inches"),ends="first"), curvature = 0.4,angle=160)+geom_point(x=x_center,y=y_center)

# 计算 x 和 y 的中心位置
coor_poly1=data.frame(
  x = c(1, 2, 2, 1),  # 多边形的 x 坐标
  y = c(1, 1, 2, 2)   # 多边形的 y 坐标
)

center b 
if xmin>x center b, xmax >x center b, 且 ymin>y center b, ymax >y center b
point a = xmax, ymin-1
point b = xmin-1, ymax
point c = xmax, ymax





