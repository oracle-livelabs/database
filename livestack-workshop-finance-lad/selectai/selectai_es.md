# Haz preguntas financieras con Select AI

## Introducción

Nina Patel es analista de riesgos en Seer Bank. Sabe qué preguntas de negocio quiere hacer, pero no quiere que cada respuesta dependa de encontrar primero la tabla, la columna, la unión y el filtro correctos.

Jessica, la DBA, ya configuró un perfil de Select AI para el esquema financiero. Nina puede hacer preguntas en lenguaje natural. Select AI usa el perfil y los metadatos de la base de datos para generar SQL, ejecutarlo o explicar el resultado.

Nina aún debe revisar el SQL generado: el modelo puede interpretar mal una pregunta o elegir columnas incorrectas. El método es sencillo: hacer una pregunta, revisar el SQL, ejecutarlo solo cuando tenga sentido y reformular la pregunta si el resultado no contiene lo que necesita el usuario de negocio.

En este laboratorio comprobarás el perfil disponible, harás una pregunta financiera, revisarás el SQL y mejorarás la pregunta para obtener un resultado útil.

<details>
<summary><strong>Términos clave: Select AI, perfil de IA, SQL generado y prompt en lenguaje natural</strong></summary>

> - **Select AI** permite trabajar con información de la base de datos mediante una pregunta en lenguaje natural.
> - Un **perfil de IA** conecta Select AI con un proveedor de IA e identifica los objetos que se pueden usar.
> - El **SQL generado** es la sentencia creada a partir de la pregunta. Nina debe revisarlo antes de confiar en el resultado.
> - Un **prompt en lenguaje natural** es la pregunta enviada a Select AI, como `Which five products have the highest revenue?`

</details>

### Objetivos

- Comprobar qué perfil de Select AI está disponible.
- Añadir al perfil las tablas financieras que Select AI puede utilizar.
- Generar SQL a partir de una pregunta y revisarlo.
- Ejecutar una pregunta mediante `DBMS_CLOUD_AI.GENERATE`.
- Mejorar una pregunta para que incluya los detalles que Nina necesita.
- Explicar por qué el SQL generado requiere revisión.

Tiempo estimado: **10 minutos**

### Escenario práctico

| Paso | Enfoque financiero |
| --- | --- |
| Problema de negocio | Nina necesita respuestas de los datos financieros sin escribir cada consulta desde cero. |
| Reto técnico | La pregunta debe convertirse en SQL contra el esquema financiero controlado. |
| Enfoque de la persona | Acompañarás a Nina mientras comprueba, revisa y mejora una pregunta de Select AI. |
| Lo que verás | Una pregunta en lenguaje natural se convierte en SQL que se puede revisar y ejecutar. |
| Capacidad de la base de datos | Select AI, `DBMS_CLOUD_AI`, perfiles de IA y generación de lenguaje natural a SQL. |
| Resultado | Nina obtiene una forma repetible de hacer preguntas financieras manteniendo la revisión del SQL. |

> **Recordatorio de SQL Worksheet:** ¿Necesitas recordar cómo abrirlo y usarlo? Vuelve a [Tarea 2 de Primeros pasos: abrir SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) para consultar la guía paso a paso.

## Tarea 1: Comprobar el perfil de Select AI

Select AI usa un perfil para identificar el proveedor de IA y los objetos disponibles. La base de datos del taller debe contener un perfil para el esquema `LLUSER`.

1. Ejecuta esta consulta:

    ```sql
    <copy>
    SELECT profile_name,
           status,
           description
    FROM user_cloud_ai_profiles
    ORDER BY profile_name;
    </copy>
    ```

    Se espera que el perfil se llame `GENAI`. Confirma que está habilitado. Si aparece otro nombre, úsalo en las tareas siguientes.

2. Revisa sus atributos:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    ORDER BY profile_name, attribute_name;
    </copy>
    ```

    Los atributos muestran cómo está configurado el perfil y qué objetos están disponibles. No copies credenciales. En la Tarea 2 solo cambiarás `object_list`.

## Tarea 2: Añadir las tablas financieras al perfil

El perfil necesita una lista de tablas que Select AI puede usar. Las preguntas de Nina requieren productos, pedidos, líneas de pedido y clientes, por lo que Jessica añade esas cuatro tablas al perfil `GENAI`.

1. Añade las tablas:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name    => 'genai',
        attribute_name  => 'object_list',
        attribute_value => '[{"owner": "' || USER || '", "name": "PRODUCTS"}, {"owner": "' || USER || '", "name": "ORDERS"}, {"owner": "' || USER || '", "name": "ORDER_ITEMS"}, {"owner": "' || USER || '", "name": "CUSTOMERS"}]'
      );
    END;
    /
    </copy>
    ```

