rm(list=ls())
options(stringsAsFactors=FALSE)

library(Gviz)
library(biomaRt)
library(ggplot2)
library(GenomicRanges)
library(data.table)
library(RColorBrewer)
library(ggbio)

#work in current directory
WD <- getwd()
if (!is.null(WD)) setwd(WD)

source("chromOverview.R")
source("ConsequenceBarChart.R")




loadFile<-"heightVEP-JAD-37-50snps2.txt"
vepResults<-fread(file.path(WD,loadFile))
#create Karyogram with SNPs locations
chromOverview(vepResults)
#create stacked bar chart with SNP consequences
ConsequenceBarChart(vepResults)
#compute percentage of snps per chromosome
snp_locations2<-chromOverview(vepResults)
chromSNPs<-table(snp_locations2$chr)

percentages<-(chromSNPs/sum(chromSNPs))*100
write.table(percentages,file=file.path(getwd(),"chromSNPsP.txt"),sep="\t")

