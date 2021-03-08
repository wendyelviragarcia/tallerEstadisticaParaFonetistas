setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/numerico")
#load("misDatos.Rda")
library(lme4)
library(ggplot2)
library(MASS)
library(readr)
library(readxl)
require(plyr)
library(dplyr)



misDatos <- read_excel("suspendidas.xls")

##################
# Preparar los datos
###################

# variables
misDatos$Region<- tolower(misDatos$Region)

# vamos a cambiar las etiquetas de region para que quede más mono
misDatos$Region<- revalue(misDatos$Region, c("b"="Barcelona", "m"="Madrid", "s" = "Seville", "c" = "Cantabria"))
misDatos$Gender<- revalue(misDatos$Gender, c("f"="Female", "m"="Male"))

# pasar a factor
misDatos <- misDatos %>% mutate_if(is.character,as.factor)

# quedarnos solo con los datos que nos interesan (en este caso quitar las agudas del estudio)
misDatos = misDatos[misDatos$`tipo acentual I` != "1",] 
misDatos$nuclearConfig<- as.factor(gsub("\\\\", "", as.character(misDatos$nuclearConfig)))

misDatos = misDatos %>% mutate(sustained = ifelse(nuclearConfig == "H* H%" |nuclearConfig == "H* !H%", "yes", "no"))
misDatos$sustained= as.factor(misDatos$sustained)



##################
# Vamos a analizar un dato numérico el rango de F0
###################

boxplot(misDatos$range ~ misDatos$nuclearConfig,
        col=c("deepskyblue4","coral"))

#comprobamos la normalidad d elos datos
# de manera gráfica
hist(misDatos$range)
# ahora vamos a hacerlo un poco más fino

m<-mean(misDatos$range)
std<-sqrt(var(misDatos$range))
hist(misDatos$range, density=20, breaks=20, prob=TRUE, 
     xlab="x-variable", ylim=c(0, 0.2), 
     main="La normal sobre mis datos")
curve(dnorm(x, mean=m, sd=std), 
      col="orange", lwd=2, add=TRUE, yaxt="n")


#test de normalidad, datos normales p>.05, para pocos datos saphiro-wilk
shapiro.test(misDatos$range)
# kolmogorov Smirnov (con modificación de Lillefors) para más de 50 datos
library("nortest")
lillie.test(x = misDatos$range)


#t de student: para datos normales, varianzas iguales, comparacion de poblaciones 2 grupos
t.test(misDatos$range)

#anova de un factor: para datos normales
aov(misDatos$range~misDatos$Gender)
#sacar la tabla de anova
summary(aov(misDatos$range~misDatos$Gender))
#tabla de anova, hay que indicar modelo lineal (lm)
anova(lm(misDatos$range~misDatos$Gender))

#### anova de dos factores (se suma el segundo factor)
anova(lm(misDatos$range~misDatos$Gender+misDatos$Region))

###### COMPROBACION DE LA INFLUENCIA DE LOS FACTORES EN UNA ANOVA
#si los dos factores dan significativo hay que hacer un grafico de interaccion para ver si una variable influye en la otra
# la filosof?a que hay detras es parecida a la correlacion solo que los datos no son numericos (escalares) sino factores (nominales)

#para verlo en forma de gr?fico: si hay interaccion las curvas seran parelelas
interaction.plot(misDatos$Gender, misDatos$Region, misDatos$range)
#para ver si la ibnteracci?n entre curvas paralelas es significativa, haremos una anova de la interaccion
anova(lm(misDatos$range ~ misDatos$Gender + misDatos$Region + misDatos$Gender*misDatos$Region))


#####################     TESTS NO PARAMETRICOS: SE APLICAN CUANDO LOS DATOS NO SON NORMALES #####################  

################## DATOS NUMERICOS ###################
#test de mann-whitney tb se llama wilcoxon esta es su funcion
wilcox.test(range ~ Gender, data=misDatos) 


######## Boxplot RANGE #############
  ggplot(misDatos, aes(x=nuclearConfig, y=range, fill=Region)) + geom_boxplot()+
  geom_boxplot(aes(color = Region), fatten = NULL, fill = NA, coef = 0, outlier.alpha = 0) +
  labs(title="Plot of range per nuclear configuration",x="Nuclear configuration (Sp_ToBI)", y = "Range (st)")

misDatos.nointer = lmer(range ~ Region + Gender+ Rural + nuclearConfig+(1|Speaker)+(1|constituyentes), data=misDatos, REML=FALSE)
misDatos.inter = lmer(range ~ Region * Gender+Rural + nuclearConfig+(1|Speaker)+(1|construccion), data=misDatos, REML=FALSE)
anova(misDatos.nointer, misDatos.inter)
#no significativo me puedo cargar los interceptos

#solo para la suspendida
suspendidas <- misDatos[misDatos$sustained=="yes",]
suspendidas.model <- lmer(range ~ Region +Gender+Rural+(1|Speaker)+(1|Item),data=suspendidas, REML=FALSE)
suspendidas.null <- lmer(range ~Gender+Rural+(1|Speaker)+(1|Item),data=suspendidas, REML=FALSE)
anova(suspendidas.model,suspendidas.null)