2. Confirma la lista:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'GENAI'
      AND attribute_name = 'object_list';
    </copy>
    ```

    El resultado debe listar `PRODUCTS`, `ORDERS`, `ORDER_ITEMS` y `CUSTOMERS`. Select AI ya puede usar esas tablas al convertir las preguntas de Nina en SQL.
  
    ![task2](images/task2.png)

## Tarea 3: Hacer una pregunta y revisar el SQL

Nina empieza con una pregunta sencilla: ¿qué productos tienen los ingresos más altos? Primero pide a Select AI que muestre el SQL sin ejecutarlo.

Database Actions no admite la palabra clave `SELECT AI`. En SQL Worksheet usa `DBMS_CLOUD_AI.GENERATE` y proporciona el nombre del perfil.

1. Ejecuta la pregunta con `GENAI`:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five products have the highest revenue?',
             profile_name => 'genai',
             action       => 'showsql'
           ) AS generated_sql;
    </copy>
    ```
  
    ![task 3](images/task3.png)

2. Lee el SQL antes de ejecutarlo.

    Comprueba que usa los datos esperados de productos y ventas, devuelve cinco filas y calcula los ingresos de forma razonable. Select AI puede generar una sentencia válida que no responda exactamente a la pregunta, así que el SQL forma parte de la revisión de Nina.

## Tarea 4: Ejecutar la pregunta en la base de datos

Nina ya revisó el SQL. Ahora pide a Select AI que ejecute la pregunta y devuelva el resultado.

1. Ejecuta la misma pregunta con `runsql`:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five products have the highest revenue?',
             profile_name => 'genai',
             action       => 'runsql'
           ) AS answer;
    </copy>
      ```
  
    ![task 4](images/task4.png)

2. Compara la respuesta con el SQL de la Tarea 3.

    Select AI generó y ejecutó SQL contra el esquema financiero. La consulta sigue usando los privilegios de base de datos de Nina y el resultado procede de las tablas, no de una copia separada.

    > **Nota:** Select AI puede generar SQL incorrecto o interpretar mal una pregunta. Usa `showsql` cuando la consulta exacta sea importante y trata la respuesta como un punto de partida para la revisión.

## Tarea 5: Mejorar la pregunta de negocio

La primera pregunta produce una clasificación de productos, pero Nina también necesita detalles para decidir qué revisar. Cambia la pregunta para solicitar la categoría, los ingresos totales y las unidades vendidas.

1. Usa `showsql` para revisar el prompt modificado:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five products with the highest revenue. Include the product name, category, total revenue, and units sold.',
             profile_name => 'genai',
             action       => 'showsql'
           ) AS generated_sql;
    </copy>
    ```
  
    ![task5](images/task5.png)

2. Revisa el SQL generado y ejecuta la pregunta con `runsql`:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five products with the highest revenue. Include the product name, category, total revenue, and units sold.',
             profile_name => 'genai',
             action       => 'runsql'
           ) AS answer;
    </copy>
    ```
  
    ![task5](images/task52.png)

3. Compara las dos preguntas.

  La segunda da a Nina un resultado que puede llevar a una reunión de revisión. El usuario de negocio no necesitó conocer los nombres de tablas ni escribir las uniones, pero Nina revisó el SQL e indicó las columnas que necesitaba.

## Tarea 6: Explicar el resultado

Nina quiere una explicación breve del resultado modificado. Select AI puede ejecutar el SQL y pedir al proveedor de IA que describa las filas devueltas.

1. Ejecuta la pregunta con `narrate`:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five products with the highest revenue. Include the product name, category, total revenue, and units sold.',
             profile_name => 'genai',
             action       => 'narrate'
           ) AS explanation;
    </copy>
    ```
  
    ![task6](images/task6.png)

2. Compara la explicación con el resultado SQL.

  La explicación ayuda al usuario de negocio, pero el resultado SQL sigue siendo el registro que Nina puede inspeccionar, repetir y usar para comprobar si la explicación es correcta.

  > **Nota:** `narrate` envía el resultado de la consulta al proveedor de IA configurado en el perfil. Úsalo solo con datos aprobados para ese proveedor.

## Conclusión: Preguntar, revisar y mejorar

Nina convirtió una pregunta financiera en SQL, revisó la sentencia, la ejecutó en Oracle AI Database y mejoró la pregunta cuando el primer resultado no contenía los detalles necesarios. Select AI reduce el SQL que debe escribir un usuario de negocio, mientras que la revisión mantiene visible la operación de la base de datos.

Este es el valor práctico de Select AI en Oracle AI Database. La pregunta, el SQL generado y el resultado siguen vinculados al esquema financiero controlado. Nina puede preguntar en lenguaje normal sin perder los controles de acceso ni la posibilidad de revisar la consulta detrás de la respuesta.

Select AI no sustituye el criterio profesional. Un buen flujo consiste en mostrar el SQL, comprobar tablas y filtros, ejecutar la sentencia y comparar la respuesta con la pregunta de negocio.

## Siguientes pasos

Para consultar las acciones de Select AI, los atributos de perfil y los proveedores compatibles, revisa la [documentación de Select AI de Oracle AI Database 26ai](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Agradecimientos

* **Autor** - Kevin Lazarz
* **Colaborador** - Eugenio Galiano
* **Última actualización por/fecha** - Oracle Database Product Management, agosto de 2026
