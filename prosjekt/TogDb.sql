--Oppretter hele databasen med alle tabeller og alle scripts spesifisert i brukerhistoriene

CREATE TABLE "Stasjon" (
	"StasjonNavn"	TEXT NOT NULL,
	"Moh"	NUMERIC,
	PRIMARY KEY("StasjonNavn")
);

INSERT INTO Stasjon VALUES("Trondheim", 5.1);
INSERT INTO Stasjon VALUES("Steinkjer", 3.6);
INSERT INTO Stasjon VALUES("Mosjøen", 6.8);
INSERT INTO Stasjon VALUES("Mo i Rana", 3.5);
INSERT INTO Stasjon VALUES("Fauske", 34.0);
INSERT INTO Stasjon VALUES("Bodø", 4.1);

CREATE TABLE "Operatør" (
	"Navn"	TEXT NOT NULL,
	PRIMARY KEY("Navn")
);

INSERT INTO Operatør Values("SJ");

CREATE TABLE "Togrute" (
	"RuteID"	INTEGER NOT NULL,
	"Retning"	INTEGER NOT NULL,
	PRIMARY KEY("RuteID")
);

INSERT INTO Togrute Values(1, 1);
INSERT INTO Togrute Values(2, 1);
INSERT INTO Togrute Values(3, 0);

CREATE TABLE "Ukedag" (
	"Dag"	TEXT NOT NULL,
	PRIMARY KEY("Dag")
);

INSERT INTO Ukedag Values("Mandag");
INSERT INTO Ukedag Values("Tirsdag");
INSERT INTO Ukedag Values("Onsdag");
INSERT INTO Ukedag Values("Torsdag");
INSERT INTO Ukedag Values("Fredag");
INSERT INTO Ukedag Values("Lørdag");
INSERT INTO Ukedag Values("Søndag");

CREATE TABLE "Kunde" (
	"KundeNr"	INTEGER NOT NULL,
	"Navn"	TEXT,
	"Epostaddresse"	TEXT,
	"Mobilnummer"	TEXT,
	PRIMARY KEY("KundeNr")
);

CREATE TABLE "Strekning" (
	"StrekningNavn"	TEXT NOT NULL,
	"Fremdriftsenergi"	TEXT,
	"Startstasjon"	TEXT NOT NULL,
	"Endestasjon"	TEXT NOT NULL,
	FOREIGN KEY("Startstasjon") REFERENCES "Stasjon"("StasjonNavn") ON UPDATE CASCADE,
	FOREIGN KEY("Endestasjon") REFERENCES "Stasjon"("StasjonNavn") ON UPDATE CASCADE,
	PRIMARY KEY("StrekningNavn")
);

INSERT INTO Strekning Values("Nordlandsbanen", "Diesel", "Trondheim", "Bodø");

CREATE TABLE "Delstrekning" (
	"DelstrekningID"	INTEGER NOT NULL,
	"StrekningNavn"	TEXT NOT NULL,
	"Lengde"	INTEGER,
	"Spor"	INTEGER,
	"Stasjon1"	TEXT NOT NULL,
	"Stasjon2"	TEXT NOT NULL,
	FOREIGN KEY("StrekningNavn") REFERENCES "Strekning"("StrekningNavn") ON UPDATE CASCADE,
	FOREIGN KEY("Stasjon2") REFERENCES "Stasjon"("StasjonNavn") ON UPDATE CASCADE,
	FOREIGN KEY("Stasjon1") REFERENCES "Stasjon"("StasjonNavn") ON UPDATE CASCADE,
	PRIMARY KEY("DelstrekningID","StrekningNavn")
);

INSERT INTO Delstrekning VALUES(1, "Nordlandsbanen", 120, 2, "Trondheim", "Steinkjer");
INSERT INTO Delstrekning VALUES(2, "Nordlandsbanen", 280, 1, "Steinkjer", "Mosjøen");
INSERT INTO Delstrekning VALUES(3, "Nordlandsbanen", 90, 1, "Mosjøen", "Mo i Rana");
INSERT INTO Delstrekning VALUES(4, "Nordlandsbanen", 170, 1, "Mo i Rana", "Fauske");
INSERT INTO Delstrekning VALUES(5, "Nordlandsbanen", 60, 1, "Fauske", "Bodø");

CREATE TABLE "KjørerDag" (
	"RuteID"	INTEGER NOT NULL,
	"Dag"	TEXT NOT NULL,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("Dag") REFERENCES "Ukedag"("Dag"),
	PRIMARY KEY("RuteID","Dag")
);

