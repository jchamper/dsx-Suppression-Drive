library(tidyverse)
library(openxlsx)
library(RColorBrewer)
library(dplyr)
##writen by Weizhe Chen for cage experiment-simulations RMSE calcultion
## varying end points
#read in


exp_A0=data.frame(read_csv("RIDDA.csv"))
colnames(exp_A0)[1] <- "gen"
exp_A=exp_A0[,c(1:4)]
exp_B0=data.frame(read_csv("RIDDB.csv"))
colnames(exp_B0)[1] <- "gen"
exp_B=exp_B0[,c(1:4)]
sim_csv=data.frame(read_csv("sim_csv.csv"))

output_RMSE <- data.frame(matrix(ncol = 8, nrow = 1)) 
colnames(output_RMSE)=c("fitness","weeks","density","RMSE_drive_A","RMSE_drive_B","RMSE_female_A","RMSE_female_B","combined")
avg_femaleA=mean(exp_A0[-1,]$female)
avg_femaleB=mean(exp_B0[-1,]$female)
avg_driveA=mean(exp_A0$drive_carrier)
avg_driveB=mean(exp_B0$drive_carrier)
for (f in c(0.7,0.75,0.8,0.85,0.9,0.95,1.0,1.05,1.1)){
  for (w in c(4,4.5,5,5.5,6,6.5,7,7.5,8)){
    for(d in c(6,6.5,7,7.5,8,8.5,9,9.5,10)){
      data<- sim_csv %>% filter(fitness == f & weeks == w & density==d)
      data$gen=data$this_gen-11
      data_10<- data  %>% filter(gen>=0 & gen!=1)
      data_10 <- data_10[,c(7:13)]
      rmse_drive_tenrunA=0
      rmse_drive_tenrunB=0
      rmse_female_tenrunA=0
      rmse_female_tenrunB=0
      for(i in c(1:100)){
        one_run <-data_10 %>% filter(ID==i)
        nrows=nrow(one_run)
        nrowA=nrow(exp_A) #RIDDA=RIDDB
        rows_to_add <- abs(nrowA - nrows)
        if (nrows< nrowA){
          for (g in 1:rows_to_add) {
            gen=nrows+g
            one_run <- rbind(one_run, c(1,0,f,d,w,i,gen))}}
        if (nrows> nrowA){ # modify both RIDDA and RIDDB
          for (g in 1:rows_to_add) {
            gen=nrowA+g
            exp_A <- rbind(exp_A, c(gen,1,0,0))
            exp_B <- rbind(exp_B, c(gen,1,0,0)) }}
        #calculate RMSE
        rmse_drive_onerunA <- sqrt(mean((exp_A$drive_carrier-one_run$sampling_drive)^2))
        rmse_drive_onerunB <- sqrt(mean((exp_B$drive_carrier-one_run$sampling_drive)^2))
        rmse_female_onerunA <- sqrt(mean((exp_A[-1,]$female-one_run[-1,]$sampling_female)^2))#exclude NA data point
        rmse_female_onerunB <- sqrt(mean((exp_B[-1,]$female-one_run[-1,]$sampling_female)^2))
        # sum RMSE of 10 simulations 
        rmse_drive_tenrunA=rmse_drive_tenrunA+rmse_drive_onerunA
        rmse_drive_tenrunB=rmse_drive_tenrunB+rmse_drive_onerunB
        rmse_female_tenrunA=rmse_female_tenrunA+rmse_female_onerunA
        rmse_female_tenrunB=rmse_female_tenrunB+rmse_female_onerunB
      }
      #avergae RMSE
      RMSE_drive_A=rmse_drive_tenrunA/100
      RMSE_drive_B=rmse_drive_tenrunB/100
      RMSE_female_A=rmse_female_tenrunA/100
      RMSE_female_B=rmse_female_tenrunB/100
      #combined RMSE
      combined=RMSE_drive_A/avg_driveA+RMSE_drive_B/avg_driveB+RMSE_female_A/avg_femaleA+RMSE_female_B/avg_femaleB
      #output_RMSE
      raw_result=c(f,w,d,RMSE_drive_A,RMSE_drive_B,RMSE_female_A,RMSE_female_B,combined)
      output_RMSE=rbind(output_RMSE,raw_result)
    }
  }
}
output_RMSE=output_RMSE[-1,]#remove NA
#combined RMSE_weight
combined_weight=output_RMSE$RMSE_drive_A/min_drive_A+output_RMSE$RMSE_drive_B/min_drive_B+
  output_RMSE$RMSE_female_A/min_female_A+output_RMSE$RMSE_female_B/min_female_B

output_RMSE$combined_weight=combined_weight


max_drive_A=max(output_RMSE$RMSE_drive_A,na.rm=TRUE)
max_drive_B=max(output_RMSE$RMSE_drive_B,na.rm=TRUE)
max_female_A=max(output_RMSE$RMSE_female_A,na.rm=TRUE)
max_female_B=max(output_RMSE$RMSE_female_B,na.rm=TRUE)
min_drive_A=min(output_RMSE$RMSE_drive_A,na.rm=TRUE)
min_drive_B=min(output_RMSE$RMSE_drive_B,na.rm=TRUE)
min_female_A=min(output_RMSE$RMSE_female_A,na.rm=TRUE)
min_female_B=min(output_RMSE$RMSE_female_B,na.rm=TRUE)


normalize= (output_RMSE$RMSE_drive_A-min_drive_A)/(max_drive_A-min_drive_A)+
           (output_RMSE$RMSE_drive_B-min_drive_B)/(max_drive_B-min_drive_B)+
           (output_RMSE$RMSE_female_A-min_female_A)/(max_female_A-min_female_A)+
           (output_RMSE$RMSE_female_B-min_female_B)/(max_female_B-min_female_B)
output_RMSE$normalize=normalize

write.csv(output_RMSE, "output_RMSE.csv", row.names = TRUE)

