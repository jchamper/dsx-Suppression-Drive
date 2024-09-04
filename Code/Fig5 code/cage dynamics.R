# cage daynamics for main 
setwd("/Users/weizhechen/Desktop/rerun0423")
sim_csv=data.frame(read_csv("sim_csv.csv"))
exp_sem=data.frame(read_csv("exp_sem.csv"))


f=1.05
w=8
d=6
data<- sim_csv %>% filter(fitness == f & weeks == w & density==d)##
data$gen=data$this_gen-11
data_10<- data  %>% filter(gen>=0 & gen!=1)
data_10 <- data_10[,c(8,9,13,14)]
data_10$sem_drive=rep(NA,nrow(data_10))
data_10$sem_female=rep(NA,nrow(data_10))
data_sim = data_10 %>% filter(ID <= 20)

data_expA=data.frame(sampling_drive=exp_A0$drive_carrier,sampling_female=exp_A0$female,ID=rep(51,nrow(exp_A0)), gen=exp_A0$gen)
data_expB=data.frame(sampling_drive=exp_B0$drive_carrier,sampling_female=exp_B0$female,ID=rep(52,nrow(exp_B0)),gen=exp_B0$gen)
data_exp=rbind(data_expA,data_expB)
data_exp$sem_drive=exp_sem$sem_drive
data_exp$sem_female=exp_sem$sem_female
data_simexp=rbind(data_sim,data_exp)              

#fly_has_drive
pdf(file = "simulation-drive.pdf", width = 10, height =5.5)
ggplot(data_simexp,aes(x = gen, y = sampling_drive, color = factor(ID))) +
  geom_line(size=1)+
  labs(x = "Weeks", y = "Drive", color = "cage") +
  scale_x_continuous(breaks=seq(0, 38, by = 2))+
  geom_errorbar(aes(ymin=data_simexp[,1]-data_simexp[,5],ymax=data_simexp[,1]+data_simexp[,5]),lwd=0.7,width=0.4,color=c("#969696"),cex=1)+
  theme_classic(base_size = 20)+
  theme(legend.position = "none")+
  scale_color_manual(values = c(rep(c("#F1E2CC"),each=20),"#1D91C0","#E31A1C")) #100
#scale_size_manual(values = c(rep(0.5,each=10),4,4,4))
dev.off()

#population
pdf(file = "sumulation-pop.pdf", width = 10, height = 5.5)
ggplot(data_simexp,aes(x = gen, y = sampling_female, color = factor(ID))) +
  geom_line(linewidth=1)+
  labs(x = "Weeks", y = "Female population", color = "cage") +
  geom_errorbar(aes(ymin=data_simexp[,2]-data_simexp[,6],ymax=data_simexp[,2]+data_simexp[,6]),lwd=0.7,width=0.4,color=c("#969696"),cex=1)+
  xlim(0,38)+ylim(0, 1600)+
  scale_x_continuous(breaks=seq(0, 38, by = 2))+
  scale_y_continuous(breaks=seq(0, 1200, by = 200))+
  theme_classic(base_size = 20)+
  theme(legend.position = "none")+
  scale_color_manual(values = c(rep(c("#F1E2CC"),each=20),"#1D91C0","#E31A1C")) #100
dev.off()

