
#this function creates a figure of chromosomes ideograms showing the positions of SNPs of interest
#input: a file of SNP information as an output of the VEP (https://www.ensembl.org/Tools/VEP)
#output: a figure of ideograms spotted with the snps of interest.

chromOverview<-function (vepResults){
  #extract snp position
  vepResults<-unique(vepResults, by = c("#Uploaded_variation","Location", "Consequence"))
  chromosomes<-sapply(strsplit(vepResults$Location,":"),"[",1)
  chr<-paste0("chr",chromosomes)
  positions<-sapply(strsplit(vepResults$Location,"-"),"[",2)
  
  snp_locations<-cbind(hgnc_symbol=vepResults$SYMBOL, rsid=vepResults[,1], 
                       chr=chr,pos=positions,gene=vepResults$Gene, consequence=vepResults$Consequence)
  colnames(snp_locations)[2]<-"rsid"
  
  #keep one consequence per variant
  snp_locations2<-unique(snp_locations, by =c("rsid","chr","pos"))
  
  #make DF GRange object
  snp_locations2$pos <- as.numeric(snp_locations2$pos)
  target <- with(snp_locations2,
                 GRanges( seqnames = Rle(chr),
                          ranges   = IRanges(pos, end=pos, names=rsid),
                          strand   = Rle(strand("*"))) )
  target$symbol<-snp_locations2$gene
  #load ideogram data for hg19 Genome Assembly
  data(hg19IdeogramCyto, package = "biovizBase")
  getOption("biovizBase")$cytobandColor
  hg19 <- keepSeqlevels(hg19IdeogramCyto, paste0("chr", c(1:22, "X","Y")),pruning.mode="coarse" )
  #create plot in current directory
  tiff(file.path(getwd(),"SNPsinKaryogram.tiff"), width = 6, height = 6, units = 'in',res = 300)
  p <- ggplot(hg19) + layout_karyogram(cytobands = TRUE )+theme(legend.position="none")
  p <- p + layout_karyogram(target, geom = "rect", 
                            legend.position="none",
                            rect.height = 10,
                            ylim = c(11, 21), 
                            color = "darkorange") 
  print(p)
  dev.off()
  return(snp_locations2)
}