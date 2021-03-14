#analisis dur vocalica
library(multcomp)
library(car)
library(lme4)
library(cAIC4)
library(ggplot2)

# ruta en Windows 
# C:\\Users\\Nombre de usuario\\Desktop
# C:/Users/Nombre de usuario/Desktop

setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/4_modelosMixtos/")

#cargo datos
allDur <- read.csv("consonantDuration.csv")


allDur$Sexo <- allDur$Gender
dfAllDurC <- allDur[allDur$Tipo=="Consonante",]


shapiro.test(allDur$dur)


#duraciones no normales

leveneTest(allDur$dur,allDur$Grupo)
# que paso???

library("dplyr")
allDur <- allDur %>% mutate_if(is.character,as.factor)



library(nortest)
lillie.test(dfAllDurC$dur)

qqPlot(allDur$dur)

ggplot(allDur)+
  geom_histogram(aes(x=dur))




###################
# GRÁFICO CAJA Y BIGOTES (BOXPLOT)
#############

ggplot(data = allDur,aes(x=Grupo,y=dur,fill=Grupo, colour=Sujeto))+geom_boxplot()+
  guides(fill=FALSE, colour = FALSE)+
  facet_wrap( ~ Tipo)+
  facet_grid(Tipo ~"Grupos diagnósticos")+
  ggtitle("Duración")+theme_classic()+ylab("(ms)")+xlab("")
#ggsave("duracion.tiff", units="cm", width=15, height=15, dpi=300, compression = 'lzw')

###################
# COMPROBACION NORMALIDAD
#############
shapiro.test(dfAllDurV$dur)
ks.test(dfAllDurV$dur,pnorm,mean(dfAllDurV$dur),sd(dfAllDurV$dur))

bartlett.test(dfAllDurC$dur,dfAllDurC$Grupo)
bartlett.test(dfAllDurC$dur,dfAllDurC$Control)


shapiro.test(dfAllDurV$dur)
###################
# MODELO DURACION
#############

modelo <- lmer(dur ~ Grupo+ Tipo+ (1|Sujeto), data=allDur)
summary(modelo)

#EL INCLUIDO EN EL PAPER con INTERACCION 
modeloConInteraccion <- lmer(dur ~ Grupo+Tipo+ (1+type|Sujeto), data=allDur)
coef(modeloConInteraccion)
summary(modeloConInteraccion) # 754.0    27.46    

# Y cómo sabemos cuál es mejor?
# Calculamos el conditional Akaike information
cAIC(modelo) #29728.90
cAIC(modeloConInteraccion) # 29380.73
# Y para saber cuál es mejor, calculamos la diferencia entre 2 y quiere decir que...
(29728.90-29380.73)/2 
#  el segundo modelo tiene 174.085 más posibilidades que el primero
# de minimizar la pérdida de información

# Por lo tanto, el modelo es mejor, ¿pero es bueno?
# En realidad, en estadística la certeza no existe, solo las probabilidades

################
# Conseguir una p usando modelos lineales
################
# Un estadístico no necesitaría esa p, si la quieres hay muchas maneras de 
# conseguirla, aquí vemos una fácil.

# Vamos a comparar el modelo con el grupo (APPsem, Control) contra un modelo
# que no incluyera esa variable. Después comparamos los modelos con una 
# anova para ver si son iguales o diferentes. Si son diferentes, quiere
# decir que esa variable hace que el modelo cambie, es significativo

# Modelo para hacer la anova necesita el REML en false
modelo <- lmer(dur ~ Grupo+Tipo+ (1+Tipo|Sujeto), REML = FALSE, data=allDur)
summary(modelo)
modelo.null <- lmer(dur ~ Tipo+ (1+Tipo|Sujeto), REML = FALSE, data=allDur)
anova(modelo,modelo.null)


# Y ahora, cuáles de los grupos tienen diferencias
modelo <- lmer(dur ~ Grupo+Tipo+ (1+Tipo|Sujeto), REML = TRUE, data=allDur)

testHipotesisLineal <- glht(modelo, linfct = mcp(Grupo = "Tukey"))
summary(testHipotesisLineal)
summary(testHipotesisLineal, test = adjusted(type = "bonferroni"))


# estimated marginal means (EMMs)
library(emmeans)
name<-emmeans(modelo, pairwise~Grupo, adjust = "Bonferroni",pbkrtest.limit = 3232)
pairs(name)

