rm(list = ls())

# library(devtools)
# devtools::install_github("carlos-alberto-silva/rGEDI", dependencies = TRUE)

# loading rGEDI package
library(rGEDI)
library(LianaGEDI)
library(dplyr)
library(ggplot2)

# Study area boundary box coordinates
# site.name <- "BCI"
# ul_lat<- 9.1
# lr_lat<- 9.2
# ul_lon<- -79.8
# lr_lon<- -79.9

site.name <- "Paracou"
ul_lat<- 5.2
lr_lat<- 5.4
ul_lon<- -52.8
lr_lon<- -53

# site.name <- "Gigante"
# ul_lat<- 9.05
# lr_lat<- 9.1
# ul_lon<- -79.85
# lr_lon<- -79.9

# Get path to GEDI data
gLevel1B <- gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2A <- gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2B <- gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")

# Set output dir for downloading the files
# outdir=file.path(getwd(),"data")
outdir <- file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/",site.name)
# if(!exists(outdir)) dir.create(outdir)

# Downloading GEDI data
# LianaGEDI::gediDownload(filepath=gLevel1B,outdir=outdir)
# LianaGEDI::gediDownload(filepath=gLevel2A,outdir=outdir)
# LianaGEDI::gediDownload(filepath=gLevel2B,outdir=outdir)

# Reading GEDI data
for (ifile in seq(1,length(gLevel1B))){
 gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir,basename(gLevel1B[ifile])))
 clipLevel1B(gedilevel1b,lr_lon,ul_lon,ul_lat,lr_lat,file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel1B[ifile])),"_sub.h5")))
}

for (ifile in seq(1,length(gLevel2A))){
  gedilevel2a<-readLevel2A(level2Apath = file.path(outdir,basename(gLevel2A[ifile])))
  clipLevel2A(gedilevel2a,lr_lon,ul_lon,ul_lat,lr_lat,file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2A[ifile])),"_sub.h5")))
}

for (ifile in seq(1,length(gLevel2B))){
  gedilevel2b<-readLevel2B(level2Bpath = file.path(outdir,basename(gLevel2B[ifile])))
  clipLevel2B(gedilevel2b,lr_lon,ul_lon,ul_lat,lr_lat,file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2B[ifile])),"_sub.h5")))
}

# gedilevel2a<-readLevel2A(level2Apath = paste0(outdir,"/GEDI02_A_2019108080338_O01964_T05337_02_001_01_sub.h5"))
# gedilevel2b<-readLevel2B(level2Bpath = paste0(outdir,"/GEDI02_B_2019108080338_O01964_T05337_02_001_01_sub.h5"))

for (ifile in seq(1,length(gLevel1B))){
  gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir,basename(gLevel1B[ifile])))
  level1bGeo<-getLevel1BGeo(level1b=gedilevel1b,select=c("elevation_bin0"))
  level1bGeo<-getLevel1BGeo(level1b=gedilevel1b,select=c("elevation_bin0"))
  saveRDS(level1bGeo,file.path(outdir,paste0("level1bGeo",ifile,".RDS")))
}

# Transfer files

# Read files
outdir <- file.path(getwd(),"data",site.name)
for (ifile in seq(1,length(gLevel1B))){
  level1bGeo_temp <-readRDS(file.path(outdir,paste0("level1bGeo",ifile,".RDS")))
  if (ifile == 1){
    level1bGeo <- level1bGeo_temp
  } else {
    level1bGeo <- rbind(level1bGeo,level1bGeo_temp)
  }
}

level1bGeo <- level1bGeo %>% filter(longitude_bin0 <= ul_lon & longitude_bin0>=lr_lon) %>%
  filter(latitude_bin0 <= lr_lat & latitude_bin0 >= ul_lat)
level1bGeo$shot_number<-paste0(level1bGeo$shot_number)

head(level1bGeo)
##           shot_number latitude_bin0 latitude_lastbin longitude_bin0 longitude_lastbin elevation_bin0
##  1: 19640002800109382     -13.75903        -13.75901      -44.17219         -44.17219       784.8348
##  2: 19640003000109383     -13.75862        -13.75859      -44.17188         -44.17188       799.0491
##  3: 19640003200109384     -13.75821        -13.75818      -44.17156         -44.17156       814.4647
##  4: 19640003400109385     -13.75780        -13.75777      -44.17124         -44.17124       820.1437
##  5: 19640003600109386     -13.75738        -13.75736      -44.17093         -44.17093       821.7012
##  6: 19640003800109387     -13.75697        -13.75695      -44.17061         -44.17061       823.2526

