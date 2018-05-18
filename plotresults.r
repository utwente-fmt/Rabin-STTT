
###########
# Imports #
###########

library(plyr)
library(ggplot2)
library(reshape2)

#######################
# Auxiliary functions #
#######################

geom_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


# distinct colors (https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/)
RED    = rgb(230/255,  25/255,  75/255, 1)
BLUE   = rgb(  0/255, 130/255, 200/255, 1)
GREEN  = rgb( 60/255, 180/255,  75/255, 1)
ORANGE = rgb(245/255, 130/255,  48/255, 1)
PURPLE = rgb(145/255,  30/255, 180/255, 1)
YELLOW = rgb(255/255, 255/255,  25/255, 1)
CYAN   = rgb( 70/255, 240/255, 240/255, 1)
MAGENTA= rgb(240/255,  50/255, 230/255, 1)
LIME   = rgb(210/255, 245/255,  60/255, 1)
TEAL   = rgb(  0/255, 128/255, 128/255, 1)
GREY   = rgb(128/255, 128/255, 128/255, 1)
GRAY   = rgb(128/255, 128/255, 128/255, 1)
WHITE  = rgb(255/255, 255/255, 255/255, 1)
BLACK  = rgb(  0/255,   0/255,   0/255, 1)

COLORS = c(RED,BLUE,GREEN,ORANGE,PURPLE,GREY,BLACK,YELLOW,CYAN,MAGENTA,LIME,TEAL)

###############
# Import data #
###############

results = read.csv("results-combined.csv")
# results are already filtered, summarized, and combined 

##################
# Plot functions #
##################

f_scatterplot_time = function(d,time_x,time_y,ltl,xlab,ylab){
  p = ggplot(data=d, aes(x=time_x, y=time_y)) +
    geom_vline(xintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_vline(xintercept=1000, color=GREEN,  linetype="dotdash",size=1) + 
    geom_hline(yintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_hline(yintercept=1000, color=GREEN,  linetype="dotdash",size=1) +
    geom_abline(slope=1, color=BLACK, size=.5) +
    geom_point(shape=ifelse(ltl<=-1,1,4), 
               color=ifelse(ltl<=-1,ifelse(d$origin=="mcc",BLUE,RED),
                                    ifelse(d$origin=="mcc",BLUE,RED)), stroke=1, size=3) +
    labs(x=xlab, y=ylab) +
    theme_light() + 
    theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
    scale_y_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000)) +
    scale_x_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000))
  return(p)
}

timescatter = function(){
drab=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1)
rab=f_scatterplot_time(drab,drab$tgba_ufscc_time,drab$rabinizer3_favoid_time,drab$tgba_ufscc_ltl,"Time TGBA","Time Rabinizer3-TGRA")

dtela=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1)
tela=f_scatterplot_time(dtela,dtela$tgba_ufscc_time,dtela$ltl3tela_favoid_time,dtela$tgba_ufscc_ltl,"Time TGBA","Time LTL3TELA-TGRA")

ddra=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1)
dra=f_scatterplot_time(ddra,ddra$tgba_ufscc_time,ddra$ltl3dra_favoid_time,ddra$tgba_ufscc_ltl,"Time TGBA","Time LTL3DRA-TGRA")

#dfinf=subset(results, tgba_ufscc_time >= 1 & finless_favoid_time >= 1)
#finf=f_scatterplot_time(dfinf,dfinf$tgba_ufscc_time,dfinf$finless_favoid_time,dfinf$tgba_ufscc_ltl,"Time TGBA","Time Fin-Less (F-avoid)")

dfint=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1)
fint=f_scatterplot_time(dfint,dfint$tgba_ufscc_time,dfint$finless_ufscc_time,dfint$tgba_ufscc_ltl,"Time TGBA","Time Fin-less")

#dfintf=subset(results, finless_favoid_time >= 1 & finless_ufscc_time >= 1)
#fintf=f_scatterplot_time(dfintf,dfintf$finless_favoid_time,dfintf$finless_ufscc_time,dfintf$finless_favoid_ltl,"Time Fin-Less (F-avoid)","Time Fin-Less (UFSCC)")

