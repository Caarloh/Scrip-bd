#TABLAS

CREATE TABLE Torneo (
	idTorneo integer PRIMARY KEY NOT NULL,
	pais VARCHAR(60) NOT NULL
);

CREATE TABLE InstanciaTorneo (
	fechaTermino VARCHAR (60) NOT NULL,
	ciudad VARCHAR(60) NOT NULL,
	fechaInicio VARCHAR(60) PRIMARY KEY NOT NULL,
	refTorneo integer,
	FOREIGN KEY(refTorneo) REFERENCES Torneo(idTorneo)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Tenista (
	nroPasaporteTenista integer PRIMARY KEY NOT NULL,
	nombreTenista VARCHAR(100) NOT NULL,
	fecnacTenista DATE NOT NULL,
	ranking integer NOT NULL,
	estatura float NOT NULL,
	nacionalidad VARCHAR(60)NOT NULL
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
	idSet integer PRIMARY KEY NOT NULL,
	nSet integer NOT NULL,
	refPartido integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Juego(
	idJuego integer PRIMARY KEY NOT NULL,
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
	rol INTEGER NOT NULL
);

CREATE TABLE ParticipaPartido (
	idParticipaPartido integer PRIMARY KEY NOT NULL,
	refPartido integer,
	tenista1Equipo1 integer,
	tenista1Equipo2 integer,
	tenista2Equipo1 integer,
	tenista2Equipo2 integer,
	FOREIGN KEY(refPartido) REFERENCES Partido(idPartido)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
	FOREIGN KEY(tenista1Equipo1) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
    FOREIGN KEY(tenista1Equipo2) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
    FOREIGN KEY(tenista2Equipo1) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE RESTRICT 
	ON UPDATE CASCADE,
    FOREIGN KEY(tenista2Equipo2) REFERENCES Tenista(nroPasaporteTenista)
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
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
	ON DELETE RESTRICT 
	ON UPDATE CASCADE
);

CREATE TABLE Arbitra(
	idArbitra integer PRIMARY KEY NOT NULL,
	refArbitro integer, 
	refPartido integer,
	FOREIGN KEY(refArbitro) REFERENCES Arbitro(nroPasaporteArbitro)
	ON DELETE RESTRICT 
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