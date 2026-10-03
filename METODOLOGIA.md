# Metodología de pruebas de software

**Versión 1.0** - 2 de octubre de 2026 - Diego Vega Cabrera

Este es un documento vivo: está en este repositorio de GitHub y se actualiza aquí. Cada cambio queda guardado como una versión con fecha y autor (ver [Historial de cambios](#historial-de-cambios) y el historial de commits del archivo).

## 1. Para qué sirve

Es la guía para planear, ejecutar y dar seguimiento a las pruebas de una app. Sirve para cualquier proyecto: se cambia el código y se escribe un plan con los mismos pasos. Se aplicó por primera vez a la app iOS **Star Wars Explorer** (ver [sección 9](#9-aplicación-actual)).

## 2. Dónde está

Todo está en GitHub. Cada parte de la metodología tiene un lugar fijo:

| Parte | Dónde está en GitHub | Para qué |
|---|---|---|
| Metodología | Este archivo (`METODOLOGIA.md`) | Reglas y pasos. Cada cambio queda versionado |
| Plan de cada proyecto | Issue con la etiqueta `plan de pruebas` y el documento del plan en el repo | Alcance, criterios y avance del ciclo |
| Casos de prueba | Issues con la etiqueta `caso de prueba` (uno por grupo de pruebas parecidas) | Qué se prueba, qué se espera y qué resultó |
| Incidencias | Issues con la etiqueta `incidencia` | Cada error con su gravedad y evidencia, hasta que se corrige |
| Ciclos | Milestones (`Ciclo 1`, `Ciclo 2`...) | Juntar lo de cada ronda de pruebas |
| Tablero | GitHub Project *Metodología de pruebas* | Ver avance, resultados y orden de corrección |
| Código, resultados y capturas | Carpetas `codigo-fuente/` y `logs/` y PDF de evidencias | Repetir las pruebas y comprobar resultados |

Al crear un Issue, GitHub muestra tres formularios: **Plan de pruebas**, **Caso de prueba** e **Incidencia**. Cada uno pide los datos que exige esta metodología.

## 3. Roles

| Rol | Qué hace |
|---|---|
| Responsable de pruebas | Planea, diseña, ejecuta y registra incidencias |
| Equipo de desarrollo | Corrige las incidencias |
| Profesor o cliente | Revisa el plan y valida los resultados |

Una misma persona puede tener más de un rol.

## 4. Proceso

| Paso | Qué se hace | Qué queda en GitHub |
|---|---|---|
| 1. Planear | Objetivos, alcance, riesgos, recursos y criterios de aceptación | Issue *Plan de pruebas*, milestone del ciclo y documento del plan |
| 2. Diseñar las pruebas | Una o más pruebas por cada requisito, con las técnicas de la sección 5 | Issues *Caso de prueba* con el requisito que revisan |
| 3. Revisar el código | Leer el código buscando errores antes de ejecutar nada | Los errores se registran como incidencias; las observaciones van en el plan |
| 4. Programar las pruebas automáticas | Escribir las pruebas que se pueden repetir solas | Código en el repo |
| 5. Ejecutar | Correr las pruebas y guardar resultados y capturas | Carpeta `logs/`, PDF de evidencias y los campos *Pasan*, *Fallan* y *Bloqueadas* del tablero |
| 6. Registrar incidencias | Cada falla se registra con el formulario *Incidencia* | Issue *Incidencia* ligado a su caso de prueba |
| 7. Cerrar o repetir | Revisar los criterios y decidir si la app se acepta | Resultado en el Issue del plan. Si se rechaza, se abre el siguiente ciclo y se repite desde el paso 5 |

## 5. Escalas

**Tipos de prueba**

| N° | Tipo | Qué es |
|---|---|---|
| 1 | Unitarias | Revisan por separado las reglas del código, sin usar la pantalla |
| 2 | Integración | Revisan que la app reciba bien los datos de los servicios reales |
| 3 | Interfaz automáticas | Un programa usa la app como una persona y toma capturas |
| 4 | Manuales | Una persona sigue los pasos en el simulador o el equipo |

**Técnicas para diseñar las pruebas**

| N° | Técnica | Qué es |
|---|---|---|
| 1 | Grupos de datos | Los datos se dividen en grupos que la app debe tratar igual y se prueba uno de cada grupo |
| 2 | Valores en el límite | Se prueban los valores justo en el borde de lo permitido |
| 3 | Combinaciones | Se prueban combinaciones de condiciones |
| 4 | Recorridos de usuario | Se sigue paso a paso lo que haría una persona |
| 5 | Revisión del código por dentro | Se diseñan pruebas viendo el código para pasar por cada camino |
| 6 | Exploración con objetivo | Se revisa un tema concreto (idioma, mensajes, velocidad, seguridad) con una meta clara |

**Gravedad de las incidencias**

| Nivel | Significado |
|---|---|
| 1 - Crítica | Impide usar una función principal y no hay otra forma de hacerlo |
| 2 - Alta | Una función principal da un resultado incorrecto o hay un riesgo de seguridad |
| 3 - Media | Falla una función secundaria o un error no se maneja, pero se puede seguir usando la app |
| 4 - Baja | Detalles de texto, idioma o presentación |

**Resultado de cada prueba:** Pasa; Falla (se registra una incidencia) o Bloqueada (no se pudo ejecutar por otra incidencia o por el entorno; se anota la razón).

## 6. Criterios de aceptación

Criterios base. Cada plan puede ajustarlos, pero debe escribirlos antes de ejecutar.

| N° | Criterio | Mínimo |
|---|---|---|
| 1 | Incidencias de gravedad 1 o 2 abiertas | 0 |
| 2 | Pruebas ejecutadas que pasan | 90 % o más |
| 3 | Pruebas de prioridad alta que pasan | 100 % |
| 4 | Código cubierto por las pruebas automáticas | 60 % o más |
| 5 | Incidencias de gravedad 3 abiertas | 3 o menos |

Si falla uno, la app se rechaza y regresa al equipo con la lista de incidencias.

## 7. Estados en el tablero

| Elemento | Todo (por hacer) | In Progress (en curso) | Done (terminado) |
|---|---|---|---|
| Plan | - | Mientras dura el ciclo | Cuando se evalúan los criterios; se cierra el Issue |
| Caso de prueba | Diseñado, sin ejecutar | Faltan pruebas por ejecutar | Ejecutado en el ciclo; se cierra el Issue. Se vuelve a abrir en el siguiente ciclo |
| Incidencia | Registrada | Se está corrigiendo | Corregida y comprobada con su prueba; se cierra el Issue |

## 8. Cómo aplicarla a otro proyecto

1. Crear un repositorio nuevo y copiar `METODOLOGIA.md` y la carpeta `.github/` (o usar este repositorio como plantilla).
2. Copiar el Project (menú de tres puntos > **Make a copy**) para tener los mismos campos y vistas.
3. Crear el milestone `Ciclo 1`.
4. Abrir un Issue con el formulario **Plan de pruebas** y llenar objetivos, alcance, riesgos y criterios.
5. Seguir los pasos 2 a 7 de la sección 4. El avance se marca en la lista del Issue del plan.

## 9. Aplicación actual

**Star Wars Explorer - ciclo 1** (septiembre de 2026)

- Documento del plan: [`Plan_de_Pruebas_StarWarsExplorer.pdf`](Plan_de_Pruebas_StarWarsExplorer.pdf)
- Issue del plan: [#34](https://github.com/vg-lz/Trabajo-Intersemestral-CdS/issues/34)
- Casos de prueba: [#19 a #33](https://github.com/vg-lz/Trabajo-Intersemestral-CdS/issues?q=label%3A%22caso+de+prueba%22) (83 pruebas en 15 grupos)
- Incidencias: [#1 a #18](https://github.com/vg-lz/Trabajo-Intersemestral-CdS/issues?q=label%3Aincidencia) (los mismos números que en el plan)
- Resultado: 64 pasan, 15 fallan y 4 bloqueadas. La app se rechaza; el siguiente paso es corregir y abrir el ciclo 2.

## 10. Cómo se mantiene al día

- Se revisa al cerrar cada ciclo. Lo que se aprende se agrega aquí como una nueva versión.
- Cada cambio se guarda con un commit que dice qué cambió.
- Los resultados de cada ciclo se actualizan en los Issues y en el tablero, no en este archivo.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 02-10-2026 | Primera versión, a partir de la sección 11 del plan de Star Wars Explorer | Diego Vega Cabrera |