multiplot(rab, tela, dra, fint, cols=2)
}

timescatter()


f_scatterplot_time = function(d,time_x,time_y,ltl,xlab,ylab){
  p = ggplot(data=d, aes(x=time_x, y=time_y)) +
    geom_vline(xintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_vline(xintercept=1000, color=RED,  linetype="dotdash",size=1) + 
    geom_hline(yintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_hline(yintercept=1000, color=RED,  linetype="dotdash",size=1) +
    geom_abline(slope=1, color=BLACK, size=.5) +
    geom_point(shape=ifelse(ltl<=-1,1,4), 
               color=ifelse(ltl<=-1,ifelse(d$origin=="mcc",BLUE,GREEN),
                            ifelse(d$origin=="mcc",BLUE,GREEN)), stroke=1, size=3) +
    labs(x=xlab, y=ylab) +
    theme_light() + 
    theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
    scale_y_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000)) +
    scale_x_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000))
  return(p)
}

leg = function(){
options(scipen=5)
pdf("legend.pdf", width=16, height=4)
plot.new()
legend(x = "top",inset = 0,
       pch=c(4,1,4,1,-1,-1,-1), 
       col=c(GREEN,GREEN,BLUE,GREEN,PURPLE,GREEN,BLACK), 
       c("Counterexample", "No counterexample", "MCC", "TACAS", "Memory limit", "Time limit", "x = y"), 
       bty="0",
       lwd=c(1.5,1.5,1.5,1.5,2.5,2.5,2.5),
       lty=c(0,0,0,0,5,6,1),
       bg=WHITE,
       horiz=TRUE)
dev.off()
}



rabinaut = function(){
allres=subset(results, #origin=="mcc" & 
                #tgba_ufscc_ltl=="-1" &
                #finless_ufscc_errmsg=="OK" &
                #ltl3tela_favoid_errmsg=="OK" &
                #ltl3dra_favoid_errmsg=="OK" &
                #rabinizer3_favoid_errmsg=="OK" &
                tgba_ufscc_errmsg=="OK")
#allres2 = allres[order(allres$tgba_ufscc_autsize,allres$model),]
ggplot(data=allres) +
#  geom_abline(slope=1, color=BLACK, size=.5) +
  geom_count(aes(x=tgba_ufscc_rabinpairs, y=tgba_ufscc_autsize),color=BLACK, position = position_nudge(x = -0.375)) + 
  geom_count(aes(x=ltl3tela_favoid_rabinpairs, y=ltl3tela_favoid_autsize),
             color=BLUE, position = position_nudge(x = -0.125)) +
  geom_count(aes(x=ltl3dra_favoid_rabinpairs, y=ltl3dra_favoid_autsize), 
             color=RED, position = position_nudge(x = 0.125)) +
  geom_count(aes(x=rabinizer3_favoid_rabinpairs, y=rabinizer3_favoid_autsize), 
             color=GREEN, position = position_nudge(x = 0.375)) +
  geom_count(aes(x=finless_ufscc_rabinpairs, y=finless_ufscc_autsize), 
             color=ORANGE, position = position_nudge(x = -0.375)) +
  scale_size(range=c(2,15)) +
  #geom_jitter(color= ifelse(allres$ltl3tela_favoid_ustates <  allres$tgba_ufscc_ustates,GREEN,
  #                   ifelse(allres$ltl3tela_favoid_ustates == allres$tgba_ufscc_ustates,BLACK,RED))) +
  labs(x="Number of Rabin pairs", y="Automata size") +
  theme_light() + 
  theme(panel.grid.major = element_line(colour = GREY), legend.position="top") +
  scale_x_continuous(limits=c(0.5,4.5),breaks=c(0.5,1.5,2.5,3.5,4.5)) +
  scale_y_continuous(limits=c(1,30),breaks=c(1,5,10,15,20,25,30))
}
# dtela=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs == 1)
# f_scatterplot_time(dtela,dtela$tgba_ufscc_time,dtela$ltl3tela_favoid_time,dtela$tgba_ufscc_ltl,"Time TGBA","Time LTL3TELA-TGRA (1 pair)")
# 
# dtela=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs > 1)
# f_scatterplot_time(dtela,dtela$tgba_ufscc_time,dtela$ltl3tela_favoid_time,dtela$tgba_ufscc_ltl,"Time TGBA","Time LTL3TELA-TGRA (1 pair)")
# 

