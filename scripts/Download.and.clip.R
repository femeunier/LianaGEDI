rm(list = ls())

# library(devtools)
# devtools::install_github("carlos-alberto-silva/rGEDI", dependencies = TRUE,force =TRUE)

# loading rGEDI package
library(rGEDI)
library(LianaGEDI)
library(dplyr)
library(ggplot2)

# Study area boundary box coordinates
site.name <- "BCI"
ul_lat<- 9.1
lr_lat<- 9.3
ul_lon<- -79.8
lr_lon<- -80.0

# Harvard
site.name <- "Harvard"
ul_lat<- 42.5
lr_lat<- 42.55
ul_lon<- -72.15
lr_lon<- -72.2

site.name <- "Paracou"
ul_lat<- 5.2
lr_lat<- 5.4
ul_lon<- -52.8
lr_lon<- -53

site.name <- "Gigante"
ul_lat<- 9.05
lr_lat<- 9.1
ul_lon<- -79.85
lr_lon<- -79.9

# Get path to GEDI data
gLevel1B <- gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2A <- gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2B <- gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")

# Set output dir for downloading the files
# outdir=file.path(getwd(),"data")
outdir <- file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/",site.name)
if(!exists(outdir)) dir.create(outdir)

# Downloading GEDI data
gediDownload(filepath=gLevel1B,outdir=outdir)
gediDownload(filepath=gLevel2A,outdir=outdir)
gediDownload(filepath=gLevel2B,outdir=outdir)

ymin = 42.4
ymax = 42.6
xmin = -72.1
xmax = -72.4

# Reading GEDI data
for (ifile in seq(1,length(gLevel1B))){
  gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir,basename(gLevel1B[ifile])))

  level1b_clip_bb <- tryCatch(clipLevel1B(gedilevel1b, xmin, xmax, ymin, ymax,output= file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel1B[ifile])),"_sub.h5"))),
                              error = function(err){NA})
  close(gedilevel1b)
  if (!is.na(level1b_clip_bb)) close(level1b_clip_bb)
}

for (ifile in seq(1,length(gLevel2A))){
  gedilevel2a<-readLevel2A(level2Apath = file.path(outdir,basename(gLevel2A[ifile])))

  level2a_clip_bb <- tryCatch(clipLevel2A(gedilevel2a, xmin, xmax, ymin, ymax,output= file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2A[ifile])),"_sub.h5"))),
                              error = function(err){NA})
  close(gedilevel2a)
  if (!is.na(level2a_clip_bb)) close(level2a_clip_bb)
}

for (ifile in seq(1,length(gLevel2B))){
  gedilevel2b<-readLevel2B(level2Bpath = file.path(outdir,basename(gLevel2B[ifile])))

  level2b_clip_bb <- tryCatch(clipLevel2B(gedilevel2b, xmin, xmax, ymin, ymax,output= file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2B[ifile])),"_sub.h5"))),
                              error = function(err){NA})
  close(gedilevel2b)
  if (!is.na(level2b_clip_bb)) close(level2b_clip_bb)
}




