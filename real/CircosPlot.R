#this function creates a circos plot showing SNP positions
#input file: a txt file of all equivalent signatures reported by JAD and a name for saving the image

CircosPlot<-function (rsids,filename){
  rsids<-as.character(rsids[1,])
  genes<-rsToGenes(rsids)
  #get data from ensembl
  ensembl = useEnsembl(biomart = "ensembl", GRCh=37, dataset = "hsapiens_gene_ensembl")
  snpmart = useEnsembl(biomart = "ENSEMBL_MART_SNP", GRCh=37, dataset="hsapiens_snp")
  #use only chromosomes 1:22 and X, Y
  normal.chroms <- c(1:22, "X", "Y")
    
    
    
    my.regions <- getBM(c("chromosome_name", "start_position", "end_position", "external_gene_name"),
                        filters = c("external_gene_name", "chromosome_name"),
                        values = list(hgnc_symbol=genes, chromosome_name=normal.chroms),
                        mart = ensembl)
    
    my.regionsSNPS <- getBM(attributes = c("refsnp_id", "chr_name", "chrom_start"), 
                            filters = "snp_filter", 
                            values = rsids, 
                            mart = snpmart)
      
    my.regions$chromosome_name<-paste0("chr",my.regions$chromosome_name)
    genesDT<-data.frame(chr=my.regions$chromosome_name,
                        start=as.numeric(my.regions$start_position), 
                        end=as.numeric(my.regions$end_position),
                        gene=my.regions$external_gene_name) 
    
       vepResults3 <- my.regionsSNPS %>%
      filter(chr_name %in% normal.chroms)
    
    snpsDT<-data.frame(chr=paste0("chr",vepResults3$chr_name),
                       start=as.numeric(vepResults3$chrom_start), 
                       end=as.numeric(vepResults3$chrom_start),
                       gene=vepResults3$refsnp_id) 
    snpsDT<-unique(snpsDT)
    
    
    tiff(paste0(filename,"-Circos.tiff"),width=8,height=8,units='in',res=300)
    
    circos.clear()
    circos.initializeWithIdeogram(plotType = NULL)
    circos.genomicLabels(snpsDT, labels.column = 4, side = "outside",
                         #col = as.numeric(factor(snpsDT[[1]])), 
                         #line_col = as.numeric(factor(snpsDT[[1]])),
                         niceFacing = T)
    circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
      chr = CELL_META$sector.index
      xlim = CELL_META$xlim
      ylim = CELL_META$ylim
      circos.rect(xlim[1], 0, xlim[2], 1, col = "white")
      circos.text(mean(xlim), mean(ylim), chr, cex = 0.5, col = "black",
                  facing = "inside", niceFacing = TRUE)
    }, track.height = 0.07, bg.border = "white")
    
    
    circos.genomicIdeogram(species = "hg19",
                           track.height = convert_height(5, "mm"))
    
    
    #circos.initializeWithIdeogram(species = "hg19",
    #                              ideogram.height = convert_height(5, "mm"),
    #                              plotType = c("ideogram","labels"))
    
    circos.genomicLabels(genesDT, labels.column = 4, side = "inside",
                         #col = as.numeric(factor(genesDT[[1]])), 
                         #line_col = as.numeric(factor(genesDT[[1]])),
                         facing = "reverse.clockwise",
                         cex = 0.6,
                         niceFacing = T)
    dev.off()
  } 