INSERT INTO KjørerDag VALUES(1, "Mandag");
INSERT INTO KjørerDag VALUES(1, "Tirsdag");
INSERT INTO KjørerDag VALUES(1, "Onsdag");
INSERT INTO KjørerDag VALUES(1, "Torsdag");
INSERT INTO KjørerDag VALUES(1, "Fredag");
    INSERT INTO KjørerDag VALUES(2, "Mandag");
INSERT INTO KjørerDag VALUES(2, "Tirsdag");
INSERT INTO KjørerDag VALUES(2, "Onsdag");
INSERT INTO KjørerDag VALUES(2, "Torsdag");
INSERT INTO KjørerDag VALUES(2, "Fredag");
INSERT INTO KjørerDag VALUES(2, "Lørdag");
INSERT INTO KjørerDag VALUES(2, "Søndag");
    INSERT INTO KjørerDag VALUES(3, "Mandag");
INSERT INTO KjørerDag VALUES(3, "Tirsdag");
INSERT INTO KjørerDag VALUES(3, "Onsdag");
INSERT INTO KjørerDag VALUES(3, "Torsdag");
INSERT INTO KjørerDag VALUES(3, "Fredag");

CREATE TABLE "GårInnom" (
	"RuteID"	INTEGER NOT NULL,
	"StasjonNavn"	TEXT NOT NULL,
	"Ankomsttid"	TEXT,
	"Avgangstid"	TEXT,
	FOREIGN KEY("StasjonNavn") REFERENCES "Stasjon"("StasjonNavn") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("RuteID","StasjonNavn")
);

INSERT INTO GårInnom VALUES(1, "Trondheim", NULL, "07:49");
INSERT INTO GårInnom VALUES(1, "Steinkjer", "09:51", "09:51");
INSERT INTO GårInnom VALUES(1, "Mosjøen", "13:20", "13:20");
INSERT INTO GårInnom VALUES(1, "Mo i Rana", "14:31", "14:31");
INSERT INTO GårInnom VALUES(1, "Fauske", "16:49", "16:49");
INSERT INTO GårInnom VALUES(1, "Bodø", "17:34", NULL);
    INSERT INTO GårInnom VALUES(2, "Trondheim", NULL, "23:05");
INSERT INTO GårInnom VALUES(2, "Steinkjer", "00:57", "00:57");
INSERT INTO GårInnom VALUES(2, "Mosjøen", "04:41", "04:41");
INSERT INTO GårInnom VALUES(2, "Mo i Rana", "05:55", "05:55");
INSERT INTO GårInnom VALUES(2, "Fauske", "08:19", "08:19");
INSERT INTO GårInnom VALUES(2, "Bodø", "09:05", NULL);
    INSERT INTO GårInnom VALUES(3, "Mo i Rana", NULL, "08:11");
INSERT INTO GårInnom VALUES(3, "Mosjøen", "09:14", "09:14");
INSERT INTO GårInnom VALUES(3, "Steinkjer", "12:31", "12:31");
INSERT INTO GårInnom VALUES(3, "Trondheim", "14:13", NULL);

CREATE TABLE "KjørerDelstrekning" (
	"RuteID"	INTEGER NOT NULL,
	"DelstrekningID"	INTEGER NOT NULL,
	"StrekningNavn"	TEXT NOT NULL,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("StrekningNavn") REFERENCES "Strekning"("StrekningNavn") ON UPDATE CASCADE,
	FOREIGN KEY("DelstrekningID") REFERENCES "Delstrekning"("DelstrekningID"),
	PRIMARY KEY("StrekningNavn","DelstrekningID","RuteID")
);

