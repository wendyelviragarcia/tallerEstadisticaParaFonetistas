# Taller de estadística para fonetistas
Taller sobre [estadística con R ofrecido en la Universidad de La Laguna](https://eventos.ull.es/53843/detail/traduccion-y-estadistica-aplicada-a-la-investigacion-linguistica.html). (marzo, 2021)

La idea de este curso es realizar un trabajo que emule el trabajo que hace en R un investigador para escribir un paper desde cargar la base de datos, hacer los análisis estadísticos, crear las figuras y reportar los resultados.

## Organización
En cada carpeta encontrarás un resumen de lo que contiene la sesión (archivo .md, clica en él para poder leerlo en línea), un script de R con el análisis que vamos a acometer y la base de datos que usaremos para hacerlo (algunas son csv y otras archivos de Excel para que veáis como importar diferentes archivos).

## Sesiones

0. [Instalación de R+Rstudio](0_antesDeClase/InstruccionesInstalacion.md)
1. [Los básicos: Funciones y variables](1_losBasicos/basicos.md)
* Uso de la consola
* Tipos de variable
* Creación de dataframes
2. [Análisis de datos numéricos](2_numéricos)
* Estadística descriptiva: medias, medianas, curtosis, asimetría…
* Gráficos de cajas y bigotes
* ¡Quiero una p! Estadística inferencial I datos numéricos (F0, duración, intensidad...): pruebas de normalidad, tests 

3. [Análisis de datos nominales](3_nominalLeon)
* Frecuencias y tablas de contingencia
* Gráficos de barras
* ¡Quiero una p! Estadística inferencial para datos nominales (transcripciones fonológicas de la entonación): chi square y test exacto de Fisher
4. [Modelos mixtos generalizados](4_modelosMixtos)
* Modelos lineales (lm)
-efectos fijos (sexo, variedad)
* Modelos mixtos (lmer, glmer)
- efectos aleatorios (sujeto, repetición/ítem)

## Bibliografía
La única bibliografía del curso es este material, pero si te interesa el tema y quieres profundizar, aquí tienes algunas referencias.
### Para lingüistas en R (especialmente para fonetistas)
 * Winter, B. 2013. [A very basic tutorial for performing linear mixed effects analyses](http://www.bodowinter.com/uploads/1/2/9/3/129362560/bw_lme_tutorial2.pdf). arXiv preprint arXiv:1308.5499.
 * Winter, B. 2019. Statistics for linguists: An introduction using R. Routledge.
### Para lingüistas en Python (especialmente para procesamiento del lenguaje natural)
 * Martín-Fuertes Moreno, Leticia. 2020. [Introducción a la programación para humanistas](https://github.com/nimbusaeta/lingufriendly#nomenclatura-de-los-temas-y-ejercicios)
 * Casado Mancebo, Mario. 2021. [Curso de iniciación en Python](https://cursos.mcasado.org/cursos/curso-de-iniciación-en-python/)
### Para investigadores en general
 *  Maurandi, Antonio; Del Rio, Laura; Balsalobre Rodríguez, Carlos. 2013. [Fundamentos estadísticos para investigación. Introducción a R](https://gauss.inf.um.es/files/Fundamentos-estadisticos-para-investigacionIntroduccion-a-R.pdf)
