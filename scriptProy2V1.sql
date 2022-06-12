#TABLAS

CREATE TABLE Torneo (
	idTorneo integer PRIMARY KEY NOT NULL,
	pais VARCHAR(60) NOT NULL
);

CREATE DOMAIN fecha AS VARCHAR(2) CHECK (
	VALUE ~ '\<[Q] + [1-4]\>'
);

CREATE TABLE InstanciaTorneo (
	fechaTermino fecha NOT NULL,
	ciudad VARCHAR(60) NOT NULL,
	fechaInicio fecha NOT NULL,
	refTorneo integer,
	FOREIGN KEY(refTorneo) REFERENCES Torneo(idTorneo)
	ON DELETE SET DEFAULT '-1' 
	ON UPDATE CASCADE
);

CREATE TABLE Tenista (
	nroPasaporteTenista integer PRIMARY KEY,
	nombreTenista VARCHAR(100) NOT NULL,
	fecnacTenista DATE NOT NULL,
	ranking integer NOT NULL,
	estatura float NOT NULL,
	nacionalidad VARCHAR(60)NOT NULL,
	CONSTRAINT mayorEdad CHECK (fecnacTenista > '2004-12-31')
);

CREATE TABLE Partido(
	idPartido integer PRIMARY KEY NOT NULL,
	modalidad VARCHAR(40) NOT NULL,
	refInstancia VARCHAR (60) NOT NULL,
    FOREIGN KEY(refInstancia) REFERENCES InstanciaTorneo(fechaInicio)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE SetPartido (
	idSet integer UNIQUE NOT NULL,
	nSet integer NOT NULL,
	refPartido integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Juego(
	idJuego integer UNIQUE NOT NULL,
	njuego integer NOT NULL,
	refSet integer,
	FOREIGN KEY(refSet) REFERENCES SetPartido(idSet)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Nacionalidades(
	idNacionalidad integer PRIMARY KEY NOT NULL,
	nacionalidad VARCHAR(60),
	refTenistaNacionalidad integer,
	FOREIGN KEY(refTenistaNacionalidad) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Arbitro(
	nroPasaporteArbitro integer PRIMARY KEY NOT NULL,
	nombreArbitro VARCHAR(100) NOT NULL,
	fecnacArbitro DATE NOT NULL,
	expArbitro INTEGER NOT NULL,
);

CREATE TABLE ParticipaPartido (
	idParticipaPartido integer PRIMARY KEY NOT NULL,
	refPartido integer,
	equipo integer,
	tenista integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(tenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE GanaPartido (
	idGanaPartido integer PRIMARY KEY NOT NULL,
	refPartido integer,
	refTenista integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE PierdePartido (
	idPierdePartido integer PRIMARY KEY NOT NULL,
	refPartido integer,
	refTenista integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE ParticipaSet (
	idParticipaSet integer PRIMARY KEY NOT NULL,
	refSet integer,
	refTenista integer,
	FOREIGN KEY(refSet) REFERENCES SetPartido(idSet)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE GanaSet (
	idGanaSet integer PRIMARY KEY NOT NULL,
	refSet integer,
	refTenista integer,
	FOREIGN KEY(refSet) REFERENCES SetPartido(idSet)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE PierdeSet (
	idPierdeSet integer PRIMARY KEY NOT NULL,
	refSet integer,
	refTenista integer,
	FOREIGN KEY(refSet) REFERENCES SetPartido(idSet)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE ParticipaJuego (
	idParticipaJuego integer PRIMARY KEY NOT NULL,
	refJuego integer,
	refTenista integer,
	FOREIGN KEY(refJuego) REFERENCES Juego(idJuego)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE GanaJuego (
	idGanaJuego integer PRIMARY KEY NOT NULL,
	refJuego integer,
	refTenista integer,
	FOREIGN KEY(refJuego) REFERENCES Juego(idJuego)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE PierdeJuego (
	idPierdeJuego integer PRIMARY KEY NOT NULL,
	refJuego integer,
	refTenista integer,
	FOREIGN KEY(refJuego) REFERENCES Juego(idJuego)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(refTenista) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE Arbitra(
	idArbitra integer PRIMARY KEY NOT NULL,
	refArbitro integer, 
	refPartido integer,
	rol INTEGER DEFAULT 'linea',
	FOREIGN KEY(refArbitro) REFERENCES Arbitro(nroPasaporteArbitro)
	ON DELETE SET NULL 
	ON UPDATE CASCADE,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);


#TRIGGER

CREATE OR REPLACE FUNCTION evitar_tenista_menor_de_edad() 
RETURNS trigger AS
$BODY$
BEGIN 
	IF NEW.fecnactenista > '2004-12-31' THEN
		RAISE EXCEPTION 'El tenista es demasiado joven para participar!';
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE COST 100;

CREATE TRIGGER trigger_tenista_menor_de_edad
	BEFORE INSERT ON tenista
	FOR EACH ROW 
		EXECUTE PROCEDURE evitar_tenista_menor_de_edad();

#PRUEBA DEL TRIGGER:
INSERT INTO tenista VALUES(00011, 'Jose Marquez Aravena', '2022-06-05', 1230, 1.74, 'Chileno')