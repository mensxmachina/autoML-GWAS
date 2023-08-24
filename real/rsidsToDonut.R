#this function creates a donut plot of SNP consequences
#input file: a txt file of all equivalent signatures reported by JAD and a name for saving the image


rsidsToDonut <- function (rsids,filename){
  #rsids should be a character vector of rsids
  rsids<-as.character(rsids[1,])
  server <- "https://grch37.rest.ensembl.org"
  consequencesALL<-c()
  impactALL<-c()
  for (j in 1:length(rsids)){
    ext <- paste0("/vep/human/id/",rsids[j],"?")
    r <- GET(paste(server, ext, sep = ""), content_type("application/json"),
             query="Mastermind")
    list<-content(r)
    consequences<-c()
    impact<-c()
    for (m in 1:length(list[[1]]$transcript_consequences)){
      consequences[m]<-list[[1]]$transcript_consequences[[m]]$consequence_terms
      impact[m]<-list[[1]]$transcript_consequences[[m]]$impact
    }
    
    consequences<-unlist(consequences)
    impact<-unlist(impact)
    consequencesALL<-c(consequencesALL,consequences)
    impactALL<-c(impactALL,impact)
  }
  dat<-as.data.frame(cbind(consequencesALL,impactALL))
  data <- dat %>%
    group_by(consequencesALL) %>%
    summarise(cnt = n()) 
  
  impact<- dat$impactALL[match(data$consequencesALL,dat$consequencesALL)]
  mydata<-cbind.data.frame(impact,data)
  #mutate(freq = round(cnt / sum(cnt), 3)) 
  
  
  
  
  #image...............
  #pdffile  <- paste0(filename,"-Donut.pdf")
  #pdf(pdffile, 8, 8);
  #par(mar=c(2, 2, 2, 2));
  #plot(c(1,800), c(1,800), type="n", axes=F, xlab="", ylab="");
  tiff(paste0(filename,"-Donut.tiff"), width = 10, height = 10, units = 'in',res = 300)
  
  PieDonutCustom(mydata, aes(impact, consequencesALL, count=cnt),
                 ratioByGroup = FALSE,
                 #only for multiple sclerosis
                 explode=c(2,3),
                 selected = c(2,3),
                 explodeDonut=TRUE,
                 explodePie=TRUE,
                 ######################
                 labelposition=2,
                 labelpositionThreshold = 0.1,
                 # labelpositionThreshold = 0.1,
                 pieLabelSize=4,
                 donutLabelSize=3,
                 r0 = 0.45, r1 = 0.9,
                 showRatioThreshold = F,
                 #showRatioThreshold = F,
                 palette_name = "Dark2")
  
  
  dev.off()
  
  
  
}