
# Vamos a hacer que las cosas se nos guarden donde deben y se abran desde donde deben
getwd()
# en windows

# ruta en Windows 
# C:\\Users\\Nombre de usuario\\Desktop
# C:/Users/Nombre de usuario/Desktop
# /Users/tunombre/Desktop/

setwd("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/2_analisisNominal/")
##########
# Datos nominales
##########
# Tanto la variable respuesta como el predictor son nominales
# no son números
# Los entendemos a partir de ver tablas de contingencia

# Leer la base de datos creada previamente
# En este caso leemos desde un archivo excel 
# lo vamos a hacer mediante interfaz, después copiamos el código para tenerlo para siempre
library(readxl)
misDatos <- read_excel("base_datos_leon.xlsx")

misDatos$Informante 
#Qué ves?

misDatos$Informante <- as.factor(misDatos$Informante)
misDatos$Tarea <- as.factor(misDatos$Tarea)
misDatos$Archivo <- as.factor(misDatos$Archivo)
misDatos$Patrón <- as.factor(misDatos$Patrón)

# de manera canónica todos los paquetes se cargan lo primero (arriba)
library("dplyr")
# una manera alternativa de hacerlo en una línea
misDatos <- misDatos %>% mutate_if(is.character,as.factor)


# vamos a ver frecuencias de manera numerica
# creación de una tabla de contingencia
datosParaAnalizar <-misDatos[misDatos$Informante=="wl61",]
datosParaAnalizar <-droplevels(datosParaAnalizar)
data <- table(datosParaAnalizar$Patrón, datosParaAnalizar$Tarea)
data <- as.data.frame(data)
colnames(data) <- c("Patrón", "Tarea", "Frecuencia")


##########
# Visualización gráficos de barras
##########


# Grouped Bar Plot
library(ggplot2)

ggplot(data=data, aes(x=Tarea, y=Frecuencia, fill=Patrón)) + 
  geom_bar(stat="identity")

#theme = theme_set(theme_minimal())

miGráfico <- ggplot(data=data, aes(x=Tarea, y=Frecuencia, fill=Patrón)) + 
  #facet_grid(data$Tarea)+
  geom_bar(position="dodge", stat="identity")+
  scale_fill_manual("Patrón", values = c("¡H* LH%" = "blue", "¡H* L%" = "yellow"))+
  labs(title="Ocurrencias de patrones por tarea", x="", y="Frecuencia", fill="Estos son los patrones")

# para guardarlo
#tiff("splitbyRegionPercentage.tiff", units="cm", width=20, height=15, res=300)
# en el nombre del archivo podeis poner toda la ruta /Users/... o solo el nombre
# si solo ponéis el nombre se guardará en el "working directory" getwd()

png("splitbyRegionPercentage.png", units="cm", width=20, height=15, res=300)
  miGráfico
dev.off()

tiff("splitbyRegionPercentage.tiff", units="cm", width=20, height=15, res=300)
miGráfico
dev.off()

# otras opciones de position, ¡probadlas!
# position="dodge"
# position="stack"
# position="fill"

# lista de colores 
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf?utm_source=twitterfeed&utm_medium=twitter

# Vamos a cambiar la etiqueta de patrón para que sea más entendible
library(plyr)
data$Patrón<- revalue(data$Patrón, c("¡H* LH%"="Híbrido", "¡H* L%"="Tradicional", "L+H* L%"="Tradicional", "L* H%"="Estándar"))

# Y ahora si queremos que salga en el gráfico hay que volver a ejecutarlo

#######
# Gráfico con porcentajes, para hacerlo, calculo matemáticamente el porcentage
# lamanera de hacer el gráfico es la misma

porc= table(misDatos$Tarea,misDatos$Patrón)/rowSums(table(misDatos$Tarea,misDatos$Patrón))
pc= as.data.frame(porc)
pc$Freq = pc$Freq*100

dePorcentaje <- ggplot(pc, aes(fill=Var1, y=Freq, x=Var2)) + 
  geom_bar(position="dodge", stat="identity") +
  geom_text(aes(label=paste0(round(Freq,2),"%")),color="black",vjust=1.6,position=position_dodge(width = 1),size=2)

