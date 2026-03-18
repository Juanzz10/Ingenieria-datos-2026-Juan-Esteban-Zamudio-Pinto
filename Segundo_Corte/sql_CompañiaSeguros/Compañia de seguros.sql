create database compañiaseguros;
use compañiaseguros;

create table compañia(
idCompañia varchar (50) primary key,
nit varchar (20) unique not null,
nombre varchar (50) not null,
fechaFundacion date null,
representanteLegal varchar (50) not null
);

create table seguros(
idSeguro varchar (50) primary key,
fechaInicio date null,
fechaExperiacion date not null,
estado varchar (20) not null,
costo double not null,
valorAsegurado double not null,
idCompañiaFK varchar (50) not null,
idAutomovilFK varchar (50) not null
);

create table automovil(
idAutomovil varchar (50) primary key,
marca varchar (20) not null,
modelo varchar (20) not null,
placa varchar (20) unique not null,
tipos varchar (50) not null,
añoFabricacion int null,
serialChasis varchar (50) unique not null,
pasajeros int not null,
cilindraje int not null
);

create table involucrados(
idAutomovilFK varchar (50) not null,
idAccidenteFK varchar (50) not null
);

create table accidente(
idAccidente varchar (50) primary key,
automotores varchar (20) not null,
fatalidades int not null,
heridos int not null,
lugar varchar (50) not null,
fechaAccidente date not null
);

alter table seguros
add constraint FKCompañiaSeguros
foreign key(idCompañiaFK)
references compañia(idCompañia);

alter table seguros
add constraint FKAutomoviles
foreign key(idAutomovilFK)
references automovil(idAutomovil);

alter table involucrados
add constraint FKAutos
foreign key(idAutomovilFK)
references automovil(idAutomovil);

alter table involucrados
add constraint FKAccidentes
foreign key(idAccidenteFK)
references accidente(idAccidente);

## SE CAMBIA EL NOMBRE DE LA TABLA ACCIDENTE
alter table accidente rename to choques;

## SE ELIMINA EL CAMPO NOMBRE DE LA TABLA COMPAÑIA
alter table compañia drop nombre;

## SE BORRA LA LLAVE FORANEA FKAutomoviles DE LA TABLA seguros
alter table seguros drop foreign key FKAutomoviles;