INSERT INTO KjørerDelstrekning VALUES(1, 1, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(1, 2, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(1, 3, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(1, 4, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(1, 5, "Nordlandsbanen");
    INSERT INTO KjørerDelstrekning VALUES(2, 1, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(2, 2, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(2, 3, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(2, 4, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(2, 5, "Nordlandsbanen");
    INSERT INTO KjørerDelstrekning VALUES(3, 3, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(3, 2, "Nordlandsbanen");
INSERT INTO KjørerDelstrekning VALUES(3, 1, "Nordlandsbanen");

CREATE TABLE "Kundeordre" (
	"OrdreNr"	INTEGER NOT NULL,
	"Dato"	TEXT,
	"Tid"	TEXT,
	"KundeNr"	INTEGER NOT NULL,
	"RuteID"	INTEGER NOT NULL,
	"Reisedag"	TEXT NOT NULL,
	"UkeNr"     INTEGER NOT NULL,
	"År"        INTEGER NOT NULL,
	FOREIGN KEY("KundeNr") REFERENCES "Kunde"("KundeNr") ON DELETE CASCADE,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("Reisedag") REFERENCES "Ukedag"("Dag"),
	PRIMARY KEY("OrdreNr")
);

CREATE TABLE "BetjenerStrekning" (
	"Operatør"   TEXT NOT NULL,
	"StrekningNavn"   TEXT NOT NULL,
	FOREIGN KEY("Operatør") REFERENCES "Operatør"("Navn") ON UPDATE CASCADE,
	FOREIGN KEY("StrekningNavn") REFERENCES "Strekning"("StrekningNavn") ON UPDATE CASCADE,
	PRIMARY KEY("Operatør","StrekningNavn")
);

INSERT INTO BetjenerStrekning Values("Sj", "Nordlandsbanen");

CREATE TABLE "Sittevogn" (
	"SerieNr"	INTEGER NOT NULL,
	"Navn"	TEXT NOT NULL,
	PRIMARY KEY("SerieNr")
);

INSERT INTO Sittevogn VALUES(1, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(2, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(3, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(4, "SJ-sittevogn-1");

CREATE TABLE "SittevognInfo" (
	"Navn"	TEXT NOT NULL,
	"Operatør"	TEXT NOT NULL,
	"Rader"	INTEGER,
	"SeterPrRad"	INTEGER,
	FOREIGN KEY("Operatør") REFERENCES "Operatør"("Navn") ON UPDATE CASCADE,
	PRIMARY KEY("Navn")
);

INSERT INTO SittevognInfo VALUES("SJ-sittevogn-1", "SJ", 3, 4);

CREATE TABLE "Sitteplass" (
	"Plass"	INTEGER NOT NULL,
	"SittevognSerieNr"	INTEGER NOT NULL,
	FOREIGN KEY("SittevognSerieNr") REFERENCES "Sittevogn"("SerieNr") ON DELETE CASCADE,
	PRIMARY KEY("Plass","SittevognSerieNr")
);

INSERT INTO Sitteplass VALUES(1, 1);
INSERT INTO Sitteplass VALUES(2, 1);
INSERT INTO Sitteplass VALUES(3, 1);
INSERT INTO Sitteplass VALUES(4, 1);
INSERT INTO Sitteplass VALUES(5, 1);
INSERT INTO Sitteplass VALUES(6, 1);
INSERT INTO Sitteplass VALUES(7, 1);
INSERT INTO Sitteplass VALUES(8, 1);
INSERT INTO Sitteplass VALUES(9, 1);
INSERT INTO Sitteplass VALUES(10, 1);
INSERT INTO Sitteplass VALUES(11, 1);
INSERT INTO Sitteplass VALUES(12, 1);
    INSERT INTO Sitteplass VALUES(1, 2);
INSERT INTO Sitteplass VALUES(2, 2);
INSERT INTO Sitteplass VALUES(3, 2);
INSERT INTO Sitteplass VALUES(4, 2);
INSERT INTO Sitteplass VALUES(5, 2);
INSERT INTO Sitteplass VALUES(6, 2);
INSERT INTO Sitteplass VALUES(7, 2);
INSERT INTO Sitteplass VALUES(8, 2);
INSERT INTO Sitteplass VALUES(9, 2);
INSERT INTO Sitteplass VALUES(10, 2);
INSERT INTO Sitteplass VALUES(11, 2);
INSERT INTO Sitteplass VALUES(12, 2);
    INSERT INTO Sitteplass VALUES(1, 3);
INSERT INTO Sitteplass VALUES(2, 3);
INSERT INTO Sitteplass VALUES(3, 3);
INSERT INTO Sitteplass VALUES(4, 3);
INSERT INTO Sitteplass VALUES(5, 3);
INSERT INTO Sitteplass VALUES(6, 3);
INSERT INTO Sitteplass VALUES(7, 3);
INSERT INTO Sitteplass VALUES(8, 3);
INSERT INTO Sitteplass VALUES(9, 3);
INSERT INTO Sitteplass VALUES(10, 3);
INSERT INTO Sitteplass VALUES(11, 3);
INSERT INTO Sitteplass VALUES(12, 3);
    INSERT INTO Sitteplass VALUES(1, 4);
INSERT INTO Sitteplass VALUES(2, 4);
INSERT INTO Sitteplass VALUES(3, 4);
INSERT INTO Sitteplass VALUES(4, 4);
INSERT INTO Sitteplass VALUES(5, 4);
INSERT INTO Sitteplass VALUES(6, 4);
INSERT INTO Sitteplass VALUES(7, 4);
INSERT INTO Sitteplass VALUES(8, 4);
INSERT INTO Sitteplass VALUES(9, 4);
INSERT INTO Sitteplass VALUES(10, 4);
INSERT INTO Sitteplass VALUES(11, 4);
INSERT INTO Sitteplass VALUES(12, 4);

CREATE TABLE "SittevognPåTog" (
	"RuteID"	INTEGER NOT NULL,
	"SittevognSerieNr"	INTEGER NOT NULL,
	"VognNr"	INTEGER,
	FOREIGN KEY("SittevognSerieNr") REFERENCES "Sittevogn"("SerieNr") ON DELETE CASCADE,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("SittevognSerieNr","RuteID")
);

INSERT INTO SittevognPåTog VALUES(1, 1, 1);
INSERT INTO SittevognPåTog VALUES(1, 2, 2);
INSERT INTO SittevognPåTog VALUES(2, 3, 1);
INSERT INTO SittevognPåTog VALUES(3, 4, 1);

CREATE TABLE "ReservertPlass" (
	"OrdreNr"	INTEGER NOT NULL,
	"DelstrekningID"	INTEGER NOT NULL,
	"Plass"	INTEGER NOT NULL,
	"SittevognSerieNr"	INTEGER NOT NULL,
	FOREIGN KEY("OrdreNr") REFERENCES "Kundeordre"("OrdreNr"),
	FOREIGN KEY("Plass") REFERENCES "Sitteplass"("Plass") ON DELETE CASCADE,
	FOREIGN KEY("SittevognSerieNr") REFERENCES "Sitteplass"("SittevognSerieNr") ON DELETE CASCADE,
	FOREIGN KEY("DelstrekningID") REFERENCES "Delstrekning"("DelstrekningID"),
	PRIMARY KEY("SittevognSerieNr","Plass","DelstrekningID","OrdreNr")
);

CREATE TABLE "Sovevogn" (
	"SovevognSerieNr"	INTEGER NOT NULL,
	"Navn"	TEXT NOT NULL,
	PRIMARY KEY("SovevognSerieNr","Navn")
);

INSERT INTO Sovevogn VALUES(1, "SJ-sovevogn-1");

CREATE TABLE "SovevognInfo" (
	"Navn"	TEXT NOT NULL,
	"AntallSovekupeer"	INTEGER,
	"Operatør"	TEXT NOT NULL,
	FOREIGN KEY("Operatør") REFERENCES "Operatør"("Navn") ON UPDATE CASCADE,
	PRIMARY KEY("Navn")
);

INSERT INTO SovevognInfo VALUES("SJ-sovevogn-1", 4, "SJ");

CREATE TABLE "Sovekupe" (
	"KupeNr"	INTEGER NOT NULL,
	"SovevognSerieNr"	INTEGER NOT NULL,
	FOREIGN KEY("SovevognSerieNr") REFERENCES "Sovevogn"("SovevognSerieNr") ON DELETE CASCADE,
	PRIMARY KEY("KupeNr","SovevognSerieNr")
);

INSERT INTO Sovekupe VALUES(1, 1);
INSERT INTO Sovekupe VALUES(2, 1);
INSERT INTO Sovekupe VALUES(3, 1);
INSERT INTO Sovekupe VALUES(4, 1);

CREATE TABLE "SovevognPåTog" (
	"RuteID"	INTEGER NOT NULL,
	"SovevognSerieNr"	INTEGER NOT NULL,
	"VognNr"	INTEGER,
	FOREIGN KEY("SovevognSerieNr") REFERENCES "Sovevogn"("SovevognSerieNr") ON DELETE CASCADE,
	FOREIGN KEY("RuteID") REFERENCES "Togrute"("RuteID") ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY("RuteID","SovevognSerieNr")
);

INSERT INTO SovevognPåTog VALUES(2, 1, 2);

CREATE TABLE "ReservertKupe" (
	"OrdreNr"	INTEGER NOT NULL,
	"KupeNr"	INTEGER NOT NULL,
	"SovevognSerieNr"	INTEGER NOT NULL,
	"ØvreSeng"	INTEGER,
	"NedreSeng"	INTEGER,
	FOREIGN KEY("KupeNr") REFERENCES "Sovekupe"("KupeNr") ON DELETE CASCADE,
	FOREIGN KEY("SovevognSerieNr") REFERENCES "Sovevogn"("SovevognSerieNr") ON DELETE CASCADE,
	FOREIGN KEY("OrdreNr") REFERENCES "Kundeordre"("OrdreNr"),
	PRIMARY KEY("SovevognSerieNr","KupeNr","OrdreNr")
);