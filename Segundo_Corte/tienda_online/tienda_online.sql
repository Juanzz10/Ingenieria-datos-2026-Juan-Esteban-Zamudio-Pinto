create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table cliente_backup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100) ,
emailCliente varchar(150),
copiado_en datetime default now()
);
-- select consulta general de las tablas 
select * from clientes;

select * from productos;

select * from pedido;


-- Agregar 1 registro
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Ana Garcia','ana@mail.com','Madrid');
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
 select * from clientes;
-- Agregar Varios registros
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

select * from productos;

insert into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';


select * from cliente_backup;

describe cliente_backup;


select * from clientes;
-- Actualizar un campo
update clientes
set ciudad='Valencia'
where idCliente=1;

-- Actualizar varios campos
select * from productos;

update productos
set
precioProducto=1099000,
stockProducto=10
where idProducto=1;

update productos
set precioProducto=precioProducto * 1.10
where categoriaProducto='Accesorios';


select * from clientes;
delete from clientes 
where idCliente=2;

select * from productos;
delete from productos
where stockProducto=0 AND categoriaProducto='Descatalogado';

/* iNSERT
1. Inserta 3 clientes nuevos con nombre, email y ciudad
2. Inserta 2 productos con nombre, precio, stock y categoría
3. Inserta 1 pedido vinculando un cliente y un producto recién creados
UPDATE
4. Cambia la ciudad de uno de tus clientes insertados
5. Aumenta en 5 unidades el stock de uno de tus productos
6. Modifica el precio del segundo producto aplicando un descuento del 10%
DELETE
7. Elimina el pedido que creaste en el punto 3
8. Elimina el cliente cuya ciudad cambiaste en el punto 4
9. Elimina todos los productos con stock menor a 3

*/

-- INSERT

INSERT INTO clientes (nombreCliente, emailCliente, ciudad)
VALUES
  ('Laura Martínez', 'laura@mail.com',   'Bogotá'),
  ('Carlos López',   'carlos@mail.com',  'Medellín'),
  ('Sofía Ruiz',     'sofia@mail.com',   'Cali'); 
  
INSERT INTO productos (nombreProducto, precioProducto, stockProducto, categoriaProducto)
VALUES
  ('Auriculares BT', 180000, 25, 'Accesorios'),
  ('Tablet 10"',      850000, 12, 'Electrónica');
  
SELECT idCliente, nombreCliente FROM clientes  ORDER BY idCliente DESC LIMIT 3;
SELECT idProducto, nombreProducto FROM productos ORDER BY idProducto DESC LIMIT 2;
INSERT INTO pedido (cantidadProducto, fechaPedido, idClienteFK, idProductoFK)
VALUES (2, '2026-03-19', 3, 5);
  
  --UPDATE
  
UPDATE clientes 
SET 
    ciudad = 'Barranquilla'
WHERE
    idCliente = 3; 
    
    
UPDATE productos
SET    stoProdT = stoProdT + 5
WHERE  idProducto = 5;
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;


UPDATE productos
SET    precioProducto = precioProducto * 0.90
WHERE  idProducto = 6;

-- DELETE

DELETE FROM pedido
WHERE idPedido = 1;

DELETE FROM pedido  WHERE idClienteFK = 3;
DELETE FROM clientes WHERE idCliente = 3;

SELECT * FROM productos WHERE stockProducto < 3;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM productos WHERE stockProducto < 3;
SET SQL_SAFE_UPDATES = 1;


describe productos;

alter table productos
change column stockProducto stoProdT int;
select nombreProducto, stoProdT from productos;

-- Muestra la tabla con nombres distintos pero no cambia en la BD
select nombreProducto as Nombre_Producto, stoProdT as stock from productos;

 -- Muestra casilla especifica
select nombreProducto, stoProdT from productos where idProducto=2;

select nombreProducto as Nombre_Producto, stoProdT as stock from productos where stoProdT>15 and nombreProducto ="Laptop Pro";

select nombreProducto as Nombre_Producto, stoProdT as stock from productos where stoProdT>15 or nombreProducto ="Laptop Pro";

-- Orden numerico
select nombreProducto as Nombre_Producto, stoProdT as stock 
from productos order by stoProdT asc;

select nombreProducto as Nombre_Producto, stoProdT as stock 
from productos order by stoProdT desc;

--Orden alfabetico
select nombreProducto as Nombre_Producto, stoProdT as stock 
from productos order by nombreProducto asc;

select nombreProducto as Nombre_Producto, stoProdT as stock 
from productos order by nombreProducto desc;     

--  Between
select nombreProducto as Nombre_Producto, precioProducto as precio
from productos where precioProducto between 50000 and 100000 and stoProdT > 3 order by precioProducto asc; 

 -- like ( Inician por ... )
select * from productos where nombreProducto like "mou%";
--  (Que contengan ... )
select * from productos where nombreProducto like "%ou%";
--  (Que terminen ...)
select * from productos where nombreProducto like "%os";

select * from productos where nombreProducto like "%os" order by precioProducto asc limit 1;

-- Consultas utilizando metodos

SELECT nombreProducto, stoProdT
FROM productos
WHERE nombreProducto LIKE '%top%'
AND stoProdT > 10;

SELECT nombreProducto, precioProducto
FROM productos
WHERE precioProducto BETWEEN 50000 AND 1100000
AND nombreProducto LIKE 'l%'
ORDER BY precioProducto DESC;


SELECT nombreProducto, precioProducto
FROM productos
WHERE nombreProducto LIKE '%a'
ORDER BY precioProducto ASC;

select * from productos;


