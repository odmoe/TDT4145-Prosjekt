-- SELECT DISTINCT Dato, Tid, RuteID, Reisedag, UkeNr, År, KupeNr, SovevognSerieNr, DelstrekningID, Plass, SittevognSerieNr
-- FROM Kundeordre
-- JOIN Kunde
-- ON Kundeordre.KundeNr = Kunde.KundeNr
-- JOIN ReservertKupe
-- ON ReservertKupe.OrdreNr = Kundeordre.OrdreNr
-- JOIN ReservertPlass;
-- WHERE KundeNr = 1;
--ORDER 




SELECT DISTINCT Kunde.KundeNr, Kundeordre.OrdreNr, Kundeordre.Reisedag, Kundeordre.Dato, Kundeordre.Tid, Kundeordre.RuteID, Kundeordre.UkeNr, Kundeordre.År, ReservertKupe.KupeNr, ReservertKupe.SovevognSerieNr, Sovekupe.ØvreSeng, Sovekupe.NedreSeng
FROM ((Kundeordre
    INNER JOIN Kunde USING(KundeNr))
    INNER JOIN ReservertKupe USING(OrdreNr)
    INNER JOIN Sovekupe USING(SovevognSerieNr));
-- WHERE KundeNr = 1
-- ORDER BY OrdreNr, SovevognSerieNr, KupeNr;

-- SELECT DISTINCT Kunde.KundeNr, Kundeordre.OrdreNr, Kundeordre.Reisedag, Kundeordre.Dato, Kundeordre.Tid, Kundeordre.RuteID, Kundeordre.UkeNr, Kundeordre.År, ReservertPlass.DelstrekningID, ReservertPlass.Plass, ReservertPlass.SittevognSerieNr
-- FROM ((Kundeordre
--     INNER JOIN Kunde USING(KundeNr))
--     INNER JOIN ReservertPlass USING(OrdreNr))
-- WHERE KundeNr = 1
-- ORDER BY OrdreNr, SittevognSerieNr, Plass, DelstrekningID;