ggplot(suspendidas, aes(x=Region, y=range, fill=Region)) + geom_boxplot()+
  geom_boxplot(aes(color = Region), fatten = NULL, fill = NA, coef = 0, outlier.alpha = 0) +
  labs(title="Plot of range per nuclear configuration",x="Nuclear configuration (Sp_ToBI)", y = "Range (st)")


## monto el modelo como dependiente (las de estudio)
#efectos fijos el sexo porque siempre hará que tenga valores más altos

misDatos.model = lmer(range ~ Region + Gender+ Rural + nuclearConfig+ `tipo acentual I`+(1|Speaker)+(1|Item), data=misDatos, REML=FALSE)
summary(misDatos.model)
####################################
# against Gender: NO
misDatos.null = lmer(range ~ Region + Rural + nuclearConfig+ (1|Speaker)+(1|Item), data=misDatos, REML=FALSE)
#hey! model failed to converge.  Model failed to converge with 

anova(misDatos.model, misDatos.null)
# npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)
#misDatos.null    11 2310.9 2358.0 -1144.4   2288.9                     
#misDatos.model   12 2310.8 2362.2 -1143.4   2286.8 2.0822  1      0.149

################################
# against rural: NO
misDatos.null = lmer(range ~ Region + Gender+ nuclearConfig+`tipo acentual I`+(1|Speaker)+(1|Item), data=misDatos, REML=FALSE)
anova(misDatos.model, misDatos.null)
# Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
# misDatos.null  13 2551.2 2606.8 -1262.6   2525.2                         
# misDatos.model p 0.5


################################
# against region: YES
misDatos.null = lmer(range ~ Rural + Gender+ nuclearConfig+`tipo acentual I`+(1|Speaker)+(1|Item), data=misDatos, REML=FALSE)
anova(misDatos.model, misDatos.null)
# Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)  
# misDatos.null  11 2556.8 2603.8 -1267.4   2534.8                           
# misDatos.model  0.1

coef(misDatos.model)

# para info más concreta del summary usar: kaike’s Information Criterion, the log-Likelihood 

#######
#ESTUDIO DEL RANGO PARA LAS ANOTADAS COMO SUSPENDIDAS
######
misDatosHH <- misDatos[misDatos$nuclearConfig=="H* H%",]
misDatos.model = lmer(range ~ Region + Gender +Rural+ `tipo acentual I`+(1|Speaker)+(1|Item), data=misDatosHH, REML=FALSE)
summary(misDatos.model)
#region sí
misDatos.null = lmer(range ~ Gender+ Rural+`tipo acentual I`+(1|Speaker)+(1|Item), data=misDatosHH, REML=FALSE)
anova(misDatos.model,misDatos.null)
summary(misDatos.model)

#gender no
misDatos.null = lmer(range ~ Region+ Rural+`tipo acentual I`+(1|Speaker)+(1|Item), data=misDatosHH, REML=FALSE)
anova(misDatos.model,misDatos.null)

# rural no
misDatos.null = lmer(range ~ Region+ Gender+`tipo acentual I`+(1|Speaker)+(1|Item), data=misDatosHH, REML=FALSE)
anova(misDatos.model,misDatos.null)

misDatos.model = lmer(range ~ relevel(Region, ref = "Cantabria") + Gender +Rural+ `tipo acentual I`+(1|Speaker)+(1|Item), data=misDatosHH, REML=FALSE)
summary(misDatos.model)
#######
#factor sustained or not
######

#check for intercepts
category.nointer <- glmer(sustained ~ Region * Gender + Rural + (1|Speaker)+(1|construccion), family = binomial, data=misDatos)
category.inter <- glmer(sustained ~ Region + Rural + Gender+ (1|Speaker)+(1|construccion), family = binomial, data=misDatos)
anova(category.nointer,category.inter)
#intercept is significant but models with intercepts do not converge.
#
# MODEL FOR DATA
category.model <- glmer(sustained ~ Region*Gender + Rural +  (1|Speaker), family = binomial, data=misDatos)
coef(category.model)

#
# GENDER
category.null <- glmer(sustained ~ Region + Rural + (1|Speaker), family = binomial, data=misDatos)
anova(category.model,category.null)

#
# REGION
category.null <- glmer(sustained ~ Rural + Gender+(1|Speaker)+(1|construccion), family = binomial, data=misDatos)
anova(category.model,category.null)

#
# RURAL Madrid only has 1, we need to change model
category.null <- glmer(sustained ~ Region + Gender+(1|Speaker), family = binomial, data=misDatos)
anova(category.model,category.null)



#########
# FACTOR NUCLEAR CONFIG
######

# MODEL FOR DATA
category.model <- glmer(sustained ~ Region*Gender + Rural +  (1|Speaker)+(1|construccion), family = binomial, data=misDatos)
coef(category.model)
