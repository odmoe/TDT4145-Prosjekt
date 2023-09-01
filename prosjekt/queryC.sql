-- SELECT GårInnom.RuteID, GårInnom.StasjonNavn, GårInnom.Avgangstid, KjørerDag.Dag
-- FROM GårInnom
-- JOIN KjørerDag
-- ON GårInnom.RuteID = KjørerDag.RuteID;
-- -- WHERE StasjonNavn = 'Trondheim' AND Dag = 'Mandag';


--SELECT GårInnom.RuteID, GårInnom.StasjonNavn, GårInnom.Avgangstid, KjørerDag.Dag, 
--FROM GårInnom, KjørerDag
--WHERE Gårinnom.RuteID = KjørerDag.RuteID
--AND StasjonNavn = 'Steinkjer' AND Dag = 'Fredag' AND Avgangstid NOT NULL;

SELECT Togrute.RuteID, Avgangstid, Retning
FROM ((GårInnom 
INNER JOIN Togrute using(RuteID)) 
INNER JOIN Kjørerdag using(RuteID)) 
--WHERE StasjonNavn = 'Trondheim' AND Dag = 'Fredag' AND Avgangstid NOT NULL
ORDER BY Retning DESC;