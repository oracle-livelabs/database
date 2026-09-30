# Soluciones financieras con Oracle AI Database 26ai

## Introducción

Jessica Chan es la administradora de la base de datos de Seer Bank. Sus equipos están creando nuevas aplicaciones para clientes, mejorando las revisiones de riesgos y fraudes, asignando el trabajo de servicio y añadiendo IA a los paneles financieros.

Las solicitudes son distintas, pero comparten un problema. Los datos ya están en Oracle AI Database y cada equipo quiere utilizarlos de una manera diferente:

- Thomas necesita las transacciones de los clientes como JSON para una aplicación web y móvil.
- Gilly necesita una búsqueda semántica que encuentre productos por significado, no solo por coincidencia de palabras.
- Bob necesita seguir las relaciones entre cuentas y otras entidades para investigar fraudes.
- Moon necesita calcular distancias entre clientes, centros de servicio y regiones con demanda.
- Otto necesita entrenar y puntuar un modelo de demanda de productos.
- Nina necesita hacer preguntas financieras en lenguaje natural y convertir las respuestas en una revisión útil.

El trabajo de Jessica es ayudar a cada equipo a cumplir sus requisitos sin crear otra copia de los datos ni un modelo de seguridad separado para cada función. Utiliza Oracle AI Database como base común: las tablas relacionales siguen siendo la fuente de los registros financieros, mientras que JSON, los vectores, los grafos, los datos espaciales, el aprendizaje automático y los servicios de IA trabajan con esos mismos registros.

Este taller sigue a Jessica y a sus colegas mientras resuelven estos problemas. Cada laboratorio se centra en un requisito de negocio, pero la base de datos sigue siendo el elemento común. Verá cómo los equipos utilizan juntos distintos tipos de datos y capacidades de la base de datos, y cómo Jessica mantiene visibles el acceso, el SQL y los resultados.

### Lo que crea el equipo

| Miembro del equipo | Requisito | Lo que verá |
| --- | --- | --- |
| Jessica, administradora de la base de datos | Crear la consulta detrás de un panel de riesgos y operaciones. | Un resultado SQL combina datos relacionales de riesgo, coincidencias semánticas de productos, datos de transacciones JSON y datos de ubicación. |
| Thomas, desarrollador de aplicaciones | Proporcionar documentos de transacciones flexibles a la aplicación. | Las columnas JSON, las colecciones JSON y las vistas JSON Relational Duality ofrecen distintas formas de servir los datos de la aplicación. |
| Gilly, ingeniera de IA | Encontrar productos relacionados con una pregunta de riesgo. | Jessica carga un modelo de embeddings ONNX en la base de datos y Gilly crea los vectores donde ya están los datos de los productos. |
| Bob, especialista en grafos | Encontrar cuentas y entidades conectadas en una investigación de fraude. | Un grafo de propiedades utiliza los datos relacionales existentes para mostrar rutas que serían difíciles de gestionar con muchos JOIN de SQL. |
| Moon, especialista espacial | Asignar trabajo usando las ubicaciones de centros de servicio y regiones. | La base de datos calcula distancias a partir de datos geográficos que la aplicación también puede mostrar. |
| Otto, científico de datos | Identificar productos que podrían sufrir un aumento de demanda. | Oracle Machine Learning entrena y puntúa un modelo dentro de la base de datos, cerca de los datos de productos y actividad. |
| Nina, analista de riesgos | Hacer preguntas financieras sin escribir cada consulta desde cero. | Select AI genera SQL que Nina puede inspeccionar, ejecutar y mejorar. Select AI Agent añade una herramienta SQL restringida y registra la actividad del agente. |

La idea no es utilizar todas las capacidades en cada consulta. La idea es que Jessica no tenga que mover los datos a otra base de datos cada vez que cambia un requisito. Los mismos registros financieros pueden servir para un payload de aplicación, una búsqueda vectorial, una investigación con grafos, un cálculo espacial, una puntuación de modelo o una pregunta en lenguaje natural.

<details>
<summary><strong>Más información: ¿Qué significa "base de datos convergente"?</strong></summary>

> Una base de datos convergente admite distintos tipos de datos y cargas de trabajo sobre una misma base. En este taller incluye filas relacionales, documentos JSON, vectores, grafos, datos geográficos, modelos de aprendizaje automático y SQL asistido por IA.
>
> La ventaja es práctica. Los equipos pueden utilizar los datos en la forma que necesita su aplicación o análisis y mantener conectados los registros, los privilegios y el acceso SQL. No necesitan copiar los datos financieros en un almacén de documentos, un servicio vectorial, una base de grafos, un sistema cartográfico ni un servicio de puntuación separado para cada requisito.

</details>


### Objetivos

- Seguir a Jessica y a su equipo mientras resuelven distintos requisitos de aplicaciones y análisis financieros.
- Utilizar SQL relacional, JSON, vectores, grafos, datos espaciales, Oracle Machine Learning, Select AI y Select AI Agent en tareas prácticas.
- Ver cómo una sola instancia de Oracle AI Database puede admitir distintos tipos de datos sin crear copias separadas de los registros financieros.
- Entender cómo los privilegios de la base de datos, los perfiles de IA restringidos, las herramientas aprobadas y el historial de ejecución mantienen visible y controlado el trabajo asistido por IA.
- Relacionar el trabajo de la base de datos con la demostración de cara al cliente Seer Bank Finance LiveStack.

Tiempo estimado del taller: **110 minutos**

### Escenario de negocio

| Paso | Enfoque financiero |
| --- | --- |
| Problema de negocio | Seer Bank necesita nuevas funciones para sus aplicaciones y decisiones más rápidas sobre riesgos, fraudes, servicio y planificación a partir de los mismos datos financieros. |
| Desafío técnico | Cada equipo necesita un tipo de datos o una carga de trabajo diferente, pero separar los almacenes añadiría copias, integración y reglas de seguridad. |
| Enfoque de las personas | Jessica trabaja con Thomas, Gilly, Bob, Moon, Otto y Nina para entregar las capacidades necesarias desde una sola base de datos. |
| Lo que verá | Los datos relacionales trabajan con JSON, vectores, grafos, datos espaciales, aprendizaje automático y SQL asistido por IA. |
| Capacidad de la base de datos | Oracle AI Database 26ai proporciona la base común para datos, SQL, seguridad, IA y aplicaciones. |
| Resultado | Seer Bank puede crear y revisar funciones financieras sin mover cada nuevo requisito a otro sistema de datos. |

## Agradecimientos

* **Autor** - Pat Shepherd, Senior Principal Database Product Manager
* **Colaborador** - Linda Foinding, Principal Database Product Manager
* **Última actualización por/fecha** - Oracle Database Product Management, agosto de 2026
