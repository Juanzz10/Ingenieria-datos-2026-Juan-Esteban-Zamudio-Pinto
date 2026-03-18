create database tienda_online;
use tienda_online;

create table productos(
idProducto int unique primary key auto_increment,
nombre varchar (20) not null,
precio double not null,
stock int default (0),
fechaCreacion datetime default(current_timestamp)
);

create table clientes(
idCliente varchar (50) primary key,
nombre varchar (20) not null,
emailCliente varchar (50) unique not null,
telefono varchar (20) null
);

create table pedidos(
idPedido varchar (50) primary key,
idClienteFK varchar(50) not null,
fecha date not null,
total double not null
);


alter table pedidos
add constraint FKClientes
foreign key(idClienteFk)
references clientes(idCliente);

alter table productos
add column categoria varchar (50);

alter table clientes
modify column telefono int not null;

alter table pedidos change column total monto_total int;

alter table productos
drop column fecha;


