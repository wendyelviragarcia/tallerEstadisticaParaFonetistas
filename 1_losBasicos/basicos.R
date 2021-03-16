# Clase 1

##########
# Básicos
##########

# Todo lo que tiene asterisco delante es información para nosotros
# R no lo lee

# abajo, hacemos cosas, aquí las anotamos para después poderlas repetir
# el panel lateral nos recuerda lo que estamos haciendo

# vamos a verlo

# escribe abajo
2+2
# y dale a intro
# qué ha pasado?

# escribe abajo
a <- 2+2 
# dale a intro 

#ahora escribe a y dale a intro
# qué ha pasado?

# Mira el lateral
# qué ves?

#vamos a borrarlo 
rm(a)

# escribe abajo
a = 2+2
# dale a intro 
# qué ha pasado?

# = y <- son sinónimos, los puristas aconsejan <- a mí muchas veces me
# es más rápido escribir =

# Ahora escribe 
b <- "hola"
#mira en la barra lateral la diferencia entre a y b

# prueba a escribir 
b<- hola
# qué ha pasado?

# c() crea "arrays" pueden ser de números o elementos con letras
c<- c(14, 15, 10)
c[1]
c[2]

min(c)
mean(c)
max(c)
length(c)

# list() crea listas pueden ser números o letras
d<- list("hola", "hola2", "hola3")
d[1]
d[[1]]

# Pero lo más importante en R son los dataframes
misDatos <- data.frame("Sexo" = c("Hombre","Mujer"), "PatronesAscendentes" = c(150,120), "PatronesDescendentes" = c(150,180))
misDatos <- data.frame("Nombre" = c("Mario", "María"), "Sexo" = c("Hombre","Mujer"), "F0" = c(90,240))

misDatos
#misDatos[fila,columna]
misDatos[1,1]
misDatos[1,2]

misDatos$Nombre
misDatos$Nombre[1]


# Ahora míralo en el lateral, dale a la flechita, has visto que pone
# ch num. Eso es muy importante, porque dependiendo de eso
# el programa nos dejará hacer unas cosas u otras
as.character(misDatos$F0)
as.factor(misDatos$F0)
as.numeric(misDatos$F0)

#Obviamente, no vamos a crear una base de datos con miles de datos así.

# Así que, ¡vamos con datos de verdad!
