require("dplyr")
cust_data=read.csv("C:/Users/GK/Desktop/Wholesale customers data.csv",header = TRUE)
IDCust_data=mutate(cust_data,ID=1:440)
IDs=apply(cust_data,2,function(x) sort(x,index.return=TRUE,decreasing = TRUE))
top6spenderIDs <- unique(c(IDs$Fresh$ix[1:6], 
                           IDs$Milk$ix[1:6], 
                           IDs$Grocery$ix[1:6],
                           IDs$Frozen$ix[1:6],
                           IDs$DP$ix[1:6], 
                           IDs$Deli$ix[1:6]))

cust_data_processed <- cust_data[-top6spenderIDs,]

dist_customers <- dist(cust_data_processed, method = "euclidean")

hc_customers <- hclust(dist_customers, method = "complete")

library(factoextra)
fviz_dend(hc_customers, show_labels = FALSE, main = "Uncut Dendrogram")

cluster_assign <- cutree(hc_customers, h = 40000)

table(cluster_assign)
k_colors=c("#2E9FDF", "#00AFBB", "#E7B800")
fviz_dend()
fviz_dend(hc_customers,k=3,show_labels = FALSE,
          k_colors = k_colors,
          rect_border = k_colors,
          rect_fill = TRUE,
          color_labels_by_k = TRUE,
          main = "Three Cluster Dendrogram"
         )


data_segmented <- mutate(cust_data_processed, Cluster = cluster_assign)

library(magrittr)

data_segmented %>%
  group_by(Cluster) %>%
  summarise_all(list(~round(mean(.,na.rm=TRUE)))) %>%
  mutate(TotalSpend = rowSums(.[2:7]), ClusterSize = as.integer(c(332,49,37)))

