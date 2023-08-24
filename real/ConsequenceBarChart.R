#this function creates a bar plot of the consequences of SNPs per chromosome
#input: a file of SNP information as an output of the VEP (https://www.ensembl.org/Tools/VEP)
#output: a bar plot of SNP consequences per chromosome

ConsequenceBarChart<-function (vepResults){
  #extract snp position
  vepResults<-unique(vepResults, by = c("#Uploaded_variation","Location", "Consequence"))
  chromosomes<-sapply(strsplit(vepResults$Location,":"),"[",1)
  chr<-paste0("chr",chromosomes)
  positions<-sapply(strsplit(vepResults$Location,"-"),"[",2)
  snp_locations<-cbind(hgnc_symbol=vepResults$SYMBOL, rsid=vepResults[,1], 
                       chr=chr,pos=positions,gene=vepResults$Gene, consequence=vepResults$Consequence)
  #find chromosomes that include SNPs of interest
  chrms<-unique(snp_locations$chr)
  #remove duplicates
  consequences<-unique(snp_locations$consequence)
  #compute percentages of each consequence per chromosome
  b<-matrix(NA,nrow = length(chrms),ncol=length(consequences))
  for (i in 1:length(chrms)){
    if (chrms[i] %in% snp_locations$chr){
      a<-c()
      for (j in 1:length(consequences)){
        a[j]<- length(which(snp_locations$chr==chrms[i] & snp_locations$consequence==consequences[j]))/length(which(snp_locations$chr==chrms[i]))
      }
      b[i,] <-a
    } else {
      b[i,] <-rep(0,length(consequences)) 
      
    }
  }
  row.names(b)<-chrms
  colnames(b)<-consequences
  
  #create color palette for the stacked bar chart
  getPalette = colorRampPalette(brewer.pal(12, "Paired"))
  color<-length(unique(snp_locations$consequence))
  
  df<-as.data.frame(as.table(b))
  #sort df chromosome order in karyotype
  colnames(df)<-c("chr","consequences","freq")
  target <- c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10",
              "chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20",
              "chr21","chr22","chrX","chrY")
  
  new_order <- sapply(target, function(x,df){which(df$chr == x)}, df=df)
  df2<-data.frame()
  for (i in 1:length(new_order)){
    if (length(new_order[[i]])!=0){
      df2<- rbind(df2,df[new_order[[i]],])
    }
  }
  
  tiff(file.path(getwd(),"SNPinKaryogramBarChart.tiff"), width = 8, height = 8, units = 'in',res = 300)
  
  p<-ggplot(df2, aes(x = chr, y = freq, fill=consequences)) +
    geom_bar(stat="identity", width=.7) +
    #scale_x_discrete(expand=c(0,0)) +
    scale_x_discrete(limits = rev(target))+
    scale_y_continuous(expand=c(0,0)) +
    scale_fill_manual(values = getPalette(color)) +
    coord_flip()+
    theme(legend.position="top")+
    theme(axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.y=element_blank(),
          legend.key.width = unit(0.5, 'cm'))+
    guides(fill=guide_legend(nrow=5, ncol=4))
  
  print(p)
  dev.off()
}