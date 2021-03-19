# cargamos todos los paquetes que vamos a usar
library("multcomp", "car", "pgirmess")
library("ggplot2", "nortest")
#install.packages("nortest")

# rutas en Windows 
# C:\\Users\\Nombre de usuario\\Desktop
# C:/Users/Nombre de usuario/Desktop

# rutas en Mac 
# /Users/nombre/Desktop

# Si no ves bien los acentos File>Reopen with encoding "UTF-8"

setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/3_analisisNumerico/")

# recordáis que tuvimos que convertir todo a factor? 
# nos lo vamos a ahorrar
df <- read.csv("datosTasaHablayRitmo.csv", sep=",", dec= ".", stringsAsFactors=TRUE)
df <- read.csv("/Users/tunombre/Desktop/datosTasaHablayRitmo.csv", sep=",", dec= ".", stringsAsFactors=TRUE)

# Nota: scripts de praat normalmente el output es tab separated
#df <- read.csv("datosTasaHablayRitmo.csv", sep="/t", stringsAsFactors=TRUE)

# vamos a explorar los datos 
head(df)
# ver datos
View(df)
# para cada paciente tenemos un unico valor, por lo tanto, vamos a hacer análisis
# univariantes 
# Vamos a analizar cada una de las variables una a una. speechRate, PerC... Y ver 
# cuáles de ellas son diferentes para el grupo control y para alguno de los 
# grupos de pacientes

mean(df$Edad)
min(df$Edad)
max(df$Edad)
sd(df$Edad)

#################
# CREACIÓN DE BOXPLOTS
#################
# Ahora vamos a ver de manera gráfica la tasa de habla
boxplot(df$speechRate ~ df$Control)
#añado colores
boxplot(df$speechRate ~ df$Control, col=c("deepskyblue4","coral"))

# Creeis que los controles hablan más rápido? 
boxplot(df$speechRate ~ df$Diagnostico)

# pero los gráficos bonitos son los de ggplot2 asi que vamos a ello
#library(ggplot2)

#uno simple
ggplot(df, aes(x=Diagnostico, y=-speechRate, fill=Diagnostico)) + geom_boxplot()

# para hacer las lineas menos largas podemos hacer intros pero no en cualquier 
# sitio. Necesitamos un + o una coma

# ¿Así?
ggplot(df, aes(x=Diagnostico, y=-speechRate, fill=Diagnostico)) 
 + geom_boxplot()

# Pues según R, no
ggplot(df, aes(x=Diagnostico, y=-speechRate, fill=Diagnostico)) + 
  geom_boxplot()


# ahora reordenamos según la media
ggplot(df, aes(x=reorder(Diagnostico, -speechRate, FUN = median), y=-speechRate, fill=Diagnostico)) +
 geom_boxplot()

# Pero esas labels son un poco feas ¿no?
# ¡Voy con todo! (sí, como la vecina rubia)
abc <- ggplot(df, aes(x=reorder(Diagnostico, -speechRate, FUN = median), y=speechRate,colour = Diagnostico)) +
  geom_jitter() +
  stat_boxplot(fill ="NA") +
  stat_boxplot(fill =c(NA,NA,NA,NA,NA,NA,NA,NA)) +
  theme_classic()+ylab("Sonidos por segundo")+xlab("Grupo")+
  theme(axis.text.x = element_text(angle = 90))+
  guides(colour=FALSE)+
  labs(title = "Tasa de habla")
####
# ¿Os acordáis de que guardábamos abriendo y cerrando el device y eso?
# pues aquí va otra manera usando el paquete ggplot2
# Guardará el último gráfico creado
# dependiendo de si guardamos un tiff u otra cosa necesata unos argumentos u otros
# por ejemplo para png nos sobra el compression
# tambien podemos crear la figura especificando los pixeles "in”, “cm”, “mm”
ggsave("speechRate.tiff", units="cm", width=14, height=8, dpi=100, compression = 'lzw')
ggsave("speechRate.png", units="cm", width=14, height=8, dpi=100)
# 

###########
# NORMALIDAD
############
#vamos a crearnos una funcion customizada
hola <- function(x,main="", xlab="X",ylab="Densidad") {
  min <- min(x)
  max <- max(x)
  media <- mean(x)
  dt <- sd(x)
  hist(x,freq=F,main=main,xlab=xlab,ylab=ylab)
  curve(dnorm(x,media,dt), min, max,add = T,col="blue")
  }

hola(df$speechRate,main="Distribución normal") #Grafico de x

