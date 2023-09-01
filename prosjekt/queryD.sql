-- SELECT GårInnom.RuteID, GårInnom.StasjonNavn, GårInnom.Ankomsttid, GårInnom.Avgangstid, KjørerDag.Dag
-- FROM GårInnom
-- JOIN KjørerDag
-- ON KjørerDag.RuteID = GårInnom.RuteID
-- ORDER BY Dag, Avgangstid;

SELECT GårInnom.RuteID, GårInnom.StasjonNavn, GårInnom.Avgangstid, KjørerDag.Dag, Togrute.Retning
FROM ((GårInnom 
    INNER JOIN Togrute using(RuteID)) 
    INNER JOIN Kjørerdag using(RuteID)) 
WHERE StasjonNavn AS start = 'Steinkjer' AND StasjonNavn AS slutt = AND Dag = 'Fredag'
ORDER BY Retning DESC, Dag, Avgangstid ;