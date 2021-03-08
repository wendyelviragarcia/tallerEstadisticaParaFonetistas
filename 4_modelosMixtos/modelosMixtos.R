#analisis dur vocalica
library(multcomp)
library(car)
library(lme4)
library(cAIC4)

setwd("/Users/weg/OneDrive - UNED/00_paperLoquensSantPau/analisisEstadistico/")

load("df_todasDuraciones.RData")
load("df_Ritmo.RData")
df$Sexo <- df$Gender
dfAllDurC <- allDur[allDur$type=="Consonante",]
dfAllDurV <-allDur[allDur$type=="Vocal",]

#allDur$DiagnosisGroup[allDur$DiagnosisGroup=="Control"] 
#levels(allDur$DiagnosisGroup)[levels(allDur$DiagnosisGroup)=="Control"]<- "Control"


shapiro.test(allDur$dur)
#duraciones no normales
leveneTest(allDur$dur,allDur$DiagnosisGroup)
qqnorm(dfAllDurC$dur, pch = 1, frame = FALSE)
qqline(dfAllDurC$dur, col = "steelblue", lwd = 2)
library(nortest)
lillie.test(dfAllDurC$dur)

qqPlot(allDur$dur)

ggplot(allDur)+
  geom_histogram(aes(x=dur))

leveneTest(dfAllDurV$dur,dfAllDurV$DiagnosisGroup)



plotn <- function(x,main="Histograma de frecuencias \ny distribución normal",
                  xlab="X",ylab="Densidad") {
  min <- min(x)
  max <- max(x)
  media <- mean(x)
  dt <- sd(x)
  hist(x,freq=F,main=main,xlab=xlab,ylab=ylab)
  curve(dnorm(x,media,dt), min, max,add = T,col="blue")
}

plotn(allDur$dur,main="Distribución normal") #Grafico de x

ggplot(data = allDur,aes(x=DiagnosisGroup,y=dur,fill=DiagnosisGroup, colour=file))+geom_boxplot()+
  guides(fill=FALSE, colour = FALSE)+
  facet_wrap( ~ type)+
  facet_grid(type ~"Grupos diagnósticos")+
  ggtitle("Duración")+theme_classic()+ylab("(ms)")+xlab("")
ggsave("duracion.tiff", units="cm", width=15, height=15, dpi=300, compression = 'lzw')

###################
# COMPROBACION NORMALIDAD
#############
shapiro.test(dfAllDurV$dur)
ks.test(dfAllDurV$dur,pnorm,mean(dfAllDurV$dur),sd(dfAllDurV$dur))

bartlett.test(dfAllDurC$dur,dfAllDurC$DiagnosisGroup)
bartlett.test(dfAllDurC$dur,dfAllDurC$Control)


shapiro.test(dfAllDurV$dur)
###################
# MODELO DURACION
#############
#sin interfects
modelo <- lmer(dur ~ DiagnosisGroup+ type+ (1|Subject), data=allDur)
summary(modelo)
cAIC(modelo) #29728.90

#EL iNCLUIDO EN EL PAPER con INTERACCION 
modelo <- lmer(dur ~ DiagnosisGroup+type+ (1+type|Subject), data=allDur)
coef(modelo)
summary(modelo) # 754.0    27.46    
cAIC(modelo) # 29380.73

(29728.90-29380.73)/2 #  the second is 174.085 veces as probable as the first model to minimiza information loss

#modelo para hacer la anova con el reml en false
modelo <- lmer(dur ~ DiagnosisGroup+type+ (1+type|Subject), REML = FALSE, data=allDur)
summary(modelo)
modelo.null <- lmer(dur ~ type+ (1+type|Subject), REML = FALSE, data=allDur)
anova(modelo,modelo.null)

###################
# Replica del estudio de Bartlett
#############




#Estimación del modelo de la duración para consonantes ***
modelo <- lmer(dur ~ ageEval + DiagnosisGroup+ (1|Subject), data=dfAllDurC, REML = FALSE)
modelo <- lmer(dur ~ DiagnosisGroup+ (1|Subject), data=dfAllDurC, REML = TRUE)
summary(modelo) 
cAIC(modelo) 

modelo <- lmer(dur ~ DiagnosisGroup+ (1|Subject), data=dfAllDurC, REML = FALSE)
modelo.null <- lmer(dur ~ ageEval + (1|Subject), data=dfAllDurC, REML = FALSE)
anova(modelo, modelo.null)

#Estimación del modelo de la duración para vocales ***
modelo <- lmer(dur ~ ageEval + DiagnosisGroup+ (1|Subject), data=dfAllDurV, REML = FALSE)
modelo <- lmer(dur ~ DiagnosisGroup+ (1|Subject), data=dfAllDurV, REML = TRUE)
summary(modelo) 
cAIC(modelo) 
#evaluación del cAIC diferencia de los modelos entre dos
(14988.38-15662.25)/2

summary(modelo)
modelo.null <- lmer(dur ~ ageEval + (1|Subject), data=dfAllDurV, REML = FALSE)
summary(modelo.null)
anova(modelo, modelo.null)

modelo <- lmer(dur ~ DiagnosisGroup+type+ (1|Subject), data=allDur)
modelo <- lmer(dur ~ DiagnosisGroup+type+ (1+type|Subject), REML = TRUE, data=allDur)

wht <- glht(modelo, linfct = mcp(DiagnosisGroup = "Tukey"))
summary(wht)
library(emmeans)
name<-emmeans(modelo, pairwise~DiagnosisGroup, adjust = "Bonferroni",pbkrtest.limit = 3232)
pairs(name)

summary(wht)
summary(wht, test = adjusted(type = "bonferroni"))