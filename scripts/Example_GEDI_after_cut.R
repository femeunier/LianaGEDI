rm(list = ls())

# Assuming the files have been downloaded

# loading rGEDI package
library(rGEDI)
library(LianaGEDI)

# Study area boundary box coordinates
site.name <- "Paracou"
ul_lat<- 5.2
lr_lat<- 5.4
ul_lon<- -52.8
lr_lon<- -53

# site.name <- "BCI"
# ul_lat<- 9.1
# lr_lat<- 9.3
# ul_lon<- -79.8
# lr_lon<- -80.0


# Get path to GEDI data
gLevel1B<-gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2A<-gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001")
gLevel2B<-gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001")

# Set output dir for downloading the files
outdir=file.path(getwd(),"data",site.name)
# outdir <- file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/",site.name)

# Downloading GEDI data
# LianaGEDI::gediDownload(filepath=gLevel1B,outdir=outdir)
# LianaGEDI::gediDownload(filepath=gLevel2A,outdir=outdir)
# LianaGEDI::gediDownload(filepath=gLevel2B,outdir=outdir)

# Reading GEDI data and merge
ifile=2

gedilevel1b <- readLevel1B(level1Bpath = file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel1B[ifile])),"_sub.h5")))
level1bGeo <- getLevel1BGeo(level1b=gedilevel1b,select=c("elevation_bin0"))

head(level1bGeo)

level1bGeo$shot_number<-paste0(level1bGeo$shot_number)

# Converting level1bGeo as data.table to SpatialPointsDataFrame
library(sp)
level1bGeo_spdf<-SpatialPointsDataFrame(cbind(level1bGeo$longitude_bin0, level1bGeo$latitude_bin0),
                                        data=level1bGeo)

# Exporting level1bGeo as ESRI Shapefile

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


shot.number <- level1bGeo$shot_number[runif(1,1,nrow(level1bGeo))]
wf <- getLevel1BWF(level1b = gedilevel1b, shot_number=shot.number)

par(mfrow = c(1,2), mar=c(4,4,1,1), cex.axis = 1.5)

plot(wf, relative=FALSE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude", ylab="Elevation (m)")
grid()
plot(wf, relative=TRUE, polygon=FALSE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude (%)", ylab="Elevation (m)")
grid()

gedilevel2a<-readLevel2A(level2Apath = file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2A[ifile])),"_sub.h5")))
level2AM<-getLevel2AM(gedilevel2a)

head(level2AM[,c("beam","shot_number","elev_highestreturn","elev_lowestmode","rh100")])

level2AM$shot_number<-paste0(level2AM$shot_number)

# Converting Elevation and Height Metrics as data.table to SpatialPointsDataFrame
level2AM_spdf<-SpatialPointsDataFrame(cbind(level2AM$lon_lowestmode,level2AM$lat_lowestmode),
                                      data=level2AM)

# Exporting Elevation and Height Metrics as ESRI Shapefile

par(mfrow = c(1,1), mar=c(4,4,1,1), cex.axis = 1.5)
# png("fig8.png", width = 8, height = 6, units = 'in', res = 300)
plotWFMetrics(gedilevel1b, gedilevel2a, shot.number, rh=c(25, 50, 75, 90))
# dev.off()

gedilevel2b<-readLevel2B(level2Bpath = file.path(outdir,paste0(sub('\\.h5$','',basename(gLevel2B[ifile])),"_sub.h5")))

level2BVPM<-getLevel2BVPM(gedilevel2b)
head(level2BVPM[,c("beam","shot_number","pai","fhd_normal","omega","pgap_theta","cover")])

# Converting shot_number as "integer64" to "character"
level2BVPM$shot_number<-paste0(level2BVPM$shot_number)

# Converting GEDI Vegetation Profile Biophysical Variables as data.table to SpatialPointsDataFrame
level2BVPM_spdf<-SpatialPointsDataFrame(cbind(level2BVPM$longitude_bin0,level2BVPM$latitude_bin0),
                                        data=level2BVPM)

level2BPAIProfile<-getLevel2BPAIProfile(gedilevel2b)
head(level2BPAIProfile[,c("beam","shot_number","pai_z0_5m","pai_z5_10m")])

level2BPAVDProfile<-getLevel2BPAVDProfile(gedilevel2b)
head(level2BPAVDProfile[,c("beam","shot_number","pavd_z0_5m","pavd_z5_10m")])

# Converting shot_number as "integer64" to "character"
level2BPAIProfile$shot_number<-paste0(level2BPAIProfile$shot_number)
level2BPAVDProfile$shot_number<-paste0(level2BPAVDProfile$shot_number)

# Converting PAI and PAVD Profiles as data.table to SpatialPointsDataFrame
level2BPAIProfile_spdf<-SpatialPointsDataFrame(cbind(level2BPAIProfile$lon_lowestmode,level2BPAIProfile$lat_lowestmode),
                                               data=level2BPAIProfile)
level2BPAVDProfile_spdf<-SpatialPointsDataFrame(cbind(level2BPAVDProfile$lon_lowestmode,level2BPAVDProfile$lat_lowestmode),
                                                data=level2BPAVDProfile)

#specify GEDI beam
beam="BEAM1011"

# Plot Level2B PAI Profile
gPAIprofile<-plotPAIProfile(level2BPAIProfile, beam=beam, elev=TRUE)
gPAVDprofile<-plotPAVDProfile(level2BPAVDProfile, beam=beam, elev=TRUE)