# Converting shot_number as "integer64" to "character"
# level1bGeo$shot_number<-paste0(level1bGeo$shot_number)
# level1bGeo <- level1bGeo[(!is.na(level1bGeo$longitude_bin0) & !is.na(level1bGeo$latitude_bin0)),]

# Converting level1bGeo as data.table to SpatialPointsDataFrame
library(sp)
level1bGeo_spdf<-SpatialPointsDataFrame(cbind(level1bGeo$longitude_bin0, level1bGeo$latitude_bin0),
                                        data=level1bGeo)

# Exporting level1bGeo as ESRI Shapefile
raster::shapefile(level1bGeo_spdf,paste0(outdir,"\\GEDI01_B_2019138232137_O02440_T00856_02_003_01_sub"))

library(leaflet)
library(leafsync)

leaflet() %>%
  addCircleMarkers(level1bGeo$longitude_bin0,
                   level1bGeo$latitude_bin0,
                   radius = 1,
                   opacity = 1,
                   color = "red")  %>%
  addScaleBar(options = list(imperial = FALSE)) %>%
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addLegend(colors = "red", labels= "Samples",title ="GEDI Level1B")

# Host
host <- list(name = "hpc",tunnel = "/tmp/testpecan")

# Close it first just in case
system(paste("ssh -S ",host$tunnel,host$name,"-O exit",sep=" "))
system(paste("ssh -nNf -o ControlMaster=yes -S",host$tunnel,host$name,sep=" "))

script <- list("gedilevel1b <- readLevel1B(level1Bpath = file.path(outdir,'GEDI01_B_2019138232137_O02440_T00856_02_003_01.h5'))",
               "getLevel1BWF(gedilevel1b, shot_number='24400007800099961')")

run.Rcommand.and.save(script,
                      name = "wf",
                      outdir = "/data/gent/vo/000/gvo00074/felicien/dataGEDI/",
                      host = host)

dummy <- remote.copy.from(host,
                          src=file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/",paste0("wf",".RDS")),
                          dst=file.path(getwd(),"data"))

wf <- readRDS(file.path(getwd(),"data",paste0("wf",".RDS")))


par(mfrow = c(1,2), mar=c(4,4,1,1), cex.axis = 1.5)

