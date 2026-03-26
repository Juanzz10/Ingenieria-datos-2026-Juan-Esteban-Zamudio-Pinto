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