rabinaut()

















f_scatterplot_time = function(d,time_x,time_y,ltl,col,xlab,ylab){
  p = ggplot(data=d, aes(x=time_x, y=time_y)) +
    geom_vline(xintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_vline(xintercept=1000, color=GREEN,  linetype="dotdash",size=1) + 
    geom_hline(yintercept=700,  color=PURPLE, linetype="dashed", size=1) + 
    geom_hline(yintercept=1000, color=GREEN,  linetype="dotdash",size=1) +
    geom_abline(slope=1, color=BLACK, size=.5) +
    geom_point(shape=ifelse(ltl<=-1,1,4), 
               color=ifelse(col<=0.1,BLUE,ifelse(col>=0.9,RED,BLACK)), stroke=1, size=3) +
    labs(x=xlab, y=ylab) +
    theme_light() + 
    theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
    scale_y_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000)) +
    scale_x_log10(limits=c(1,1000),breaks=c(1,2,5,10,20,50,100,200,500,1000))
  return(p)
}

scatterpair = function(){
  drab1=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs==1)
  rab1=f_scatterplot_time(drab1,drab1$tgba_ufscc_time,drab1$rabinizer3_favoid_time,drab1$tgba_ufscc_ltl,"","Time Rabinizer3-TGRA")
  drab2=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs==2)
  rab2=f_scatterplot_time(drab2,drab2$tgba_ufscc_time,drab2$rabinizer3_favoid_time,drab2$tgba_ufscc_ltl,"","")
  drab3=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs>=3)
  rab3=f_scatterplot_time(drab3,drab3$tgba_ufscc_time,drab3$rabinizer3_favoid_time,drab3$tgba_ufscc_ltl,"","")
  
  ddra1=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs==1)
  dra1=f_scatterplot_time(ddra1,ddra1$tgba_ufscc_time,ddra1$ltl3dra_favoid_time,ddra1$tgba_ufscc_ltl,"","Time LTL3DRA-TGRA")
  ddra2=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs==2)
  dra2=f_scatterplot_time(ddra2,ddra2$tgba_ufscc_time,ddra2$ltl3dra_favoid_time,ddra2$tgba_ufscc_ltl,"","")
  ddra3=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs>=3)
  dra3=f_scatterplot_time(ddra3,ddra3$tgba_ufscc_time,ddra3$ltl3dra_favoid_time,ddra3$tgba_ufscc_ltl,"","")
  
  
  dtela1=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs==1)
  tela1=f_scatterplot_time(dtela1,dtela1$tgba_ufscc_time,dtela1$ltl3tela_favoid_time,dtela1$tgba_ufscc_ltl,"","Time LTL3TELA-TGRA")
  dtela2=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs==2)
  tela2=f_scatterplot_time(dtela2,dtela2$tgba_ufscc_time,dtela2$ltl3tela_favoid_time,dtela2$tgba_ufscc_ltl,"","")
  dtela3=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs>=3)
  tela3=f_scatterplot_time(dtela3,dtela3$tgba_ufscc_time,dtela3$ltl3tela_favoid_time,dtela3$tgba_ufscc_ltl,"","")
  
  dfinless1=subset(results, tgba_ufscc_time >= 1 & is.na(finless_ufscc_rabinpairs))
  finless1=f_scatterplot_time(dfinless1,dfinless1$tgba_ufscc_time,dfinless1$tgba_ufscc_time,dfinless1$tgba_ufscc_ltl,"Time TGBA","Time Fin-less")
  dfinless2=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1 & finless_ufscc_rabinpairs==2)
  finless2=f_scatterplot_time(dfinless2,dfinless2$tgba_ufscc_time,dfinless2$finless_ufscc_time,dfinless2$tgba_ufscc_ltl,"Time TGBA","")
  dfinless3=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1 & finless_ufscc_rabinpairs>=3)
  finless3=f_scatterplot_time(dfinless3,dfinless3$tgba_ufscc_time,dfinless3$finless_ufscc_time,dfinless3$tgba_ufscc_ltl,"Time TGBA","")
 
  multiplot(rab1, dra1, tela1, 
            rab2, dra2, tela2,
            rab3, dra3, tela3, cols=3)
}