# Nos ha quedado un poco feo, vamos a añadirle cosas
dePorcentaje +
  xlab("Patrón")+
  ylab("Frecuencia (%)")+
  labs(fill = "Tarea", caption = "*Porcentajes")+
  theme_minimal()+
  scale_fill_brewer(palette="Set2")
  




##############
#   UN POCO DE ESTADÍSTICA
################

#descriptivos
min(data$Frecuencia)
max(data$Frecuencia)
mean(data$Frecuencia)
#un resumen de los descriptivos más habituales
summary(data$Frecuencia)


# lo más simple un chi cuadrado
# le damos de comer la tabla de contingencia y ya esta
chisq.test(table(misDatos$Patrón, misDatos$Tarea))
chisq.test(data)
# Teoría de la estadística. El test Chi solo se puede usar cuando ningún valor esperado es >5
# Es decir ¡tenemos muy pocos datos para hacer eso! (Una celda tiene un valor de 0)
# ¡Vamos a cambiar de test!

fisher.test(table(misDatos$Patrón, misDatos$Tarea))

# Ahora sabemos que algo es estadísticamente diferente, pero... ¿qué? Quizá es solo el 
# maptask y eso ya lo vemos a ojímetro
# Operadores lógicos Y & O |
leidoContraInducido <- filter(misDatos, Tarea == "Inducido" | Tarea == "Lectura" )
fisher.test(table(leidoContraInducido$Patrón, leidoContraInducido$Tarea))


# Hacer esto (repetir el análisis para cada pareja) es una posibilidad, pero
# hay una más elegante
# usar un modelo Log-Lineal
########
# Para este tipo de momdelos
# log-lineales (glm)
# necesitamos los datos ya en tabla de contingencia 
# la tabla de contingencia (la frecuencia de cada patrón)
# usamos familia Poisson 
#######


# vamos a predecir la aparición del patrón tradicional
tradicional <- data[data$Patrón=="Tradicional",]
miModelo <- glm(tradicional$Frecuencia ~ tradicional$Tarea, 
                family = poisson)

# Vamos a explorar un poco
summary(miModelo)

# Deviance Residuals: el residuo, todo lo que no es explicable por el modelo
# lo queremos pequeño y con una distribución normal
# ahora no lo podemos ver por el tipo de muestra (pequeña) en la ultima sesión lo veremos

# el intercepto es lo que nos queda enmedio, lo escoge el programa por el orden
# de los factores (el 1o que sale en el gráfico, alfabético), se puede cambiar
tradicional = tradicional %>% mutate(Tarea = relevel(Tarea, 3))
# y la estimación es la probabilidad de que te salga ese patrón, ahora solo 
# nos preocupa el signo (más probable o menos probable), pero 
# a partir de ese número (que es logaritmico). El log-count esperado para una unidad 
# crecerá lo que pone en el estimado.

# Bondad del ajuste del modelo
# Si el valor es <0.05 hay ASOCIACIÓN 
1-pchisq(miModelo$deviance, miModelo$df.residual)
# y es un buen modelo 
pchisq(miModelo$deviance, miModelo$df.residual,lower.tail=FALSE)


##### ahora vamos a usar más datos
todo<- as.data.frame(table(misDatos$Patrón, misDatos$Tarea, misDatos$Informante))
colnames(todo)<- c("Patrón", "Tarea", "Informante", "Frecuencia")
miModelo <- glm(todo$Frecuencia ~ todo$Tarea+ todo$Informante,
                family = poisson)
summary(miModelo)

# NOTA para respuesta nominal, pero predictor numérico (por ejemplo, 
# ver si la altura del pico puede predecir el patrón) y siempre que tengamos dos
# usaríamos la familia binomial y lo haríamso a partir de todo el dataset, y 
# no de la tabla de contingencia
# modelo<-glm(misDatos$Patrón, misDatos$alturaPico, family='binomial')
