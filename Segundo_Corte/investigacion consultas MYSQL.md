# Consultas sobre MySQL

## 1. Métodos de tipos numéricos y caracteres en MySQL

En MySQL existen múltiples funciones (métodos) para trabajar con datos numéricos y de tipo carácter (strings).

### Funciones para tipos numéricos
- `ABS(numero)`: Devuelve el valor absoluto.
- `ROUND(numero, decimales)`: Redondea un número.
- `CEIL(numero)` / `CEILING(numero)`: Redondea hacia arriba.
- `FLOOR(numero)`: Redondea hacia abajo.
- `MOD(a, b)`: Devuelve el residuo de una división.
- `POWER(a, b)`: Eleva un número a una potencia.
- `SQRT(numero)`: Calcula la raíz cuadrada.

### Funciones para tipos de caracteres (strings)
- `CONCAT(str1, str2, ...)`: Une cadenas de texto.
- `LENGTH(str)`: Devuelve la longitud en bytes.
- `CHAR_LENGTH(str)`: Devuelve la longitud en caracteres.
- `UPPER(str)` / `LOWER(str)`: Convierte a mayúsculas/minúsculas.
- `SUBSTRING(str, inicio, longitud)`: Extrae una subcadena.
- `REPLACE(str, buscar, reemplazar)`: Reemplaza texto.
- `TRIM(str)`: Elimina espacios en los extremos.
- `LEFT(str, n)` / `RIGHT(str, n)`: Obtiene caracteres desde la izquierda o derecha.

---

## 2. ¿Se puede revertir una eliminación de registros en MySQL?

Depende del contexto.

### Caso 1: Uso de transacciones (sí se puede)
Si se esta trabajando con tablas que soportan transacciones (como InnoDB) se puede revertir una eliminación usando:

```sql
ROLLBACK;