scatterpair2 = function(){
  drab1=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs==1)
  rab1=f_scatterplot_time(drab1,drab1$tgba_ufscc_time,drab1$rabinizer3_favoid_time,drab1$tgba_ufscc_ltl,drab1$rabinizer3_favoid_ftrans / drab1$rabinizer3_favoid_ustates,"","Time Rabinizer3-TGRA")
  drab2=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs==2)
  rab2=f_scatterplot_time(drab2,drab2$tgba_ufscc_time,drab2$rabinizer3_favoid_time,drab2$tgba_ufscc_ltl,drab2$rabinizer3_favoid_ftrans / drab2$rabinizer3_favoid_ustates,"","")
  drab3=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 & rabinizer3_favoid_rabinpairs>=3)
  rab3=f_scatterplot_time(drab3,drab3$tgba_ufscc_time,drab3$rabinizer3_favoid_time,drab3$tgba_ufscc_ltl,drab3$rabinizer3_favoid_ftrans / drab3$rabinizer3_favoid_ustates,"","")
  
  ddra1=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs==1)
  dra1=f_scatterplot_time(ddra1,ddra1$tgba_ufscc_time,ddra1$ltl3dra_favoid_time,ddra1$tgba_ufscc_ltl,ddra1$ltl3dra_favoid_ftrans / ddra1$ltl3dra_favoid_ustates,"","Time LTL3DRA-TGRA")
  ddra2=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs==2)
  dra2=f_scatterplot_time(ddra2,ddra2$tgba_ufscc_time,ddra2$ltl3dra_favoid_time,ddra2$tgba_ufscc_ltl,ddra2$ltl3dra_favoid_ftrans / ddra2$ltl3dra_favoid_ustates,"","")
  ddra3=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 & ltl3dra_favoid_rabinpairs>=3)
  dra3=f_scatterplot_time(ddra3,ddra3$tgba_ufscc_time,ddra3$ltl3dra_favoid_time,ddra3$tgba_ufscc_ltl,ddra3$ltl3dra_favoid_ftrans / ddra3$ltl3dra_favoid_ustates,"","")
  
  
  dtela1=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs==1)
  tela1=f_scatterplot_time(dtela1,dtela1$tgba_ufscc_time,dtela1$ltl3tela_favoid_time,dtela1$tgba_ufscc_ltl,dtela1$ltl3tela_favoid_ftrans / dtela1$ltl3tela_favoid_ustates,"Time TGBA","Time LTL3TELA-TGRA")
  dtela2=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs==2)
  tela2=f_scatterplot_time(dtela2,dtela2$tgba_ufscc_time,dtela2$ltl3tela_favoid_time,dtela2$tgba_ufscc_ltl,dtela2$ltl3tela_favoid_ftrans / dtela2$ltl3tela_favoid_ustates,"Time TGBA","")
  dtela3=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 & ltl3tela_favoid_rabinpairs>=3)
  tela3=f_scatterplot_time(dtela3,dtela3$tgba_ufscc_time,dtela3$ltl3tela_favoid_time,dtela3$tgba_ufscc_ltl,dtela3$ltl3tela_favoid_ftrans / dtela3$ltl3tela_favoid_ustates,"Time TGBA","")
  
  dfinless1=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1 & finless_ufscc_rabinpairs==1)
  finless1=f_scatterplot_time(dfinless1,dfinless1$tgba_ufscc_time,dfinless1$tgba_ufscc_time,dfinless1$tgba_ufscc_ltl,dfinless1$tgba_ufscc_ftrans / dfinless1$tgba_ufscc_ustates,"Time TGBA","Time Fin-less")
  dfinless2=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1 & finless_ufscc_rabinpairs==2)
  finless2=f_scatterplot_time(dfinless2,dfinless2$tgba_ufscc_time,dfinless2$finless_ufscc_time,dfinless2$tgba_ufscc_ltl,dfinless2$finless_ufscc_ftrans / dfinless2$finless_ufscc_ustates,"Time TGBA","")
  dfinless3=subset(results, tgba_ufscc_time >= 1 & finless_ufscc_time >= 1 & finless_ufscc_rabinpairs>=3)
  finless3=f_scatterplot_time(dfinless3,dfinless3$tgba_ufscc_time,dfinless3$finless_ufscc_time,dfinless3$tgba_ufscc_ltl,dfinless3$finless_ufscc_ftrans / dfinless3$finless_ufscc_ustates,"Time TGBA","")
  
  multiplot(rab1, dra1, tela1, 
            rab2, dra2, tela2,
            rab3, dra3, tela3, cols=3)
}

