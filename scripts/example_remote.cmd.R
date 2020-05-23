rm(list = ls())

library(LianaGEDI)

host <- list(name = "hpc",tunnel = "/tmp/testpecan")

# Close it first just in case
system(paste("ssh -S ",host$tunnel,host$name,"-O exit",sep=" "))
system(paste("ssh -nNf -o ControlMaster=yes -S",host$tunnel,host$name,sep=" "))

remote.execute.cmd(host = host, cmd = "R")
result <- remote.execute.R(script='library(rGEDI);
                                   gedifinder(product="GEDI01_B",5.2, -52.8, 5.4, -53,version="001")',
                           host=host,
                           verbose=FALSE)

result <- remote.execute.R(script='library(rGEDI);
                                   library(LianaGEDI);
                                   WD <- getwd();
                                   setwd("/data/gent/vo/000/gvo00074/felicien/R/LianaGEDI/");
                                   outdir <- file.path("/data/gent/vo/000/gvo00074/felicien/dataGEDI/Paracou");
                                   gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir,"GEDI01_B_2019169195233_O02919_T05406_02_003_01.h5"));
                                   saveRDS(gedilevel1b,file.path(getwd(),"data","gedilevel1b.RDS"));
                                   setwd(WD)',
                           host=host,
                           verbose=FALSE)

system(paste("ssh -S ",host$tunnel,host$name,"-O exit",sep=" "))
