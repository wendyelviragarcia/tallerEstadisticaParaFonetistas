# Clase 2 

##########
# Datos nominales
##########


# Leer la base de datos creada previamente
# En este caso leemos desde un archivo excel 
# lo vamos a hacer mediante interfaz, después copiamos el código para tenerlo para siempre
library(readxl)
misDatos <- read_excel("/Users/weg/OneDrive - UNED/git-me/tallerEstadisticaParaFonetistas/2_nominalLeon/base_datos_leon.xlsx")

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
data <- table(misDatos$Patrón, misDatos$Tarea)
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

ggplot(data=data, aes(x=Tarea, y=Frecuencia, fill=Patrón)) + 
  #facet_grid(data$Tarea)+
  geom_bar(position="fill", stat="identity")+
  scale_fill_manual("Patrón", values = c("¡H* LH%" = "black", "¡H* L%" = "orange"))+
  labs(title="Ocurrencias de patrones por tarea", x="", y="Esto es la frecuencia", fill="Estos son los patrones")

# otras opciones de position, ¡probadlas!
# position="dodge"
# position="stack"
# position="fill"

# Vamos a cambiar la etiqueta de patrón para que sea más entendible
library(plyr)
data$Patrón<- revalue(data$Patrón, c("¡H* LH%"="Híbrido", "¡H* L%"="Tradicional"))



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

# Teoría de la estadística. El test Chi solo se puede usar cuando ningún valor esperado es >5
# Es decir ¡tenemos muy pocos datos para hacer eso! (Una celda tiene un valor de 0)
# ¡Vamos a cambiar de test!

fisher.test(table(misDatos$Patrón, misDatos$Tarea))

# Ahora sabemos que algo es estadísticamente diferente, pero... ¿qué? Quizá es solo el 
# maptask y eso ya lo vemos a ojímetro
# Operadores lógicos Y & O |
leidoContraInducido <- filter(misDatos, Tarea == "Inducido" | Tarea == "Lectura" )
fisher.test(table(leidoContraInducido$Patrón, leidoContraInducido$Tarea))