qqnorm(df$speechRate, pch = 1, frame = FALSE)
qqline(df$speechRate, col = "steelblue", lwd = 2)
#test de normalidad, datos normales p>0.05, para pocos datos saphiro-wilk

shapiro.test(df$speechRate) #normal
shapiro.test(df$PerC)# NORMAL
shapiro.test(df$VarcoC)#NO NORMAL
shapiro.test(df$PVI.C)# no normal

# kolmogorov Smirnov (mejor con modificación de Lillefors) para más de 50 datos
# para que veais como se hace, pero no lo podríamos aplicar porque tenemos 
# 30 casos (en este caso 30 pacientes porque cada uno solo tiene 1 dato asociado)
# en biología solo lo aplican si tienen un porrón de datos
ks.test(df$speechRate,pnorm,mean(df$speechRate),sd(df$speechRate)) # estamos comparando nuestros datos con la d. normal
library("nortest")
lillie.test(df$speechRate) # normal

# para los normales también hay que mirar igualdad de las varianzas 
# llamada homoscedasticity
# de nuevo la p funciona al reves porque lo que hacemos es no rechazar 
#la hipotesis nula

# library(car)
# vamos a comprobarlo con 3 tests
bartlett.test(df$speechRate,df$Diagnostico) #si Esta es muy sensible a las desviaciones de la normalidad
leveneTest(df$speechRate,df$Diagnostico) #si 
leveneTest(df$PerC,df$Diagnostico) #si 





###############
# ESTADÍSTICA INFERENCIAL (DE DONDE SALEN LAS P)
################


#t de student: para datos normales, varianzas iguales, comparacion de poblaciones 2 grupos
# si me da significativo quiere decir que en mis datos hay dos grupos
# los hay? Pues seguramente, recordemos que teníamos Controles vs APP y que eran muuuy diferentes
t.test(df$speechRate)
t.test(df$PerC)


####### PARA DATOS NORMALES más de dos grupos (y con la posibilidad de hacer post-hoc)
#anova de un factor: para datos normales
miAnova <- aov(speechRate~Diagnostico,data=df)
#sacar la tabla de anova
summary(miAnova)
# F(34,7)=10.39, p =0.0004
# F(34,7)=10.39, p <0.001


# o lo que es lo mismo
summary(aov(speechRate~Diagnostico,data=df))

# otra manera de ver la tabla de anova
library(broom)
tidy(miAnova)

#tabla de anova, hay que indicar modelo lineal (lm)
anova(lm(speechRate~Diagnostico,data=df))

#### anova de dos factores (se suma el segundo factor)
anova(lm(speechRate~Diagnostico+Edad,data=df))
anova(lm(speechRate~Diagnostico+Sexo,data=df))

# el post-hoc de toda la vida
TukeyHSD(aov(speechRate~Diagnostico,data=df))

# en el artículo replicamos otro estudio, esta es la manera de hacer post-hocs 
# del otro estudio

#pair-wise comparisons
library("multcomp")

pairWise <- glht(miAnova, linfct = mcp(Diagnostico = "Tukey"))
summary(pairWise, test = adjusted(type = "bonferroni"))

# intervalos de confianza 95%
plot(print(confint(pairWise)))

######     TESTS NO PARAMETRICOS: SE APLICAN CUANDO LOS DATOS NO SON NORMALES #####################  

################## DATOS NUMERICOS ###################
# VarcoC y rPVI-C no eran normales

# Mann-Whitney-Wilcoxon (alternativa al t test, solo dos niveles)
wilcox.test(VarcoC ~ Control, data=df) # significativo
# W= 133 

# Kruskal-Wallis para más grupos
kruskal.test(VarcoC ~ Diagnostico, data = df) # pero para los grupos ya no
kruskal.test(PVI.C ~ Diagnostico, data = df) # este sí!!!

# ¿Pero entre qué grupos?
# Vamos a hacer nuestros post-hoc, recordad que siempre se puede ir haciendo 
#grupo por grupo la comparación

# o hacer el test de antes (el que comparaba 2 muestras) para todos
pairwise.wilcox.test(df$PVI.C, df$Diagnostico, p.adjust.method = "BH")


# o podemos hacer el test diseñado específicamente para cuando el Kruskal Wallis nos da significativo
#library(pgirmess)
kruskalmc(PVI.C ~ Diagnostico, data = df,cont="two-tailed")
kruskalmc(df$PVI.C ~ df$Diagnostico, cont="two-tailed")

# pero en cualquiera de los dos casos, no hay ninguna pareja que sea lo sificientemente potente
#para dar significativo, conclusión...
# amplía la muestra
# ¯\_(ツ)_/¯

