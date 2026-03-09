#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Grado en Ingeniería Informática",
  subject: "Procesadores del Lenguaje",
  year: (25, 26),
  project: "Parser Descendente Recursivo",
  title: "Entrega 1",
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
Axioma      ::= Expresion Fin 
Expresion   ::= ( operador Parametro Parametro ) 
              | numero
Parametro   ::= Expresion 
Fin ::= \n
`
Como se puede ver, hemos decidido seguir de manera literal las especificaciones del enunciado y traducirlas directamente a la gramática. No obstante, la gramática presentada no es la primera que hemos desarrollado, pues antes de ella, se planteó otra version en la que el axioma se definía como `Axioma ::= Expresion \n` , describiendo directamente el no terminal de finalización de la sentecia. Sin embargo, esta versión producía errores al realizar la verificación de gramática LL(1). 

En la siguiente imagen, se presentan los resultados de dicha verificación con la gramática inicial presentada con anterioridad:
#image("img/verif1.png", width: 100%) 

Tras la realización de dicha gramática, hemos planteado los cambios necesarios en la misma de modo que la gramática reconozca también el uso de variables. Notesé, que por la definición del parser que se presenta en _drLL.c_ el nombre dado a las variables se entiende como un token, por lo que no se debe gestionar directamente desde la gramática. 

De este modo, añadimos reglas que nos permitan realizar asignaciones de variables para que estas puedan tomar valores. Para ello, hemos añadido un nuevo no terminal llamado ExpresionesResto, que define aquellas expresiones que no son un solo número o una sola variable. Así, se define ExpresionResto o bien como cualquier operación entre dos parámetros o bien como cualquier asignación de un parámetro a una variable. Por consecuente, resulta la siguiente gramática también LL(1): 

`
Axioma          ::= Expresion Fin 
Expresion       ::= ( ExpresionResto ) 
                  | numero 
                  | variable
ExpresionResto  ::= operador Parametro Parametro 
                  | = variable Parametro
Parametro       ::= Expresion
Fin             ::= \n
`

En la siguiente imagen, se puede ver la verificación de esta gramática con JFLAP, lo que garantiza que la ampliación incremental de la gramática no ha afectado a los requisitos de tipo establecidos para la misma, garantizando que es adecuada para un Parser Descendente. 

#image("img/verif2.png", width: 100%) 

Una vez hemos finalizado el uso de variables en nuestra gramática, hemos continuado con las expecificaciones extendidas que se incluyen en el enunciado de la práctica. De este modo, hemos modificado la gramática de modo que permita el uso de asignaciones ternarias y de operadores condicionales ternarios. 

Para ello, hemos añadido dos asigaciones nuevas a la definción de ExpresionResto. La primera de ellas que amplia las asignaciones para permitir asignaciones ternarias, permitiendo que una variable pueda tomar el valor de la comparación de dos parámetros o solo de una expresión, haciendo que Ternario pueda ser nada u otros dos parámetros. La segunda, que define los condicionales, introducidos por el operador ? y seguidos por tres expresiones, dos que se comparan y una que se devuelve. 

`
Axioma          ::= Expresion Fin
Expresion       ::= ( ExpresionResto )
                  | numero
                  | variable
ExpresionResto  ::= operador Parametro Parametro
                  | = variable Parametro Ternario
                  | ? Expresion Expresion Expresion
Parametro       ::= Expresion
Ternario        ::= Parametro Parametro 
                  | λ
Fin             ::= \n
`

En la siguiente imagen, se muestra el resultado de la comprobación realizada con JFLAP para esta última versión y que garantiza que la gramática sigue siendo LL(1) con este incremento: 
#image("img/verif3.png", width: 100%)

Por último, hemos eliminado el no terminal Parametro, ya que simplemente realiza una reasignación del no terminal Expresión, por lo que no era útil en este caso ni nos ayudaba a eliminar problemas o ambigüedades en la gramática. De este modo, la gramática final resultante es la siguiente: 

`
Axioma          ::= Expresion Fin
Expresion       ::= ( ExpresionResto )
                  | numero
                  | variable
ExpresionResto  ::= operador Expresion Expresion
                  | = variable Expresion Ternario
                  | ? Expresion Expresion Expresion
Ternario        ::= Expresion Expresion 
                  | λ
Fin             ::= \n
`

Que también cumple con todos los requisitos y especificaciones mencionadas en el enunciado de la práctica y que sigue siendo una gramática LL(1) como se muestra en la siguiente imagen:
#image("img/verif4.png", width: 100%)

= Desarrollo del Parser

Para continuar con el desarrollo de la práctica, hemos modificado y adaptado el código del fichero _ddLR.c_ para que se ajuste a la gramática que hemos diseñado con anterioridad. 

En primer lugar, hemos generado las funciones parse que corresponden a cada uno de los no terminales de la gramática. A continuación, especificaremos el desarrollo de cada una de las mismas:
- *ParseAxioma()*: En esta función, hemos añadido una llamada a la función ParseExpresion() para que se realice el proceso de análisis sintáctico de la expresión y concuerde exactamente con la regla de derivación Axioma ::= Expresion Fin , que hemos definido con anterioridad. Además hemos incluido la verificación del token final de salto de linea, pues es el funcionamiento que se pide en la práctica. 
- *ParseExpresion()*: Esta función resulta algo más compleja que la anterior, pues debe tratar varias relgas de derivación que definen las diferentes posibles maneras de definir una expresión. Por ello, hemos estructurado un if que comprueba el primer token leido. En el caso de que se corresponda con un número o variable, asegura que estos se corresponden con los tokens que definen números y variables llamando a las funciones MatchSymbol() correspondientes. Por otro lado, se compueba si el token leido es un paréntesis de apertura, en cuyo caso debemos llamar a la función ParseExpresionResto() y posteriormente comprobamos el paréntesis de cierre. 
- *ParseExpresionResto()*: El funcionamiento de esta función es muy similar al definido en el caso anterior. Hemos comprobado el primer token leido de modo que, partiendo de su valor, decidimos cual de las reglas de derivación se corresponden con la expresión, llamando en cada una a las funciones Parse que corresponden a los no terminales de las reglas. 
- *ParseTernario()*: En dicha función, comprobamos si hay algún caracter por leer que se corresponda con el inicio de una expresión. En caso afirmativo, procedemos con la llamada a las funciones de Parse de Expresión, no obstante, al también generar lambda, si no se da el inicio de una expresión, simplemente no se hará nada, de modo que se representa regla de derivación ExpresionResto ::= λ.
- *ParseOperador()*: En esta función, simplemente se comprueba que el token leido se corresponda con alguno de los operadores definidos en la gramática, llamando a la función MatchSymbol() para cada uno de ellos.

