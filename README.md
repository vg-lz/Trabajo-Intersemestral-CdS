# Star Wars Explorer - Pruebas de software

Proyecto de la materia **Calidad y Pruebas de Software**: metodología, plan, ejecución y resultados de las pruebas de la app iOS *Star Wars Explorer*.

| Contenido | Qué es |
|---|---|
| [`METODOLOGIA.md`](METODOLOGIA.md) | Metodología de pruebas (documento vivo) y cómo aplicarla a otro proyecto |
| `Plan_de_Pruebas_StarWarsExplorer.pdf` | Plan de pruebas de la app: casos, resultados, incidencias, revisión del código y metodología |
| `Evidencias_StarWarsExplorer.pdf` | Capturas de las pruebas, una por página (el índice está en el anexo del plan) |
| `codigo-fuente/` | Código de la app y de las pruebas automáticas (proyecto de Xcode) |
| `logs/` | Resultados y errores de cada ejecución de pruebas |
| `.github/ISSUE_TEMPLATE/` | Formularios para crear planes, casos de prueba e incidencias |

## Seguimiento

- [Issues](https://github.com/vg-lz/Trabajo-Intersemestral-CdS/issues): plan del ciclo 1 (#34), casos de prueba (#19 a #33) e incidencias (#1 a #18).
- Tablero: pestaña **Projects** de este repositorio (*Metodología de pruebas - Star Wars Explorer*).

## Resultado del ciclo 1

83 pruebas: 64 pasan, 15 fallan y 4 quedaron bloqueadas. Se registraron 18 incidencias; la app se rechaza hasta corregir las más graves (#17, #1, #18 y #6).

## Para correr las pruebas

Abrir `codigo-fuente/HelloWorld.xcodeproj` con Xcode 27, elegir un simulador de iPhone con iOS 27 y usar *Product > Test*. Los resultados se guardan en `logs/`.
