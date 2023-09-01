--Script som legger inn data for de tre togrutene på Nordlandsbanen (Brukes kun for testing og ikke oppretting av DB)

--Innsetting i Togrute tabellen
INSERT INTO Togrute Values(1, 1);
INSERT INTO Togrute Values(2, 1);
INSERT INTO Togrute Values(3, 0);

--Innsetting i Ukedag tabellen (Ikke en del av de tre togrutene, men brukes i innsetting i KjørerDag tabellen under)
INSERT INTO Ukedag Values("Mandag");
INSERT INTO Ukedag Values("Tirsdag");
INSERT INTO Ukedag Values("Onsdag");
INSERT INTO Ukedag Values("Torsdag");
INSERT INTO Ukedag Values("Fredag");
INSERT INTO Ukedag Values("Lørdag");
INSERT INTO Ukedag Values("Søndag");

--Innsetting i KjørerDag tabellen
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

--Innsetting i GårInnom tabellen
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

--Innsetting i KjørerDelstrekning tabellen
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

--Innsetting i Sittevogn tabellen
INSERT INTO Sittevogn VALUES(1, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(2, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(3, "SJ-sittevogn-1");
INSERT INTO Sittevogn VALUES(4, "SJ-sittevogn-1");

--Innsetting i SittevognInfo tabellen
INSERT INTO SittevognInfo VALUES("SJ-sittevogn-1", "SJ", 3, 4);

--Innsetting i Sitteplass tabellen
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

--Innsetting i SittevognPåTog tabellen
INSERT INTO SittevognPåTog VALUES(1, 1, 1);
INSERT INTO SittevognPåTog VALUES(1, 2, 2);
INSERT INTO SittevognPåTog VALUES(2, 3, 1);
INSERT INTO SittevognPåTog VALUES(3, 4, 1);

--Innsetting i Sovevogn tabellen
INSERT INTO Sovevogn VALUES(1, "SJ-sovevogn-1");

--Innsetting i SovevognInfo tabellen
INSERT INTO SovevognInfo VALUES("SJ-sovevogn-1", 4, "SJ");

--Innsetting i Sovekupe tabellen
INSERT INTO Sovekupe VALUES(1, 1);
INSERT INTO Sovekupe VALUES(2, 1);
INSERT INTO Sovekupe VALUES(3, 1);
INSERT INTO Sovekupe VALUES(4, 1);

--Innsetting i SovevognPåTog tabellen
INSERT INTO SovevognPåTog VALUES(2, 1, 2);