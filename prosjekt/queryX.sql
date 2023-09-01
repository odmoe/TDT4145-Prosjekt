SELECT Togrute.RuteID, Dag, Avgangstid --, DelstrekningID, Stasjon1, Stasjon2
                    FROM (Togrute INNER JOIN KjørerDag USING(RuteID) 
                        INNER JOIN GårInnom USING("RuteID")
                    WHERE ((Dag = "Mandag" AND Avgangstid > "06:30") OR Dag = "Tirsdag") AND StasjonNavn = "Mo i Rana" COLLATE NOCASE AND Avgangstid NOT NULL AND GårInnom.RuteID IN (
                        SELECT Togrute.RuteID
                        FROM GårInnom AS ankomst INNER JOIN Togrute USING(RuteID)
                        WHERE StasjonNavn = "Steinkjer" COLLATE NOCASE AND Ankomsttid NOT NULL)
                    ORDER BY Dag ASC, Avgangstid ASC;