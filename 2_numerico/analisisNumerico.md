# Análisis de datos nominales

## Antes de empezar
Vamos a usar algunos paquetes de R
Para instalarlos escribid en el terminal de R (la parte de abajo de RStudio)
```R
install.packages("dplyr","ggplot2","plyr")
```
## El contenido de la sesión
1. Cargar una base de datos en formato csv
2. Variables factor: importancia y conversión de char a factor
3. Descriptivos
4. Gráficos de cajas y bigotes (crear y guardar)
5. Estadística inferencial para datos numéricos (comprobación de la normalidad, anova y Mann-whitney y post-hocs)

## Los datos
Vamos a trabajar con datos de ritmo que han sido publicados en:

Elvira-García, Wendy y Marrero, Victoria. 2020. [El ritmo y la tasa de habla como ayuda diagnóstica en síndromes neurodegenerativos de los lóbulos fronto-temporales](http://www.doi.org/10.3989/loquens.2020.068). Loquens, 7(1), e068. 10.3989/loquens.2020.068

Los datos tienen esta pinta:

id | Diagnóstico | TasaDeHabla
------------ | ------------- | -------------
1 | Control | 0.015
2 | Control | 0.018
3 | APP_sem | 0.013
4 | APP_log | 0.010
5 | ELA | 0.006

## La extracción de esos datos
En esta clase vamos a trabajar con esa base de datos ya preparada en un archivo CSV (comma separated file), pero si queréis conseguir una base de datos igual a partir de vuestros TextGrids, previamente tendríais que usar un script de Praat calcular la tasa de habla y/o diferentes métricas de ritmo de vuestros archivos. También, si tenéis vuestros TextGrids preparados podriáis usar esto: 
 * [Web-app de shiny para calcular parámetros de ritmo]( https://wendyelvira.shinyapps.io/ritmo/)

## Cómo aplicar este análisis a otros datos
Por supuesto este mismo análisis se puede aplicar a otros datos en los que haya un resultado para cada hablante o fichero. Por ejemplo, el rango de F0 de la tónica en un momento determinado. La duración de las sílabas, etc...


## Algunos resultados esperables para abrir boca
![image](../figuras/speechRate.png)

