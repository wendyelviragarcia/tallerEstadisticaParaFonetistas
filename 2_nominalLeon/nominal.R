# Clase 2 

##########
# Datos nominales
##########


# Leer la base de datos creada previamente
# En este caso leemos desde un archivo excel 
# lo vamos a hacer mediante interfaz, después copiamos el código para tenerlo para siempre
library(readxl)
misDatos <- read_excel("base_datos_leon.xlsx")

misDatos$Informante <- as.factor(misDatos$Informante)
misDatos$Tarea <- as.factor(misDatos$Tarea)
misDatos$Archivo <- as.factor(misDatos$Archivo)
misDatos$Patrón <- as.factor(misDatos$Patrón)

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
theme = theme_set(theme_minimal())

ggplot(data=data, aes(x=Tarea, y=Frecuencia, fill=Patrón)) + 
  #facet_grid(data$Tarea)+
  geom_bar(position="fill", stat="identity")+
  scale_fill_manual("Patrón", values = c("¡H* LH%" = "black", "¡H* L%" = "orange"))+
  labs(title="Ocurrencias de patrones por tarea", x="", y="Esto es la frecuencia", fill="Estos son los patrones")

# otras opciones de position, ¡probadlas!
# position="dodge"
# position="stack"
# position="fill"




##########
# Estadística para datos nonminales
##########

#descriptivos
min(data$Frecuencia)
max(data$Frecuencia)
mean(data$Frecuencia)
#un resumen de los descriptivos más habituales
summary(data$Frecuencia)
