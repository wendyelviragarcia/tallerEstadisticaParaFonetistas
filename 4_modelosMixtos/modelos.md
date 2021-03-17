# Análisis de datos numéricos (o variables continuas)

## Antes de empezar
Vamos a usar algunos paquetes de R
Para instalarlos escribid en el terminal de R (la parte de abajo de RStudio).
Los de la primera línea deberían estar instalados del día anterior.
```R
install.packages("dplyr","ggplot2","plyr")
install.packages("multcomp", "car", "nortest")
install.packages("lme4","cAIC")

```
## El contenido de la sesión
1. Cargamos la base de datos csv
2. Visualizamos los datos
3. La regresión: modelos lineales generalizados (lm), efectos fijos
4. Modelos mixtos (lmer) efectos random
5. Evaluación de modelos: residuos y Akaike criterion
6. ¡Quiero mi p! Como conseguir una p de un modelo mixto
7. Post-hocs en lmer: como saber qué grupos son diferentes

## Archivos necesarios
Para seguir la sesión descarga en tu ordenador el [script de R]() y la [base de datos que usaremos](). Son los archivos que están en esta misma carpeta (también puedes seguir los links).

## Información sobre los datos
Seguimos trabajando con los datos que han sido publicados en:

Elvira-García, Wendy y Marrero, Victoria. 2020. [El ritmo y la tasa de habla como ayuda diagnóstica en síndromes neurodegenerativos de los lóbulos fronto-temporales](http://www.doi.org/10.3989/loquens.2020.068). Loquens, 7(1), e068. 10.3989/loquens.2020.068

En este caso vamos a analizar la duración vocálica y consonántica de los grupos de controles y pacientes. ¿Cuán más largas son las consonantes de los pacientes?




## La extracción de esos datos
En esta clase vamos a trabajar con esa base de datos ya preparada en un archivo CSV (comma separated file), pero si queréis conseguir una base de datos igual a partir de vuestros TextGrids, previamente tendríais que usar un script de Praat extraer la duración de cada una de las vocales y consonantes del archivo.

## Cómo aplicar este análisis a otros datos
Este mismo análisis se puede aplicar a otros datos en los que haya varios resultados para cada hablante o fichero. Por ejemplo, para analizar el pico espectral de la [s] de los hablantes (Muñoz y Elvira-García, 2021) o alturas formánticas o alturas de pico de F0 o duraciones en tónica y átona... Solo tenéis que recordar que: 1) el objetivo último es comparar grupos (dialectos, apical/laminal, paciente/control, hombre/mujer, interrogativa/declarativa, tónica/átona); 2) para poder sacar una p necesitas más de un factor fijo, 3) para hacer lmer necesitas factor random (si no, con un lm y la anova de toda la vida estás listo); 4)  los datos tienen que estar en formato largo.


Elemento | Informante (random) | Repetición (random) | Sexo | Grupo | Variable analizada
------------ | ------------- | -------------| -------------| -------------| -------------
pa | Pepita | 1| Mujer|Canarias
pa | Pepita | 2| Mujer|Canarias
pa | Pepita | 3| Mujer| Canarias
te | Pepita | 1| Mujer| Canarias
pa | Juanito | 1| Hombre| Madrid


