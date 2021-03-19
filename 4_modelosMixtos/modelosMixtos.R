###############
# Modelos mixtos
############

# ¿Qué librerías vamos a usar?
# Recuerda si no las tienes instaladas, instálalas con install.packages("nombreDelPaquete")
# Análisis dur vocalica
# la libreria de los post.hoc
library(multcomp)
library(car)
#libreria para crear modelos lmer()
library(lme4)
#libreria para evaluar modelos cAIC
library(cAIC4)
# libreria de las  figuras ggplot()
library(ggplot2)

############
# inicio, nos colocamos en la carpeta que debemos
###########

# ruta en Windows 
# C:\\Users\\Nombre de usuario\\Desktop
# C:/Users/Nombre de usuario/Desktop

setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/4_modelosMixtos/")

#cargo datos
allDur <- read.csv("consonantDuration.csv")
# si no he cambiado el working directory, con setwd, tendré que poner
# completa la ruta del fichero, así
allDur <- read.csv("/Users/weg/Desktop/4_modelosMixtos/consonantDuration.csv")


shapiro.test(allDur$dur)
#duraciones no normales

# comprobamos varianzas, ya ni haría falta
leveneTest(allDur$dur,allDur$Grupo)
# que paso??? Lee el warning

library("dplyr")
allDur <- allDur %>% mutate_if(is.character,as.factor)

# Ten en cuenta que si has mezclado "mujer" "Hombre" y "hombre". te dirá que hay 
# una variable con tres niveles y no dos.
# Si te pasa eso, vuelve a pasar la variable a char, pasa a minuscula y 
# vuelve a convertir en factor
allDur$Sexo<- as.character(allDur$Sexo)
allDur$Sexo <- tolower(allDur$Sexo)

###################
# COMPROBACION NORMALIDAD
#############

library(nortest)
lillie.test(allDur$dur)

qqPlot(allDur$dur)

ggplot(allDur)+
  geom_histogram(aes(x=dur, bins=100))



###################
# GRÁFICO CAJA Y BIGOTES (BOXPLOT)
#############
ggplot(data = allDur,aes(x=Sujeto, y=dur, group=Sujeto,fill=Grupo))+geom_boxplot()+
  facet_wrap( ~ Grupo)
  
ggplot(data = allDur,aes(x=Grupo, y=dur, group= Grupo, fill=Grupo, colour=Sujeto))+geom_boxplot()+
  guides(fill=FALSE, colour = FALSE)+
  facet_wrap( ~ Tipo)+
  facet_grid(Tipo ~"Grupos diagnósticos")+
  ggtitle("Duración")+theme_classic()+ylab("(ms)")+xlab("")
ggsave("duracion.tiff", units="cm", width=15, height=15, dpi=300, compression = 'lzw')
ggsave("duracion.png", units="cm", width=15, height=15, dpi=300)



###################
# MODELO LINEAL DURACION
#############
# la idea para montarlo es como una anova
# la duración depende del grupo?
# pero en vez de devolvernos si sí o no (si pueden ser parte de la misma muestra)
# nos dice cuanto cambian los números dependiendo del grupo
# a esto se le llama regresión y es como las formulitas aquellas del cole 
# en las que sacábamos la función de una pendiente

modeloLineal <- lm(dur ~ Grupo, data=allDur)
# igual que
modeloLineal <- lm(allDur$dur ~ allDur$Grupo)

summary(modeloLineal)
# ese intercepto no nos va muy bien... El orden dijimos que es automático
# vamos a ver los niveles que tiene ese factor y en que orden
levels(allDur$Grupo)
# Vamos a hacer que la referencia sean los controles, el resultado es el mismo
# solo es más intuitivo
allDur = allDur %>% mutate(Grupo = relevel(Grupo, 4))
levels(allDur$Grupo)

modeloLineal <- lm(allDur$dur ~ allDur$Grupo)
summary(modeloLineal)
# Ahora mejor. 
# Vamos a entender este modelo, para después ir a los siguientes.
# La duración estimada del grupo control es 70.830
# en el modelo debería ser parecida.
controles <- allDur[allDur$Grupo=="Control",]
mean(controles$dur)

#igual que
mean(allDur[allDur$Grupo=="Control",]$dur)

# ¿Se entiende mejor el concepto de modelo?
# Nos está prediciendo la media de los datos

