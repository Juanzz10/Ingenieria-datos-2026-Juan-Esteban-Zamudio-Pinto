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

