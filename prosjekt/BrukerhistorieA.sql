--Script som legger inn data for Nordlandsbanen (Brukes kun for testing og ikke oppretting av DB)

--Innsetting i Stasjon tabellen
INSERT INTO Stasjon VALUES("Trondheim", 5.1);
INSERT INTO Stasjon VALUES("Steinkjer", 3.6);
INSERT INTO Stasjon VALUES("Mosjøen", 6.8);
INSERT INTO Stasjon VALUES("Mo i Rana", 3.5);
INSERT INTO Stasjon VALUES("Fauske", 34.0);
INSERT INTO Stasjon VALUES("Bodø", 4.1);

--Innsetting i Operatør tabellen
INSERT INTO Operatør Values("SJ");

--Innsetting i Strekning tabellen
INSERT INTO Strekning Values("Nordlandsbanen", "Diesel", "Trondheim", "Bodø");

--Innsetting i Delstrekning tabellen
INSERT INTO Delstrekning VALUES(1, "Nordlandsbanen", 120, 2, "Trondheim", "Steinkjer");
INSERT INTO Delstrekning VALUES(2, "Nordlandsbanen", 280, 1, "Steinkjer", "Mosjøen");
INSERT INTO Delstrekning VALUES(3, "Nordlandsbanen", 90, 1, "Mosjøen", "Mo i Rana");
INSERT INTO Delstrekning VALUES(4, "Nordlandsbanen", 170, 1, "Mo i Rana", "Fauske");
INSERT INTO Delstrekning VALUES(5, "Nordlandsbanen", 60, 1, "Fauske", "Bodø");

--Innsetting i BetjenerStrekning tabellen
INSERT INTO BetjenerStrekning Values("Sj", "Nordlandsbanen");