# pero la regresión ha existido toda la vida no?
# Sí, nuestro objetivo no son los factores fijos, son los aleatorios
# necesarios para experimentos con medidas repetidas (3 repes de algo)
# o donde esperamos que cada sujeto tenga su propia media
# por ejemplo, yo sé que cada sujeto tendrá un F0 base propio y a partir de ahí
# esperaré las variaciones, no me importa si uno tiene 120 y el otro 220 me importa
# si a su base le están haciendo +60 o -60.
# Incluir el random effect da cuenta de esa variación
# Incluimos que cada sujeto tiene una duración diferente
# (Otra cosa posible es normalizar, en z-score o en este caso con su speech rate)
library(lme4)
modelo <- lmer(dur ~ Grupo+ Tipo+Sexo+ (1|Sujeto), data=allDur)
summary(modelo)


# EL INCLUIDO EN EL PAPER con INTERACCIÓN
# Un pasito más allá, a veces los sujetos pueden interaccionar, pueden no "sumarle lo mismo" según
# si algo es vocal o consonante. Igual en las consonantes suman más duración
modeloConInteraccion <- lmer(dur ~ Grupo+Tipo+ (1+Tipo|Sujeto), data=allDur)
coef(modeloConInteraccion)
summary(modeloConInteraccion) # 754.0    27.46

################
# ¿Y cómo sé qué modelo incluir en el paper?
################
# Inlcuimos el mejor, el que da mejor cuenta de la variación de los datos
# ¿Y cómo sabemos cuál es mejor?
# De muchas maneras, os enseño 2 aptas para filólogos

# 1) Residuo pequeño y normal
# 2) AIC Calculamos el conditional Akaike information
cAIC(modelo) #29728.90
cAIC(modeloConInteraccion) # 29380.73
# Y para saber cuál es mejor, calculamos la diferencia entre 2 y quiere decir que...
probalidades =(cAIC(modelo)- cAIC(modeloConInteraccion))/2
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
# decir que esa variable hace que el modelo cambie, esa variable es significativa

# Para hacer la anova de un modelo hay que poner el REML en false
# ¿Por qué? No lo sé. Pero a los estadísticos se les hace caso
modelo <- lmer(dur ~ Grupo+Tipo+ (1+Tipo|Sujeto), REML = FALSE, data=allDur)
summary(modelo)
modelo.sinlacosaquemeimporta <- lmer(dur ~ Tipo+ (1+Tipo|Sujeto), REML = FALSE, data=allDur)
anova(modelo,modelo.sinlacosaquemeimporta)


# Y ahora, cuáles de los grupos tienen diferencias
#######
# POSIBILIDADES DE POST-HOC PARA UN MODELO
######
# volvemos a crearnos el modelo
modelo <- lmer(dur ~ Grupo+Tipo+ (1+Tipo|Sujeto), REML = TRUE, data=allDur)

# vamos a hipotetizar que nuestros datos se ajustan al modelo
# library(multcomp)
testHipotesisLineal <- glht(modelo, linfct = mcp(Grupo = "Tukey"))
summary(testHipotesisLineal)
# Nos da un warning
# para arreglarlo tenemos que usar la corrección de bonferroni 
summary(testHipotesisLineal, test = adjusted(type = "bonferroni"))

# O directamente nos vamos a un paquete que han creado específicamente para 
# hacer post-hocs de lmer y que por tanto está preparado para ello
# estimated marginal means (EMMs)

library(emmeans)
misParejas<-emmeans(modelo, pairwise~Grupo, adjust = "Bonferroni",pbkrtest.limit = 3232)
pairs(misParejas)

# Atención, hay muchos post-hoc, el mejor para tus datos dependerá de estos
# y ahí es cuando viene la consulta con el estadístico
# o, en su defecto, mucho buceo en 1) la información de los paquetes 
# 2) artículos parecidos al tuyo que hayan pasado peer-review
# 3) Si tienes la suerte de saber leerlos, ir a los papers donde se explican las 
# formulas y convertirte en un estadístico de pro, que no estadista.

# Hasta aquí el curso y, go play with data!


# ¡Extra! Como guardar un daraframe
# en formato Rdata solo se podrá abrir en R
save(controles, file="hola.RData")

# en Excel 
library(writexl)
write_xlsx(controles,"hola.xlsx")
write_xlsx(controles,"hola.xls")

# y en csv, se puede importar en Excel, ver como texto plano y es universal
write.csv(controles, file="hola.csv")
