-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
DROP DATABASE IF EXISTS tienda_tech;
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4;
USE tienda_tech;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    ciudad          VARCHAR(60),
    fecha_registro  DATE DEFAULT (CURRENT_DATE)
);


CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria    VARCHAR(60),
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    estado       VARCHAR(20) DEFAULT "pendiente"
        CHECK (estado IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes VALUES
 (1,"Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 (2,"Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 (3,"Maria Torres","maria@mail.com","Cali","2023-05-10"),
 (4,"Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 (5,"Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 (6,"Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 (7,"Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 (8,"Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos VALUES
 (1,"Laptop Pro 15","Computadores",3500000.00,12),
 (2,"Mouse Inalambrico","Perifericos",85000.00,50),
 (3,"Teclado Mecanico","Perifericos",220000.00,30),
 (4,"Monitor 27","Pantallas",1200000.00,8),
 (5,"Auriculares BT","Audio",350000.00,25),
 (6,"Webcam HD","Perifericos",180000.00,20),
 (7,"Disco SSD 1TB","Almacenamiento",420000.00,40),
 (8,"Tablet 10","Moviles",1800000.00,6);

INSERT INTO pedidos VALUES
 (1,1,1,1,"2024-01-10","entregado"),(2,1,2,2,"2024-01-15","entregado"),
 (3,2,3,1,"2024-02-05","entregado"),(4,2,5,1,"2024-02-20","cancelado"),
 (5,3,4,1,"2024-03-01","entregado"),(6,3,7,2,"2024-03-15","pendiente"),
 (7,4,2,3,"2024-04-02","entregado"),(8,4,6,1,"2024-04-10","pendiente"),
 (9,5,8,1,"2024-04-18","entregado"),(10,6,1,2,"2024-05-05","entregado"),
 (11,6,3,1,"2024-05-12","pendiente"),(12,7,5,2,"2024-05-20","entregado"),
 (13,1,7,1,"2024-06-01","entregado"),(14,8,4,1,"2024-06-10","cancelado"),
 (15,5,2,4,"2024-06-15","entregado"),(16,3,1,1,"2024-07-01","pendiente");
 
 
/*  1) Agregue a la tabla pedidos una columna total_valor DECIMAL(12,2) generada automáticamente como 
la multiplicacion de cantidad por el precio del producto (columna calculada persistida con AS ..STORED,
o en su defecto agréguela como columna normal y luego actualice su valor mediante un UPDATE con 
JOIN entre pedidos y productos). Finalmente, agregue un índice sobre la columna estado
Clausulas requeridas: ALTER TABLE, UPDATE ... JOIN, CREATE INDEX */

 
 alter table pedidos
 add column total_valor decimal(12, 2);
 
update pedidos pe
join productos pr on pe.producto_id = pr.producto_id
set pe.total_valor = pe.cantidad * pr.precio;

create index idx_estado ON pedidos(estado);

select pedido_id, cantidad, total_valor FROM pedidos;
select precio from productos;

/* 2) Cree la tabla log_cambios_estado (log_id PK AI, pedido_id FK, estado_anterior VARCHAR(20), 
estado_nuevo VARCHAR(20), fecha_cambio DATETIME DEFAULT NOW()). A continuación, 
cree una vista llamada vista_log_reciente que muestre los últimos 10 registros 
de log_cambios_estado ordenados por fecha_cambio descendente.
Clausula requeridas: CREATE TABLE, FOREIGN KEY, CREATE VIEW, ORDER BY, LIMIT*/

create table log_cambios_estado(
log_id int primary key auto_increment,
pedido_id int,
estado_anterior varchar(20),
estado_nuevo varchar(20),
fecha_cambio datetime default now(),
foreign key (pedido_id) references pedidos(pedido_id)
);

create view vista_log_reciente as
select 
log_id,
pedido_id,
estado_anterior,
estado_nuevo,
fecha_cambio
from log_cambios_estado
order by fecha_cambio desc
limit 10;

select * from vista_log_reciente;

/* 3) Realice las siguientes operaciones en una misma sesión: (a) Inserte un nuevo cliente 
(nombre=Laura Rios, email=laura@mail.com, ciudad=Manizales). 
(b) Inserte un pedido para ese cliente del producto_id=3 con cantidad=2 y estado=pendiente. 
(c) Actualice el stock del producto_id=3 decrementandolo en 2. 
(d) Consulte con un JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado.
Clausula requeridas: INSERT, UPDATE, SELECT con JOIN, WHERE
*/

insert into clientes (nombre, email, ciudad)
values
	("Laura Rios", "laura@mail.com", "Manizales");
    
insert into pedidos (cliente_id, producto_id, cantidad, estado)
values
	(last_insert_id(),3, 2, 'pendiente');

update productos
set stock = stock - 2
where producto_id = 3;

select 
    c.nombre as nombre_cliente,
    pr.nombre as nombre_producto,
    pe.estado
from pedidos pe
join  clientes c on pe.cliente_id  = c.cliente_id
join productos pr on pe.producto_id = pr.producto_id
where pe.pedido_id = LAST_INSERT_ID();


/* 4) Actualice el precio de todos los productos cuyo stock sea menor al promedio de stock de su misma 
categoría (use subconsulta correlacionada), incrementando el precio un 8%. 
Luego elimine los pedidos con estado cancelado cuyos clientes no tengan ningún otro pedido en estado 
entregado (use subconsulta con NOT EXISTS).
Clausulas requeridas: UPDATE con subconsulta correlacionada, DELETE con NOT EXISTS*/

update productos p
set precio = precio * 1.08
where stock < (select avg(stock)
from productos p2
where p2.categoria = p.categoria
);

delete from pedidos 
where estado = 'cancelado'
and not exists (
    select 1
    from (select cliente_id from pedidos where estado = 'entregado') as entregados
    where entregados.cliente_id = pedidos.cliente_id
);

select * from pedidos;

/* 5) Liste el nombre del cliente, ciudad, nombre del producto, cantidad y fecha_pedido de todos los 
pedidos entregados cuyo total (cantidad * precio) supere el promedio general de totales de pedidos 
entregados. Ordene los resultados por total descendente.
Clausulas requeridas: JOIN tres tablas, WHERE con subconsulta escalar AVG, ORDER BY DESC*/

select
    c.nombre as nombre_cliente,
    c.ciudad,
    pr.nombre as nombre_producto,
    pe.cantidad,
    pe.fecha_pedido,
    (pe.cantidad * pr.precio) as total
from pedidos pe
join clientes  c  on pe.cliente_id  = c.cliente_id
join productos pr on pe.producto_id = pr.producto_id
where pe.estado = 'entregado'
and (pe.cantidad * pr.precio) > (
    select avg(pe2.cantidad * pr2.precio)
    from pedidos pe2
    join productos pr2 on pe2.producto_id = pr2.producto_id
    where pe2.estado = 'entregado'
)
order by total desc;


select avg(total_valor) from pedidos;


/* 6) Cree la vista vista_ventas_ciudad que muestre: ciudad, total_pedidos_entregados, suma_ingresos 
(SUM de cantidad*precio) y promedio_ingreso_por_pedido. Luego consulte la vista para mostrar solo las 
ciudades cuyo suma_ingresos supere los 5,000,000, ordenadas de mayor a menor.
Clausula requeridas: CREATE VIEW con JOIN, GROUP BY, CREATE INDEX opcional, SELECT FROM vista con WHERE
y ORDER BY */

create view vista_ventas_ciudad as
select
    c.ciudad,
    COUNT(pe.pedido_id) as total_pedidos_entregados,
    SUM(pe.cantidad * pr.precio) as suma_ingresos,
    avg(pe.cantidad * pr.precio) as promedio_ingreso_por_pedido
from pedidos pe
join clientes  c on pe.cliente_id  = c.cliente_id
join productos pr on pe.producto_id = pr.producto_id
where pe.estado = 'entregado'
group by c.ciudad;

select * from vista_ventas_ciudad
where suma_ingresos > 5000000
order by suma_ingresos desc;


/* 7) Cree la vista vista_productos_populares que liste los productos que hayan sido pedidos por más de un 
cliente distinto (en pedidos entregados). La vista debe mostrar: producto_id, nombre, categoria, precio 
y total_clientes_distintos. Luego use la vista para obtener unicamente 
los productos de la categoría Perifericos.
Clausula requeridas: CREATE VIEW con subconsulta o HAVING COUNT(DISTINCT), SELECT FROM vista con WHERE */

create view vista_productos_populares as
select
    pr.producto_id,
    pr.nombre,
    pr.categoria,
    pr.precio,
    COUNT(distinct pe.cliente_id) as total_clientes_distintos
from productos pr
join pedidos pe on pr.producto_id = pe.producto_id
where pe.estado = 'entregado'
group by pr.producto_id, pr.nombre, pr.categoria, pr.precio
having COUNT(distinct pe.cliente_id) > 1;

SELECT * FROM vista_productos_populares;

select * from vista_productos_populares
where categoria = 'Perifericos';

-- PREGUNTA 8
-- Cree la función fn_ingreso_cliente(p_cliente_id INT) que retorne el ingreso 
-- total acumulado de un cliente (suma de cantidad*precio solo para pedidos 
-- entregados, usando JOIN entre pedidos y productos). Luego use esa función en 
-- un SELECT sobre la tabla clientes para mostrar nombre, ciudad y su ingreso_total, 
-- ordenados de mayor a menor ingreso.
-- =====================================================

DELIMITER //
CREATE FUNCTION fn_ingreso_cliente(p_cliente_id INT) 
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE ingreso_total DECIMAL(12,2);
    
    SELECT SUM(pd.cantidad * p.precio) INTO ingreso_total
    FROM pedidos pd
    JOIN productos p ON pd.producto_id = p.producto_id
    WHERE pd.cliente_id = p_cliente_id AND pd.estado = 'entregado';
    
    RETURN IFNULL(ingreso_total, 0);
END//
DELIMITER ;

SELECT c.nombre, c.ciudad, fn_ingreso_cliente(c.cliente_id) AS ingreso_total
FROM clientes c
ORDER BY ingreso_total DESC;

-- =====================================================
-- PREGUNTA 9
-- Cree la función fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT) 
-- que retorne 1 si el stock actual del producto es mayor o igual a la cantidad 
-- solicitada, o 0 en caso contrario. Luego escriba una consulta que liste nombre 
-- y stock de todos los productos donde fn_stock_suficiente(producto_id, 5) = 0, 
-- es decir, productos con menos de 5 unidades disponibles.
-- =====================================================

DELIMITER //
CREATE FUNCTION fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM productos
    WHERE producto_id = p_producto_id;
    
    RETURN IF(stock_actual >= p_cantidad_solicitada, 1, 0);
END//
DELIMITER ;

SELECT nombre, stock
FROM productos
WHERE fn_stock_suficiente(producto_id, 5) = 0;

-- =====================================================
-- PREGUNTA 10
-- Cree el procedimiento sp_actualizar_estado_pedido(p_pedido_id INT, 
-- p_nuevo_estado VARCHAR(20)) que: (a) Verifique que el pedido exista (si no, 
-- retorne mensaje de error). (b) Inserte un registro en log_cambios_estado con 
-- el estado anterior y el nuevo. (c) Actualice el estado del pedido. (d) Si el 
-- nuevo estado es cancelado, restaure el stock del producto correspondiente.
-- =====================================================

DELIMITER //
CREATE PROCEDURE sp_actualizar_estado_pedido(
    IN p_pedido_id INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_estado_anterior VARCHAR(20);
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_existe INT;
    
    SELECT COUNT(*) INTO v_existe
    FROM pedidos
    WHERE pedido_id = p_pedido_id;
    
    IF v_existe = 0 THEN
        SELECT 'Error: El pedido no existe' AS mensaje;
    ELSE
        SELECT estado, producto_id, cantidad 
        INTO v_estado_anterior, v_producto_id, v_cantidad
        FROM pedidos
        WHERE pedido_id = p_pedido_id;
        
        INSERT INTO log_cambios_estado (pedido_id, estado_anterior, estado_nuevo)
        VALUES (p_pedido_id, v_estado_anterior, p_nuevo_estado);
        
        UPDATE pedidos
        SET estado = p_nuevo_estado
        WHERE pedido_id = p_pedido_id;
        
        IF p_nuevo_estado = 'cancelado' THEN
            UPDATE productos
            SET stock = stock + v_cantidad
            WHERE producto_id = v_producto_id;
        END IF;
        
        SELECT 'Estado actualizado exitosamente' AS mensaje;
    END IF;
END//
DELIMITER ;

-- =====================================================
-- PREGUNTA 11
-- Cree el procedimiento sp_resumen_cliente(p_cliente_id INT) que ejecute y retorne 
-- en un solo SELECT: nombre del cliente, ciudad, total de pedidos por estado (use 
-- SUM con CASE WHEN para contar pedidos entregados, pendientes y cancelados en 
-- columnas separadas) y el ingreso total solo de pedidos entregados.
-- =====================================================

DELIMITER //
CREATE PROCEDURE sp_resumen_cliente(IN p_cliente_id INT)
BEGIN
    SELECT c.nombre, c.ciudad,
           SUM(CASE WHEN pd.estado = 'entregado' THEN 1 ELSE 0 END) AS total_entregados,
           SUM(CASE WHEN pd.estado = 'pendiente' THEN 1 ELSE 0 END) AS total_pendientes,
           SUM(CASE WHEN pd.estado = 'cancelado' THEN 1 ELSE 0 END) AS total_cancelados,
           SUM(CASE WHEN pd.estado = 'entregado' THEN pd.cantidad * p.precio ELSE 0 END) AS ingreso_total
    FROM clientes c
    LEFT JOIN pedidos pd ON c.cliente_id = pd.cliente_id
    LEFT JOIN productos p ON pd.producto_id = p.producto_id
    WHERE c.cliente_id = p_cliente_id
    GROUP BY c.cliente_id, c.nombre, c.ciudad;
END//
DELIMITER ;

-- =====================================================
-- PREGUNTA 12
-- Cree la vista vista_pedidos_pendientes que muestre pedido_id, nombre del cliente, 
-- nombre del producto, cantidad, precio unitario y dias_espera (DATEDIFF entre 
-- CURDATE() y fecha_pedido) para todos los pedidos con estado pendiente. Luego 
-- cree el procedimiento sp_alertar_retrasos(p_dias_limite INT) que consulte esa 
-- vista y retorne los pedidos cuyo dias_espera supere p_dias_limite.
-- =====================================================

CREATE VIEW vista_pedidos_pendientes AS
SELECT pd.pedido_id, c.nombre AS nombre_cliente, p.nombre AS nombre_producto,
       pd.cantidad, p.precio AS precio_unitario,
       DATEDIFF(CURDATE(), pd.fecha_pedido) AS dias_espera
FROM pedidos pd
JOIN clientes c ON pd.cliente_id = c.cliente_id
JOIN productos p ON pd.producto_id = p.producto_id
WHERE pd.estado = 'pendiente';

DELIMITER //
CREATE PROCEDURE sp_alertar_retrasos(IN p_dias_limite INT)
BEGIN
    SELECT pedido_id, nombre_cliente, nombre_producto, cantidad, 
           precio_unitario, dias_espera
    FROM vista_pedidos_pendientes
    WHERE dias_espera > p_dias_limite;
END//
DELIMITER ;

-- PREGUNTA 13
-- Agregue la columna descuento DECIMAL(5,2) DEFAULT 0 a la tabla productos con 
-- una restricción CHECK que garantice valores entre 0 y 50. Cree la función 
-- fn_precio_final(p_producto_id INT) que retorne el precio del producto aplicando 
-- su descuento (precio * (1 - descuento/100)). Luego escriba una consulta que 
-- muestre nombre, precio, descuento y precio_final para los 3 productos con mayor 
-- precio_final, usando la función.
-- =====================================================

ALTER TABLE productos 
ADD COLUMN descuento DECIMAL(5,2) DEFAULT 0,
ADD CONSTRAINT chk_descuento CHECK (descuento >= 0 AND descuento <= 50);

DELIMITER //
CREATE FUNCTION fn_precio_final(p_producto_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(5,2);
    
    SELECT precio, descuento INTO v_precio, v_descuento
    FROM productos
    WHERE producto_id = p_producto_id;
    
    RETURN v_precio * (1 - v_descuento/100);
END//
DELIMITER ;

SELECT nombre, precio, descuento, fn_precio_final(producto_id) AS precio_final
FROM productos
ORDER BY precio_final DESC
LIMIT 3;

-- =====================================================
-- PREGUNTA 14
-- Cree el procedimiento sp_registrar_pedido(p_cliente_id INT, p_producto_id INT, 
-- p_cantidad INT) que: (a) Valide que el cliente exista. (b) Valide que el stock 
-- sea suficiente. (c) Inserte el pedido con estado pendiente. (d) Actualice el 
-- stock descontando la cantidad. (e) Retorne con un SELECT JOIN el pedido recién 
-- creado con nombre del cliente y nombre del producto.
-- =====================================================

DELIMITER //
CREATE PROCEDURE sp_registrar_pedido(
    IN p_cliente_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_cliente_existe INT;
    DECLARE v_stock_actual INT;
    
    SELECT COUNT(*) INTO v_cliente_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;
    
    IF v_cliente_existe = 0 THEN
        SELECT 'Error: El cliente no existe' AS mensaje;
    ELSE
        SELECT stock INTO v_stock_actual
        FROM productos
        WHERE producto_id = p_producto_id;
        
        IF v_stock_actual < p_cantidad THEN
            SELECT 'Error: Stock insuficiente' AS mensaje;
        ELSE
            INSERT INTO pedidos (cliente_id, producto_id, cantidad, estado)
            VALUES (p_cliente_id, p_producto_id, p_cantidad, 'pendiente');
            
            UPDATE productos
            SET stock = stock - p_cantidad
            WHERE producto_id = p_producto_id;
            
            SELECT c.nombre AS nombre_cliente, p.nombre AS nombre_producto, 
                   pd.cantidad, pd.estado, pd.fecha_pedido
            FROM pedidos pd
            JOIN clientes c ON pd.cliente_id = c.cliente_id
            JOIN productos p ON pd.producto_id = p.producto_id
            WHERE pd.pedido_id = LAST_INSERT_ID();
        END IF;
    END IF;
END//
DELIMITER ;

-- =====================================================
-- PREGUNTA 15
-- Cree la funcion fn_clasificar_producto(p_producto_id INT) que retorne: PREMIUM 
-- si el precio > 1,000,000; ESTANDAR si esta entre 200,000 y 1,000,000; BASICO 
-- si es menor a 200,000. Luego cree la vista vista_catalogo_clasificado que muestre 
-- nombre, categoria, precio, clasificacion (usando la funcion) y stock para todos 
-- los productos. Finalmente, consulte la vista mostrando solo los productos PREMIUM 
-- con stock > 5.
-- =====================================================

DELIMITER //
CREATE FUNCTION fn_clasificar_producto(p_producto_id INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_clasificacion VARCHAR(20);
    
    SELECT precio INTO v_precio
    FROM productos
    WHERE producto_id = p_producto_id;
    
    SET v_clasificacion = CASE
        WHEN v_precio > 1000000 THEN 'PREMIUM'
        WHEN v_precio >= 200000 THEN 'ESTANDAR'
        ELSE 'BASICO'
    END;
    
    RETURN v_clasificacion;
END//
DELIMITER ;

CREATE VIEW vista_catalogo_clasificado AS
SELECT nombre, categoria, precio, 
       fn_clasificar_producto(producto_id) AS clasificacion, stock
FROM productos;

SELECT nombre, categoria, precio, clasificacion, stock
FROM vista_catalogo_clasificado
WHERE clasificacion = 'PREMIUM' AND stock > 5;

-- PREGUNTA 16
-- Cree la vista vista_clientes_vip que contenga el cliente_id, nombre, ciudad y 
-- total_pedidos_entregados de clientes que hayan realizado mas pedidos entregados 
-- que el promedio de pedidos entregados por cliente (use subconsulta en el HAVING). 
-- Luego escriba una consulta sobre esa vista junto con un JOIN a pedidos y productos 
-- para listar el detalle de los últimos 2 pedidos de cada cliente VIP, mostrando 
-- nombre del cliente, nombre del producto y fecha_pedido.

CREATE VIEW vista_clientes_vip AS
SELECT c.cliente_id, c.nombre, c.ciudad, COUNT(pd.pedido_id) AS total_pedidos_entregados
FROM clientes c
JOIN pedidos pd ON c.cliente_id = pd.cliente_id
WHERE pd.estado = 'entregado'
GROUP BY c.cliente_id, c.nombre, c.ciudad
HAVING COUNT(pd.pedido_id) > (
    SELECT AVG(total_entregados)
    FROM (
        SELECT COUNT(pedido_id) AS total_entregados
        FROM pedidos
        WHERE estado = 'entregado'
        GROUP BY cliente_id
    ) AS subquery
);

SELECT v.nombre AS nombre_cliente, p.nombre AS nombre_producto, pd.fecha_pedido
FROM vista_clientes_vip v
JOIN pedidos pd ON v.cliente_id = pd.cliente_id
JOIN productos p ON pd.producto_id = p.producto_id
WHERE pd.estado = 'entregado'
AND (
    SELECT COUNT(*)
    FROM pedidos pd2
    WHERE pd2.cliente_id = v.cliente_id
    AND pd2.estado = 'entregado'
    AND pd2.fecha_pedido >= pd.fecha_pedido
) <= 2
ORDER BY v.cliente_id, pd.fecha_pedido DESC;