plot(wf, relative=FALSE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude", ylab="Elevation (m)")
grid()
plot(wf, relative=TRUE, polygon=FALSE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude (%)", ylab="Elevation (m)")
grid()


# Get GEDI Elevation and Height Metrics
script <- list("outdir <- '/data/gent/vo/000/gvo00074/felicien/dataGEDI/Paracou/'",
               "readLevel2A(level2Apath = paste0(outdir,'/GEDI02_A_2019169195233_O02919_T05406_02_001_01.h5'))")

run.Rcommand.and.save(script,
                      name = "gedilevel2a",
                      outdir = "/data/gent/vo/000/gvo00074/felicien/dataGEDI/",
                      host = host)

dummy <- remote.copy.from(host,
                          src=file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/",paste0("gedilevel2a",".RDS")),
                          dst=file.path(getwd(),"data"))

gedilevel2a <- readRDS(file.path(getwd(),"data",paste0("gedilevel2a",".RDS")))
level2AM<-getLevel2AM(level2a = gedilevel2a)
# head(level2AM[,c("beam","shot_number","elev_highestreturn","elev_lowestmode","rh100")])

##          beam       shot_number elev_highestreturn elev_lowestmode rh100
##  1: BEAM0000 19640002800109382           740.7499        736.3301  4.41
##  2: BEAM0000 19640003000109383           756.0878        746.7614  9.32
##  3: BEAM0000 19640003200109384           770.3423        763.1509  7.19
##  4: BEAM0000 19640003400109385           775.9838        770.6652  5.31
##  5: BEAM0000 19640003600109386           777.8409        773.0841  4.75
##  6: BEAM0000 19640003800109387           778.7181        773.6990  5.01

# Converting shot_number as "integer64" to "character"


# Converting Elevation and Height Metrics as data.table to SpatialPointsDataFrame
level2AM_spdf<-SpatialPointsDataFrame(cbind(level2AM$lon_lowestmode,level2AM$lat_lowestmode),
                                      data=level2AM)

# Exporting Elevation and Height Metrics as ESRI Shapefile
raster::shapefile(level2AM_spdf,paste0(outdir,"\\GEDI02_A_2019108080338_O01964_T05337_02_001_01_sub"))

shot_number = "24400007800099961"

par(mfrow = c(1,1), mar=c(4,4,1,1), cex.axis = 1.5)
png("fig8.png", width = 8, height = 6, units = 'in', res = 300)
plotWFMetrics(gedilevel1b, gedilevel2a, shot_number, rh=c(25, 50, 75, 90))
dev.off()

level2BVPM<-getLevel2BVPM(gedilevel2b)
head(level2BVPM[,c("beam","shot_number","pai","fhd_normal","omega","pgap_theta","cover")])

##          beam       shot_number         pai fhd_normal omega pgap_theta       cover
##   1: BEAM0000 19640002800109382 0.007661204  0.6365142     1  0.9961758 0.003823273
##   2: BEAM0000 19640003000109383 0.086218357  2.2644432     1  0.9577964 0.042192958
##   3: BEAM0000 19640003200109384 0.299524575  1.8881851     1  0.8608801 0.139084846
##   4: BEAM0000 19640003400109385 0.079557180  1.6625489     1  0.9609926 0.038997617
##   5: BEAM0000 19640003600109386 0.018724868  1.5836401     1  0.9906789 0.009318732
##   6: BEAM0000 19640003800109387 0.017654873  1.2458609     1  0.9912092 0.008788579

# Converting shot_number as "integer64" to "character"
level2BVPM$shot_number<-paste0(level2BVPM$shot_number)

# Converting GEDI Vegetation Profile Biophysical Variables as data.table to SpatialPointsDataFrame
level2BVPM_spdf<-SpatialPointsDataFrame(cbind(level2BVPM$longitude_bin0,level2BVPM$latitude_bin0),
                                        data=level2BVPM)

# Exporting GEDI Vegetation Profile Biophysical Variables as ESRI Shapefile
raster::shapefile(level2BVPM_spdf,paste0(outdir,"\\GEDI02_B_2019108080338_O01964_T05337_02_001_01_sub_VPM"))

level2BPAIProfile<-getLevel2BPAIProfile(gedilevel2b)
head(level2BPAIProfile[,c("beam","shot_number","pai_z0_5m","pai_z5_10m")])

##          beam       shot_number   pai_z0_5m   pai_z5_10m
##   1: BEAM0000 19640002800109382 0.007661204 0.0000000000
##   2: BEAM0000 19640003000109383 0.086218357 0.0581122264
##   3: BEAM0000 19640003200109384 0.299524575 0.0497199222
##   4: BEAM0000 19640003400109385 0.079557180 0.0004457365
##   5: BEAM0000 19640003600109386 0.018724868 0.0000000000
##   6: BEAM0000 19640003800109387 0.017654873 0.0000000000

level2BPAVDProfile<-getLevel2BPAVDProfile(gedilevel2b)
head(level2BPAVDProfile[,c("beam","shot_number","pavd_z0_5m","pavd_z5_10m")])

##          beam       shot_number  pavd_z0_5m  pavd_z5_10m
##   1: BEAM0000 19640002800109382 0.001532241 0.0007661204
##   2: BEAM0000 19640003000109383 0.005621226 0.0086218351
##   3: BEAM0000 19640003200109384 0.049960934 0.0299524590
##   4: BEAM0000 19640003400109385 0.015822290 0.0079557188
##   5: BEAM0000 19640003600109386 0.003744974 0.0018724868
##   6: BEAM0000 19640003800109387 0.003530974 0.0017654872

# Converting shot_number as "integer64" to "character"
level2BPAIProfile$shot_number<-paste0(level2BPAIProfile$shot_number)
level2BPAVDProfile$shot_number<-paste0(level2BPAVDProfile$shot_number)

# Converting PAI and PAVD Profiles as data.table to SpatialPointsDataFrame
level2BPAIProfile_spdf<-SpatialPointsDataFrame(cbind(level2BPAIProfile$lon_lowestmode,level2BPAIProfile$lat_lowestmode),
                                               data=level2BPAIProfile)
level2BPAVDProfile_spdf<-SpatialPointsDataFrame(cbind(level2BPAVDProfile$lon_lowestmode,level2BPAVDProfile$lat_lowestmode),
                                                data=level2BPAVDProfile)

# Exporting PAI and PAVD Profiles as ESRI Shapefile
raster::shapefile(level2BPAIProfile_spdf,paste0(outdir,"\\GEDI02_B_2019108080338_O01964_T05337_02_001_01_sub_PAIProfile"))
raster::shapefile(level2BPAVDProfile_spdf,paste0(outdir,"\\GEDI02_B_2019108080338_O01964_T05337_02_001_01_sub_PAVDProfile"))

#specify GEDI beam
beam="BEAM0101"

# Plot Level2B PAI Profile
gPAIprofile<-plotPAIProfile(level2BPAIProfile, beam=beam, elev=TRUE)

# Plot Level2B PAVD Profile
gPAVDprofile<-plotPAVDProfile(level2BPAVDProfile, beam=beam, elev=TRUE)