-- Importar datos de csv se hace mediante el Import Wizard de MySQL
-- Los datos tambien se pueden importar de archivos JSON, XML, TXT.

-- agrupar campos by select

select * from productos group by categoriaProducto;
 
select categoriaProducto,
count(*) as cantidad,
avg(precioProducto) as promedioMedio
from productos 
group by categoriaProducto
having avg(precioProducto) > 5000
order by promedioMedio desc;


-- Funciones calculadas
select
count(*) as Total,
avg(precioProducto) as PromedioPrecio,
max(precioProducto) as PrecioMaximo,
min(precioProducto) as PrecioMinimo,
sum(stoProdT) as StockTotal
from productos;

select nombreCliente as nombre,
upper(nombreCliente) as NombreMayusacula,
concat('Nombre Ciente: ', nombreCliente, ' email cliente: ', emailCliente) as concatenar,
length(nombreCliente) as tamanioNombre
from clientes;

## SUBCONSULTAS

/*Consultas Anidadas SubQuery select 
select col1,col2
from tabla_Princial
where columna operador
	(select col1,col2
	from tabla_Secundaria
	where condicion); 
Escalar devuelve  un único valor o fila o columna 
de fila devuelve una sola fila con varias columnas ROw()
de tabla devuelve varias filas y varias columnas
correlacional

 1. reto 1 crear tabla empleados (id,nombre,deptoId, salario), producto (id,nombre,precio,categoria),
 departamento(id,nombre)
 2. Vamos a registrar 5 empleados 3 departamentos y 5 productos*/


create table empleados(
idEmpleado int primary key,
nombreEmpleado varchar (50) not null,
salario double not null,
idDepartamentoFK int not null
);


create table producto(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
categoriaProducto varchar(60)
);

create table departamento(
idDepartamento int primary key,
nombreDepartamento varchar (50) not null
);

alter table empleados
add constraint FKDepartamentoEmpleados
foreign key(idDepartamentoFK)
references departamento(idDepartamento);

INSERT INTO empleados (idEmpleado, nombreEmpleado, salario, idDepartamentoFK)
VALUES
	(1,'Ernesto',500000, 1),
    (2,'Manuel',250000, 2),
    (3,'Juan',  320000, 3),
    (4,'Daniel',  100000, 4),
    (5,'Santiago',   200000, 5);
    
INSERT INTO departamento (idDepartamento, nombreDepartamento)
VALUES
	(1, 'DeptoA'),
    (2, 'DeptoB'),
    (3, 'DeptoC'),
    (4, 'DeptoD'),
    (5, 'DeptoE');
    
INSERT INTO producto (idProducto, nombreProducto, precioProducto, categoriaProducto)
VALUES
  (100, 'celular', 180000, 'Electronica'),
  (205, 'Silla', 850000, 'Oficina'),
  (300, 'Escritorio', 180000, 'Oficina'),
  (420, 'Tablet 10', 850000, 'Electrónica'),
  (210, 'Monitor',  850000, 'Electrónica');


/*Subconsultas*/
###-----Where----
select nombreEmpleado,salario 
from empleados
where salario>
	(select AVG(salario)
    from empleados);
    
 ###-----Where+in----
select nombreEmpleado,salario 
from empleados
where idDepartamentoFK in 
	(select idDepartamento
    from departamento
    where nombreDepartamento in ('DeptoA','DeptoB'));
   
   
 ###-----tabla derivada----
select idDepartamentoFK,prom_salario
from 
	(select idDepartamentoFK,AVG(salario)as prom_salario
	from empleados
    group by idDepartamentoFK) as promedios
where prom_salario > 2800000.000000;


## TAREA
select nombreEmpleado, salario,
(select AVG(salario) from empleados) AS prom_salario,
salario - (select AVG(salario) from empleados) as diferencia from empleados; 


select nombreProducto, precioProducto
from producto
where precioProducto>
	(select AVG(precioProducto)
    from producto)
order by precioProducto desc;

select * from productos;

create table pedidos(
idPedidos int primary key auto_increment,
idCliente int not null,
fechaPedidos date not null,
estado enum('pendiente', 'enviado', 'entregado', 'cancelado'),
total decimal (12,2) default 0,
foreign key(idCliente) references clientes(idCliente)
);

create table detallePedido(
idDetalle int primary key auto_increment,
idPedidos int not null,
idProducto int not null,
cantidad int not null,
precio_unit decimal(10,2) not null,
foreign key (idPedidos) references pedidos(idPedidos),
foreign key (idProducto) references producto (idProducto)
);

INSERT INTO pedidos (idCliente, fechaPedidos, estado, total)
VALUES
  (1, '2026-04-01', 'entregado',  1030000),
  (1, '2026-04-03', 'enviado',    1700000),
  (1, '2026-04-07', 'pendiente',   180000);

INSERT INTO detallePedido (idPedidos, idProducto, cantidad, precio_unit)
VALUES
  (4, 100, 1, 180000),   
  (5, 210, 1, 850000),   
  (4, 205, 1, 850000),   
  (6, 420, 1, 850000),   
  (5, 100, 1, 180000);   

SELECT 
    c.nombreCliente,
    c.emailCliente,
    p.idPedidos,
    p.fechaPedidos,
    p.estado,
    pr.nombreProducto,
    dp.cantidad,
    dp.precio_unit,
    (dp.cantidad * dp.precio_unit) AS totalLinea
FROM clientes c
JOIN pedidos p       ON c.idCliente  = p.idCliente
JOIN detallePedido dp ON p.idPedidos  = dp.idPedidos
JOIN producto pr     ON dp.idProducto = pr.idProducto
ORDER BY p.idPedidos ASC;



