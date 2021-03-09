library(multcomp)
library("car")
library(pgirmess)

setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/2_numerico/")

df <- read.csv("datosTasaHablayRitmo.csv", sep=";", dec= ".", stringsAsFactors=TRUE)

# Nota: scripts de praat normalmente el output es tab separated
#df <- read.csv("datosTasaHablayRitmo.csv", sep="/t", stringsAsFactors=TRUE)

# ver datos
mean(df$Edad)
min(df$Edad)


boxplot(df$speechRate ~ df$Control)
# Creeis que los controles hablan más rápido? 
boxplot(df$speechRate ~ df$Diagnostico)
#añado colores
boxplot(df$speechRate ~ df$Control, col=c("deepskyblue4","coral"))

# pero los gráficos bonitos son los de ggplot asi que vamos a ello
library(ggplot2)

#uno simple
ggplot(df, aes(x=Diagnostico, y=-speechRate, fill=Diagnostico)) + geom_boxplot()

# ahora reordenamos según la media
ggplot(df, aes(x=reorder(Diagnostico, -speechRate, FUN = median), y=speechRate,colour = Diagnostico)) +
  geom_jitter() +
  stat_boxplot(fill ="NA") +
  stat_boxplot(fill =c(NA,NA,NA,NA,NA,NA,NA,NA)) +
  theme_classic()+ylab("Sonidos por segundo")+xlab("Grupo")+
  theme(axis.text.x = element_text(angle = 90))+
  guides(colour=FALSE)+
  labs(title = "Tasa de habla")

ggsave("speechRate.tiff", units="cm", width=14, height=8, dpi=100, compression = 'lzw')


###########
# NORMALIDAD
######
#test de normalidad, datos normales p>.05, para pocos datos saphiro-wilk

shapiro.test(df$PerC) #normal
# kolmogorov Smirnov (con modificación de Lillefors) para más de 50 datos
# para que veais como se hace, pero no lo podríamos aplicar porque tenemos 
# 30 casos (en este caso 30 pacientes porque cada uno solo tiene 1 dato asociado)
library("nortest")
lillie.test(x = df$PerC)


shapiro.test(df$VarcoC) #NO NORMAL
shapiro.test(df$DeltaC) #NO NORMAL
             
library(car)
leveneTest(df$DeltaC,df$Diagnostico) #si

shapiro.test(df$DeltaC) #NO NORMAL


bartlett.test(dfAllDurC$dur,dfAllDurC$Diagnostico)
ks.test(dfAllDurV$dur,pnorm,mean(dfAllDurV$dur),sd(dfAllDurV$dur))


plotn <- function(x,main="Histograma de frecuencias \ny distribución normal",
                  xlab="X",ylab="Densidad") {
  min <- min(x)
  max <- max(x)
  media <- mean(x)
  dt <- sd(x)
  hist(x,freq=F,main=main,xlab=xlab,ylab=ylab)
  curve(dnorm(x,media,dt), min, max,add = T,col="blue")
}
plotn(df$VarcoV,main="Distribución normal") #Grafico de x


###############
# ESTADÍSTICA INFERENCIAL (DE DONDE SALEN LAS P)
################



#t de student: para datos normales, varianzas iguales, comparacion de poblaciones 2 grupos
t.test(misDatos$range)


####### PARA DATOS NORMALES
#anova de un factor: para datos normales
miAnova <- aov(speechRate~Diagnostico,data=df)
#sacar la tabla de anova
summary(miAnova)

# o lo que es lo mismo
summary(aov(speechRate~Diagnostico,data=df))

wht <- glht(miAnova, linfct = mcp(Diagnostico = "Tukey"))
summary(wht, test = adjusted(type = "bonferroni"))

#tabla de anova, hay que indicar modelo lineal (lm)
anova(lm(misDatos$range~misDatos$Gender))

#### anova de dos factores (se suma el segundo factor)
anova(lm(misDatos$range~misDatos$Gender+misDatos$Region))


######     TESTS NO PARAMETRICOS: SE APLICAN CUANDO LOS DATOS NO SON NORMALES #####################  

################## DATOS NUMERICOS ###################


# Mann-Whitney U-test tests
kruskal.test(DeltaC ~ Control, data = df)
# Mann-Whitney-Wilcoxon como post-hoc
wilcox.test(range ~ Gender, data=misDatos) 
# vale, pero más rápido...
pairwise.wilcox.test(df$DeltaC, df$Control, p.adjust.method = "BH")


# y esto es una adaptación especial, lo habían usado en otro paper, 
# asíq ue lo usamos para que fuera totalmente replicable
library(pgirmess)
kruskalmc(DeltaC ~ Diagnostico, data = df,cont="two-tailed")



