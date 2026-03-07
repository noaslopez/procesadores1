#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Grado en Ingeniería Informática",
  subject: "Procesadores del Lenguaje",
  year: (25, 26),
  project: "Parser Descendente Recursivo",
  title: "Entrega 1.1",
  group: 81,
  team: 116,
  authors: (
    (
      name: "Noa",
      surname: "López Fernández",
      nia: 100522230
    ),
    (
      name: "Guillermo",
      surname: "González Avilés",
      nia: 100522146
    ),
  ),
  professor: none,
  toc: true,
  logo: "old",
  language: "es"
)

= Diseño de gramática LL(1)
En este apartado, explicaremos de manera extendida el desarrollo de la gramática LL(1) que nos ha permitido representar la sintaxis de expresiones aritméticas en forma prefija. Pues este, es el primer paso para la realización de la entrega, ya que el objetivo prinicpal de la misma es la traducción desde esta forma a forma infija. 

En primer lugar, partimos de las especificaciones iniciales presentadas en el enunciado, generando una gramática inicial que aún no reconoce variables y con expresiones aritméticas con paréntesis. 
En este caso, la gramática inicial que hemos generado es la siguiente:
`
Axioma ::= Expresion Fin 
Expresion ::= ( Operador Parametro Parametro ) | Numero
Parametro ::= Expresion 
Operador ::= + | - |_* | /
Numero ::= 0 | 1 | ... | 9
Fin ::= \n
`
Como se puede ver, hemos decidido seguir de manera literal las especificaciones del enunciado y traducirlas directamente a la gramática. No obstante, la gramática presentada no es la primera que hemos desarrollado, pues antes de ella, se planteó otra version en la que el axioma se definía como `Axioma ::= Expresion \n` , describiendo directamente el no terminal de finalización de la sentecia. Sin embargo, esta versión producía errores al realizar la verificación de gramática LL(1). 

En la siguiente imagen, se presentan los resultados de dicha verificación con la gramática inicial presentada con anterioridad:
#image("img/verif1.png", width: 100%) 

Tras la realización de dicha gramática, hemos planteado los cambios necesarios en la misma de modo que la gramática reconozca también el uso de variables. En primer lugar, modificamos la gramática de modo que esta permita variables de una sola letra mayúscula. Por consecuente, resulta la siguiente gramática también LL(1): 

`
Axioma ::= Expresion Fin 
Expresion ::= ( Operador Parametro Parametro ) | Numero | Variable
Parametro ::= Expresion
Operador ::= + | - |_* | /
Numero ::= 0 | 1 | ... | 9
Variable ::=  Letra 
Letra ::= A | B | ... | Z
Fin ::= \n
`





-----------------------------------


`
Axioma ::= Expresion Fin 
Expresion ::= ( Operador Parametro Parametro ) | Numero | Variable
Parametro ::= Expresion
Operador ::= + | - |_* | /
Numero ::= 0 | 1 | ... | 9
Variable ::=  Letra RestoVariable
RestoVariable ::= Letra | Numero
Letra ::= A | B | ... | Z
Fin ::= \n
`
