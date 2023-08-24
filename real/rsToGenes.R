rsToGenes <- function(rsids) {
  server <- "https://grch37.rest.ensembl.org"
  
  genes<-c()
  for (j in 1:length(rsids)){
    ext <- paste0("/vep/human/id/",rsids[j],"?")
    r <- GET(paste(server, ext, sep = ""), content_type("application/json"),
             query="Mastermind")
    #extact genes
    list<-content(r)
    genesRS<-c()
    for (m in 1:length(list[[1]]$transcript_consequences)){
      genesRS[m]<-list[[1]]$transcript_consequences[[m]]$gene_symbol
    }
    genes<-c(genes,unique(genesRS))
    genes<-unique(genes)
    print(j)
  }
  
  return(genes)
  
}