scatterpair2()









fstates = function(){
df=subset(results, tgba_ufscc_time >= 1 & ltl3tela_favoid_time >= 1 &  
            ltl3tela_favoid_ftrans >= 0 & ltl3tela_favoid_utrans >= 0)
f1=ggplot(data=df, aes(x=ltl3tela_favoid_ftrans/ltl3tela_favoid_ustates, y=ltl3tela_favoid_time/tgba_ufscc_time)) +
  geom_hline(yintercept=1, color=BLACK, size=1) +
  geom_point(shape=ifelse(df$ltl3tela_favoid_ltl<=-1,1,4), 
             color=ifelse(df$ltl3tela_favoid_ltl<=-1,BLUE,RED), stroke=1, size=3) +
  labs(x="Fin states / Total states", y="Time LTL3TELA / Time TGBA") +
  theme_light() + 
  theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
  scale_y_continuous(limits=c(0,5)) +
  scale_x_continuous(limits=c(0,1))


df=subset(results, tgba_ufscc_time >= 1 & ltl3dra_favoid_time >= 1 &  
            ltl3dra_favoid_ftrans >= 0 & ltl3dra_favoid_utrans >= 0)
f2=ggplot(data=df, aes(x=ltl3dra_favoid_ftrans/ltl3dra_favoid_ustates, y=ltl3dra_favoid_time/tgba_ufscc_time)) +
  geom_hline(yintercept=1, color=BLACK, size=1) +
  geom_point(shape=ifelse(df$ltl3dra_favoid_ltl<=-1,1,4), 
             color=ifelse(df$ltl3dra_favoid_ltl<=-1,BLUE,RED), stroke=1, size=3) +
  labs(x="Fin states / Total states", y="Time LTL3DRA / Time TGBA") +
  theme_light() + 
  theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
  scale_y_continuous(limits=c(0,5)) +
  scale_x_continuous(limits=c(0,1))


df=subset(results, tgba_ufscc_time >= 1 & rabinizer3_favoid_time >= 1 &  
            rabinizer3_favoid_ftrans >= 0 & rabinizer3_favoid_utrans >= 0)
f3=ggplot(data=df, aes(x=rabinizer3_favoid_ftrans/rabinizer3_favoid_ustates, y=rabinizer3_favoid_time/tgba_ufscc_time)) +
  geom_hline(yintercept=1, color=BLACK, size=1) +
  geom_point(shape=ifelse(df$rabinizer3_favoid_ltl<=-1,1,4), 
             color=ifelse(df$rabinizer3_favoid_ltl<=-1,BLUE,RED), stroke=1, size=3) +
  labs(x="Fin states / Total states", y="Time Rabinizer 3 / Time TGBA") +
  theme_light() + 
  theme(panel.grid.major = element_line(colour = GREY), legend.position="none") +
  scale_y_continuous(limits=c(0,5)) +
  scale_x_continuous(limits=c(0,1))

multiplot(f1,f2,f3, cols=3)
}

#fstates()

#rabinaut()



