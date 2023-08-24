#this code creates the individual parts (circos plots and donut plots) of Figure 2 of the paper: 
#Automated machine learning for Genome Wide Association Studies
rm(list=ls())
options(stringsAsFactors=F)

library("circlize")
library("data.table")
library("biomaRt")
library("dplyr")
library("httr")
library("jsonlite")
library("xml2")
library("moonBook")
library("webr")
library("ggplot2")
library("tidyr")

#work in current directory
WD <- getwd()
if (!is.null(WD)) setwd(WD)

source("rsToGenes.R")
source("rsidsToDonut.R")
source("PieDonutCustom.R")
source("CircosPlot.R")



#example for Multiple Sclerosis
filename<-"Multiple Sclerosis"
#read a txt file of all equivalent signatures reported by JAD
rsids<-fread(paste0(filename,"_equiv_combs.txt"),header=F)

#create Circos plot
CircosPlot(rsids,filename)
#create donut plot
rsidsToDonut(rsids,filename)