# Fin-less times
allres=subset(results, origin=="beem" & 
                #tgba_ufscc_ltl!="-1" & # for CE and No-CE
                finless_ufscc_errmsg=="OK" &
                tgba_ufscc_errmsg=="OK")
print("averages:")
sprintf("%.2f & %.2f & %.2f \\ ",
        geom_mean(allres$finless_ufscc_time), # finless
        geom_mean(allres$finless_ufscc_time)/geom_mean(allres$tgba_ufscc_time),
        geom_mean(allres$tgba_ufscc_time)  # tgba
)
nrow(allres)

# TGRA times
allres=subset(results, origin=="mcc" & 
                #tgba_ufscc_ltl!="-1" &
                ltl3tela_favoid_errmsg=="OK" &
                ltl3dra_favoid_errmsg=="OK" &
                rabinizer3_favoid_errmsg=="OK" &
                tgba_ufscc_errmsg=="OK")
print("averages:")
sprintf("%.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f",
        geom_mean(allres$ltl3tela_favoid_time), # ltl3tela
        geom_mean(allres$ltl3tela_favoid_time)/geom_mean(allres$tgba_ufscc_time),
        geom_mean(allres$ltl3dra_favoid_time), # ltl3dra
        geom_mean(allres$ltl3dra_favoid_time)/geom_mean(allres$tgba_ufscc_time),
        geom_mean(allres$rabinizer3_favoid_time), # rabinizer3
        geom_mean(allres$rabinizer3_favoid_time)/geom_mean(allres$tgba_ufscc_time),
        geom_mean(allres$tgba_ufscc_time)  # tgba
)
nrow(allres)


# Finless aut results
allres=subset(results, origin=="beem" & 
                tgba_ufscc_ltl=="-1" &
                finless_ufscc_errmsg=="OK" &
                tgba_ufscc_errmsg=="OK")
print("averages:")
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$finless_ufscc_autsize), 
        geom_mean(allres$finless_ufscc_rabinpairs), 
        geom_mean(allres$finless_ufscc_ustates)/1e6, 
        geom_mean(allres$finless_ufscc_utrans)/1e6
)
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$tgba_ufscc_autsize), 
        geom_mean(allres$tgba_ufscc_rabinpairs), 
        geom_mean(allres$tgba_ufscc_ustates)/1e6, 
        geom_mean(allres$tgba_ufscc_utrans)/1e6
)
nrow(allres)




# aut size for TGRA
allres=subset(results, origin=="beem" & 
                ltl3dra_favoid_ltl=="-1" &
                ltl3tela_favoid_errmsg=="OK" &
                ltl3dra_favoid_errmsg=="OK" &
                rabinizer3_favoid_errmsg=="OK" &
                tgba_ufscc_errmsg=="OK")
print("averages:")
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$ltl3tela_favoid_autsize), 
        geom_mean(allres$ltl3tela_favoid_rabinpairs), 
        geom_mean(allres$ltl3tela_favoid_ustates)/1e6, 
        geom_mean(allres$ltl3tela_favoid_utrans)/1e6
)
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$ltl3dra_favoid_autsize), 
        geom_mean(allres$ltl3dra_favoid_rabinpairs), 
        geom_mean(allres$ltl3dra_favoid_ustates)/1e6, 
        geom_mean(allres$ltl3dra_favoid_utrans)/1e6
)
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$rabinizer3_favoid_autsize), 
        geom_mean(allres$rabinizer3_favoid_rabinpairs), 
        geom_mean(allres$rabinizer3_favoid_ustates)/1e6, 
        geom_mean(allres$rabinizer3_favoid_utrans)/1e6
)
sprintf("%.2f & %.2f & %.2f & ${}\\cdot 10^6$  & %.2f & ${}\\cdot 10^6$",
        geom_mean(allres$tgba_ufscc_autsize), 
        geom_mean(allres$tgba_ufscc_rabinpairs), 
        geom_mean(allres$tgba_ufscc_ustates)/1e6, 
        geom_mean(allres$tgba_ufscc_utrans)/1e6
)
nrow(allres)


