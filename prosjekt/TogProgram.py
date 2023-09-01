import sys
import sqlite3
import re
from datetime import date, datetime, time, timedelta

run = True
dager = ["Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag", "Lørdag", "Søndag"]

def stoppProgram(): #Stopper programmet hvis brukeren ønsker å avslutte
    print("\nTakk for at du brukte Tog booking for Norge. Du vil nå logges ut.")
    con.close()
    sys.exit(1)
    
def sjekkStopp(input): #Sjekker om brukeren ønsker å avslutte programmet
    if input == "":
        stoppProgram()
    return input

def sjekkEpost(epost): #Sjekker om epost har riktig format
    format = "^\S+@\S+\.\S+$"
    if re.match(format, epost):
        return True
    return False

def sjekkMobilnummer(mobilnummer): #Sjekker om mobilnummer har riktig format
    format = r"[0-9]{8}"
    if re.match(format, mobilnummer):
        return True
    return False

def leggTilNyKunde(navn, epost, mobilnummer): #Legger til ny kunde i databasen
    #Spørringen finner antall kundenummer og gir det neste ledige
    kundeNr = int(cursor.execute("SELECT COUNT(KundeNr) FROM Kunde").fetchone()[0]) + 1 
    cursor.execute('''INSERT INTO Kunde Values(?, ?, ?, ?)''', (kundeNr, navn, epost, mobilnummer))
    con.commit()
    
    print("\nVelkommen til oss som kunde. Vi har registrert følgende informasjon:")
    print(f"Navn: {navn} \nEpostaddresse: {epost} \nMobilnummer: {mobilnummer}")
    print(f"Ditt kundenummer er: {kundeNr}. Dette brukes for innlogging i programmet.")
    return kundeNr
    
def henteEksisterendeKunde(kundeNr): #Henter ut eksisterende kunde/Sjekker at kunden finnes
    #Spørringen henter ut Kunde ved bruk av Kundenummer
    kunde = cursor.execute("SELECT * FROM Kunde WHERE KundeNr = ? COLLATE NOCASE", (kundeNr,)).fetchone()
    if kunde == None:
        print("\nKundeNr finnes ikke i vår database. Sjekk at du har skrevet det inn riktig")
        return False
    else:
        print(f"\nVelkommen tilbake {kunde[1]}!")
        return True

def henteStasjon(stasjon, ukedag): #Henter ut alle togruter som går innom stasjonen på en gitt ukedag
    #Spøringen henter ut stasjonen hvis den eksisterer
    valgtStasjon = cursor.execute("SELECT StasjonNavn FROM Stasjon WHERE StasjonNavn = ? COLLATE NOCASE", (stasjon,)).fetchone()
    if valgtStasjon == None:
        print("\nStasjonen finnes ikke. Sjekk om du har skrevet inn riktig")
        return []
    else:
        #Spørringen henter ut Togruter som går innom stasjonen, Avgangstiden og hvilken endestasjon den går mot (For Nordlandsbanen er det Trondheim og Bodø)
        ruterQuery = '''SELECT DISTINCT Togrute.RuteID, Avgangstid, Endestasjon AS Retning 
                    FROM (GårInnom INNER JOIN Togrute USING(RuteID)
                        INNER JOIN KjørerDelstrekning USING(RuteID)
                        INNER JOIN Strekning USING(StrekningNavn)
                        INNER JOIN Kjørerdag using(RuteID)) 
                    WHERE StasjonNavn = ? COLLATE NOCASE AND Dag = ? COLLATE NOCASE AND Retning = 1
                    UNION
                    SELECT DISTINCT Togrute.RuteID, Avgangstid, Startstasjon AS Retning 
                    FROM (GårInnom INNER JOIN Togrute USING(RuteID)
                        INNER JOIN KjørerDelstrekning USING(RuteID)
                        INNER JOIN Strekning USING(StrekningNavn)
                        INNER JOIN Kjørerdag using(RuteID)) 
                    WHERE StasjonNavn = ? COLLATE NOCASE AND Dag = ? COLLATE NOCASE AND Retning = 0
                    ORDER BY Retning ASC, Avgangstid ASC;'''
        return cursor.execute(ruterQuery, (stasjon, ukedag, stasjon, ukedag)).fetchall()

def henteTogruter(start, stopp, Idag, Imorgen, tid): #Henter ut togruter som kjører den gitte strekning en gitt dag eller neste dag
    #Spørringen henter ut retningen som ruten ville gått i basert på kun de to stasjonene som er oppgitt
    sjekkRetningQuery = '''SELECT DelstrekningID
                            FROM Delstrekning
                            WHERE Stasjon1 = ? COLLATE NOCASE OR Stasjon2 = ? COLLATE NOCASE
                            GROUP BY StrekningNavn
                            HAVING DelstrekningID < (
                                SELECT DelstrekningID
                                FROM Delstrekning
                                WHERE Stasjon1 = ? COLLATE NOCASE OR Stasjon2 = ? COLLATE NOCASE
                                GROUP BY StrekningNavn
                                HAVING DelstrekningID = MAX(DelstrekningID));'''
    if cursor.execute(sjekkRetningQuery, (start, start, stopp, stopp)).fetchone() != None:
        retning = 1
    else:
        retning = 0
    
    #Spørringen henter ut informasjon om alle togruter som kjører senere på den oppgitte dagen eller neste dag
    togQuery = '''SELECT Togrute.RuteID, Dag, Avgangstid
                    FROM (Togrute INNER JOIN KjørerDag USING(RuteID) 
                        INNER JOIN GårInnom USING("RuteID"))
                    WHERE ((Dag = ? AND Avgangstid > ?) OR Dag = ?) AND StasjonNavn = ? COLLATE NOCASE AND Avgangstid NOT NULL AND Retning = ? AND GårInnom.RuteID IN (
                        SELECT Togrute.RuteID
                        FROM GårInnom AS ankomst INNER JOIN Togrute USING(RuteID)
                        WHERE StasjonNavn = ? COLLATE NOCASE AND Ankomsttid NOT NULL)
                    ORDER BY Dag ASC, Avgangstid ASC;'''
    togruter = cursor.execute(togQuery, (dager[Idag.weekday()], str(tid), dager[Imorgen.weekday()], start, retning, stopp)).fetchall() 
    gyldigeTog = []
    for tog in togruter:
        rute = list(tog)
        rute.append(cursor.execute("SELECT Ankomsttid FROM GårInnom WHERE RuteID = ? AND StasjonNavn = ? COLLATE NOCASE", (int(tog[0]), stopp)).fetchone()[0])
        gyldigeTog.append(rute)
    return gyldigeTog

def hentTypeTogvogner(RuteID): #Henter ut og lar evt. brukeren velge hva slags type plass den vil kjøpe
    #Spørringene sjekker om toget har minst en av hhv. Sittevogn og Sovevogn
    harSittevogn = cursor.execute("SELECT * FROM SittevognPåTog WHERE RuteID = ?", (RuteID,)).fetchone()
    harSovevogn = cursor.execute("SELECT * FROM SovevognPåTog WHERE RuteID = ?", (RuteID,)).fetchone()
    if harSittevogn != None and harSovevogn != None:
        return input("\nPå toget kan du velge mellom sitteplasser (Skriv: sitte) og sovekupeer (Skriv: sove): ").lower()
    elif harSittevogn != None:
        print("\nToget har kun sitteplasser:")
        return "sitte"
    elif harSovevogn != None:
        print("\nToget har kun sovevogner: ")
        return "sove"
    else:
        print("\nToget har ingen vogner")
        return ""

def hentLedigePlasserPåTog(RuteID, dato, start, stopp, uke): #Henter ut ledige plasser på toget
    vogntype = hentTypeTogvogner(RuteID)
    if vogntype == "sitte":
        #Spørringen henter ut informasjon om alle plasser på toget og hvilke delstrekninger de er ledige på
        plasserQuery = '''SELECT Delstrekning.Stasjon1, Delstrekning.Stasjon2, Delstrekning.DelstrekningID, SittevognSerieNr, Plass, Retning, VognNr
                    FROM (Togrute INNER JOIN KjørerDelstrekning USING(RuteID) 
                        INNER JOIN KjørerDag USING (RuteID)
                        INNER JOIN Delstrekning USING (DelstrekningID)
                        INNER JOIN SittevognPåTog USING (RuteID)
                        INNER JOIN Sitteplass USING (SittevognSerieNr))
                    WHERE RuteID = ? AND Dag = ? COLLATE NOCASE
                    EXCEPT
                    SELECT Delstrekning.Stasjon1, Delstrekning.Stasjon2, Delstrekning.DelstrekningID, ReservertPlass.SittevognSerieNr, ReservertPlass.Plass, Retning, VognNr
                    FROM (Kundeordre INNER JOIN ReservertPlass USING (OrdreNr)
                        INNER JOIN KjørerDelstrekning USING (RuteID)
                        INNER JOIN Togrute USING(RuteID)
                        INNER JOIN SittevognPåTog USING(RuteID)
                        INNER JOIN Delstrekning USING (DelstrekningID)
                        INNER JOIN KjørerDag USING (RuteID))
                    WHERE Kundeordre.Reisedag = KjørerDag.Dag AND ReservertPlass.DelstrekningID = KjørerDelstrekning.DelstrekningID AND Kundeordre.UkeNr = ? AND Dag = ? COLLATE NOCASE
                    ORDER BY SittevognSerieNr ASC, Plass ASC, Delstrekning.DelstrekningID ASC;'''
        plasser = cursor.execute(plasserQuery, (RuteID, dager[dato.weekday()], uke, dager[dato.weekday()])).fetchall()
        gyldigePlasser = {}
        rad = 0
        if plasser != None and int(plasser[0][5]) == 1: #Finner plasser for Tog som kjører med hovedretningen
            while rad < len(plasser):
                if (plasser[rad][0]).lower() == start.lower():
                    sjekk = rad
                    while sjekk < len(plasser) and plasser[sjekk][4] == plasser[rad][4]:
                        if (plasser[sjekk][1]).lower() == stopp.lower():
                            if plasser[rad][3] in gyldigePlasser:
                                gyldigePlasser[plasser[rad][3]].append(plasser[rad][4])
                            else:
                                gyldigePlasser.update({plasser[rad][3]: [plasser[rad][4]]})
                            rad = sjekk
                            break
                        
                        if int(plasser[sjekk][2]) != int(plasser[sjekk + 1][2]) - 1:
                            print(plasser[sjekk][2], plasser[sjekk - 1][2])
                            rad = sjekk
                            break
                        sjekk += 1
                rad += 1
        elif plasser != None and int(plasser[0][5]) == 0: #Finner plasser for Tog som kjører mot hovedretningen
            while rad < len(plasser):
                if (plasser[rad][1]).lower() == start.lower():
                    sjekk = rad
                    while sjekk >= 0 and plasser[sjekk][4] == plasser[rad][4]:
                        if (plasser[sjekk][0]).lower() == stopp.lower():
                            if plasser[rad][3] in gyldigePlasser:
                                gyldigePlasser[plasser[rad][3]].append(plasser[rad][4])
                            else:
                                gyldigePlasser.update({plasser[rad][3]: [plasser[rad][4]]})
                            rad += 1
                            break
                        
                        if int(plasser[sjekk][2]) != int(plasser[sjekk - 1][2]) + 1:
                            rad = sjekk
                            break
                        sjekk -= 1
                rad += 1
        return gyldigePlasser, vogntype
    elif vogntype == "sove":
        #Spørringen henter ut alle kupeer som er ledige for en togrute
        kupeerQuery = '''SELECT DISTINCT SovevognSerieNr, KupeNr, VognNr
                        FROM KjørerDag INNER JOIN SovevognPåTog USING (RuteID)
                            INNER JOIN Sovekupe USING (SovevognSerieNr)
                        WHERE RuteID = ? AND Dag = ?
                        EXCEPT
                        SELECT SovevognSerieNr, KupeNr, VognNr
                        FROM ReservertKupe INNER JOIN SovevognPåTog USING(SovevognSerieNr)
                            INNER JOIN Kundeordre USING (OrdreNr)
                            INNER JOIN KjørerDag USING (RuteID)
                        WHERE Kundeordre.Reisedag = KjørerDag.Dag AND Kundeordre.UkeNr = ? AND Kundeordre.Reisedag = ?'''
        kupeer = cursor.execute(kupeerQuery, (RuteID, dager[dato.weekday()], uke, dager[dato.weekday()])).fetchall()
        gyldigeKupeer = {}
        for kupe in kupeer:
            if kupe[0] in gyldigeKupeer:
                gyldigeKupeer[kupe[0]].append(kupe[1])
            else:
                gyldigeKupeer.update({kupe[0]: [kupe[1]]})
        return gyldigeKupeer, vogntype
    else:
        return []
    
def kjøpPlasser(vogntype, togrute, valgtePlasser, kundenr, dag, uke, år, start, slutt):
    ordrenr = int(cursor.execute('''SELECT COUNT(OrdreNr) FROM Kundeordre;''').fetchone()[0]) + 1
    dato = (f"{datetime.now().strftime('%d.%m.%y')}")
    klokkeslett = f"{datetime.now().strftime('%H:%M')}"
    kundeordre = '''INSERT INTO Kundeordre VALUES(?,?,?,?,?,?,?,?);'''
    cursor.execute(kundeordre, (ordrenr, dato, klokkeslett, int(kundenr), togrute[0], dag, int(uke), int(år)))
    con.commit()
    if vogntype == "sitte":
        plasskjøp = 'INSERT INTO ReservertPlass VALUES(?,?,?,?);'
        finndelstrekning = '''SELECT Retning, DelstrekningID
                                FROM KjørerDelstrekning INNER JOIN Togrute USING (RuteID)
                                INNER JOIN Delstrekning USING (DelstrekningID)
                                WHERE RuteID = ? AND Stasjon1 = ? COLLATE NOCASE
                                UNION
                                SELECT Retning, DelstrekningID
                                FROM KjørerDelstrekning INNER JOIN Togrute USING (RuteID)
                                INNER JOIN Delstrekning USING (DelstrekningID)
                                WHERE RuteID = ? AND Stasjon2 = ? COLLATE NOCASE;'''
        retningssøk = '''SELECT Retning FROM Togrute WHERE RuteID = ?;'''
        retning = int(cursor.execute(retningssøk, (togrute[0],)).fetchone()[0])
        if retning == 1:
            fratil = cursor.execute(finndelstrekning, (togrute[0], start, togrute[0], slutt)).fetchall()
        else:
            fratil = cursor.execute(finndelstrekning, (togrute[0], slutt, togrute[0], start)).fetchall()
        
        for plass in valgtePlasser:
            plassogvogn = plass.split('.')
            if len(fratil) == 1:
                cursor.execute(plasskjøp, (ordrenr, int(fratil[0][1]), int(plassogvogn[1]), int(plassogvogn[0]) ))
                con.commit()
            else:
                for i in range(int(fratil[0][1]), int(fratil[1][1]) + 1):
                    cursor.execute(plasskjøp, (ordrenr, i, int(plassogvogn[1]), int(plassogvogn[0]) ))
                    con.commit() 
        print("Suksessfullt kjøp av plasser!")
    else:
        plasskjøp = 'INSERT INTO ReservertKupe VALUES(?,?,?,?,?);'
        for plass in valgtePlasser:
            plassogvogn = plass.split('.')
            seng = input(sjekkStopp("Ønsker du seng oppe (Skriv: oppe), nede (Skriv: nede) eller begge (Skriv: begge). Du vil uansett booke hele kupeen for hele turen: ")).lower()
            if seng == "oppe":
                cursor.execute(plasskjøp, (ordrenr, int(plassogvogn[1]), int(plassogvogn[0]), 1, 0))
            elif seng == "nede":
                cursor.execute(plasskjøp, (ordrenr, int(plassogvogn[1]), int(plassogvogn[0]), 0, 1))
            elif seng == "begge":
                cursor.execute(plasskjøp, (ordrenr, int(plassogvogn[1]), int(plassogvogn[0]), 1, 1))
            else:
                cursor.execute(plasskjøp, ())
            con.commit() 
        print("Suksessfullt kjøp av kupeer!")

def hentKommendeBilletter(kundeNr, now):
    kommendePlasser = []
    #Spørringen finner alle sovekupeer som en Kunde har bestillt i kommende tid
    sovekupeerQuery = '''SELECT DISTINCT Kundeordre.OrdreNr, Kundeordre.Reisedag, Kundeordre.Dato, Kundeordre.Tid, Kundeordre.RuteID, Kundeordre.UkeNr, Kundeordre.År, ReservertKupe.KupeNr, VognNr, Startstasjon, Endestasjon, ØvreSeng, NedreSeng, Retning
                        FROM (Kundeordre INNER JOIN Kunde USING(KundeNr)
                            INNER JOIN ReservertKupe USING(OrdreNr)
                            INNER JOIN Sovekupe USING(SovevognSerieNr)
                            INNER JOIN Togrute USING(RuteID)
                            INNER JOIN SovevognPåTog USING(RuteID)
                            INNER JOIN KjørerDelstrekning USING(RuteID)
                            INNER JOIN Strekning USING(StrekningNavn))
                        WHERE KundeNr = ? AND År >= ? AND UkeNr >= ?
                        ORDER BY OrdreNr, VognNr, Sovekupe.KupeNr;'''
    sovekupeer = cursor.execute(sovekupeerQuery, (kundeNr, now.year, now.strftime("%V"))).fetchall()
    for kupe in sovekupeer:  
        if int(now.strftime("%V")) < int(kupe[5]) or (int(now.strftime("%V")) == int(kupe[5]) and now.weekday() <= dager.index(kupe[1])):  
            kommendePlasser.append(kupe)     
    
    #Spørringen finner alle sitteplasser som en kunde har bestilt og første og siste delstrekning for hvert sete                      
    sitteplasserQuery = '''SELECT DISTINCT Kundeordre.OrdreNr, Kundeordre.Reisedag, Kundeordre.Dato, Kundeordre.Tid, Kundeordre.RuteID, Kundeordre.UkeNr, Kundeordre.År, DelstrekningID, Stasjon1, ReservertPlass.Plass, VognNr, Retning
                            FROM (Kundeordre INNER JOIN Togrute USING(RuteID)
                                INNER JOIN SittevognPåTog USING(RuteID)
                                INNER JOIN Kunde USING(KundeNr)
                                INNER JOIN ReservertPlass USING(OrdreNr)
                                INNER JOIN Delstrekning USING(DelstrekningID))
                            WHERE KundeNr = ? AND År >= ? AND UkeNr >= ?
                            GROUP BY ReservertPlass.Plass, VognNr, OrdreNr
                            HAVING ReservertPlass.DelstrekningID = MIN(ReservertPlass.DelstrekningID)
                            UNION
                            SELECT DISTINCT Kundeordre.OrdreNr, Kundeordre.Reisedag, Kundeordre.Dato, Kundeordre.Tid, Kundeordre.RuteID, Kundeordre.UkeNr, Kundeordre.År, DelstrekningID, Stasjon2, ReservertPlass.Plass, VognNr, Retning
                            FROM (Kundeordre INNER JOIN Togrute USING(RuteID)
                                INNER JOIN SittevognPåTog USING(RuteID)
                                INNER JOIN Kunde USING(KundeNr)
                                INNER JOIN ReservertPlass USING(OrdreNr)
                                INNER JOIN Delstrekning USING(DelstrekningID))
                            WHERE KundeNr = ? AND År >= ? AND UkeNr >= ?
                            GROUP BY ReservertPlass.Plass, VognNr, OrdreNr
                            HAVING ReservertPlass.DelstrekningID = MAX(ReservertPlass.DelstrekningID)
                            ORDER BY OrdreNr, VognNr, Plass;'''
    sitteplasser = cursor.execute(sitteplasserQuery, (kundeNr, now.year, now.strftime("%V"), kundeNr, now.year, now.strftime("%V"))).fetchall()
    for i in range(0, len(sitteplasser) - 1, 2):
        if int(now.strftime("%V")) < int(sitteplasser[i][5]) or (int(now.strftime("%V")) == int(sitteplasser[i][5]) and now.weekday() <= dager.index(sitteplasser[i][1])) and sitteplasser[i][10] == sitteplasser[i + 1][10] and sitteplasser[i][9] == sitteplasser[i + 1][9]:
            plass = list(sitteplasser[i])
            plass.insert(9, sitteplasser[i + 1][8])
            kommendePlasser.append(plass) 
    return kommendePlasser

while run: #Hovedprogram
    con = sqlite3.connect("togdata.db")
    cursor = con.cursor()
    
    print("\n+--------------------------------------------------------------------------------------+")
    print("|                     Hei, og velkommen til Tog booking for Norge!                     |")
    print("+---------------------------------------------+----------------------------------------+")
    print("| Du kan når som helst avslutte programmet ved å skrive inn en tom streng/Trykke enter |")
    print("|     Alle inputs som stasjoner, ukedager og operasjoner er uavhengig av Caps Lock     |")
    print("+--------------------------------------------------------------------------------------+")
    
    typeKunde = ""
    while typeKunde != "nk" and typeKunde != "ek": #Løkke for å logge inn eksisterende kunde eller opprette ny kunde
        typeKunde = sjekkStopp(input("\nEr du Ny Kunde (Skriv: nk) eller er du Eksisterende Kunde (Skriv: ek): ").lower())
        if typeKunde == "nk": 
            navn = sjekkStopp(input("Hva er navnet ditt?: "))
            epost = sjekkStopp(input("Hva er epostaddressen din? (Må være på format: bruker@domene.landskode): "))
            while not sjekkEpost(epost):
                print("Ikke en gyldig epost. Eposten må være på format: bruker@domene.landskode")
                epost = sjekkStopp(input("Hva er epostaddressen din? (Må være på format: bruker@domene.landskode): "))
                sjekkEpost(epost)
            mobilnummer = sjekkStopp(input("Hva er mobilnummeret ditt? (Må være et norsk nummer med 8 siffer): "))
            while not sjekkMobilnummer(mobilnummer):
                print("Ikke et gyldig mobilnummer. Mobilnummer må være et norsk nummer med 8 siffer")
                mobilnummer = sjekkStopp(input("Hva er mobilnummeret ditt? (Mobilnummer må være et norsk nummer med 8 siffer): "))
                sjekkMobilnummer(mobilnummer)
            if typeKunde != "Prøv igjen":
                kundeNr = leggTilNyKunde(navn, epost, mobilnummer)
        elif typeKunde == "ek":
            kundeNr = sjekkStopp(input("Hva er ditt kundenummer?: "))
            if not henteEksisterendeKunde(kundeNr):
                typeKunde = "Prøv igjen"
        else:
            print("Ikke et gyldig input. Sjekk om du har skrevet inn riktig")
    
    operasjon = ""      
    while operasjon != "stasjon" and operasjon != "togrute" and operasjon != "billetter": #Hovedløkke for å utføre operasjoner.
        operasjon = sjekkStopp(input("\nVelg operasjon: Se togruter som går innom en stasjon (Skriv: stasjon), \nvelg start/stopp for å finne togruter og bestille billetter (Skriv: togrute) \neller finn dine kjøpte billetter (Skriv: billetter): ").lower())
        if operasjon == "stasjon": #Får ut informasjon om tog for en stasjon
            stasjon = sjekkStopp(input("\nSkriv inn navnet på stasjonen (Eksempelvis: Trondheim): "))
            ukedag = sjekkStopp(input("Hvilken ukedag skal du reise på (Eksempelvis: Mandag): "))
            
            stasjonInfo = henteStasjon(stasjon, ukedag)
            if len(stasjonInfo) > 0:
                print(f"\nTogrutene som går innom {stasjon} på en {ukedag}")
                print("+------------------------------------------------------+")
                for tog in stasjonInfo:
                    if tog[1] != None:
                        print(f"Tog med ID: {tog[0]}, Kl: {tog[1]}, Retning: {tog[2]}")  
                    else:
                       print(f"Tog med ID: {tog[0]}, Endestasjon for toget (Ingen Påstigning)") 
                print("+------------------------------------------------------+")
            else:
                print(f"\nDet finnes ingen togruter som går innom {stasjon} på en {ukedag}")
        elif operasjon == "togrute": #Får ut informasjon om togruten som kjører den ruten
            startstasjon = sjekkStopp(input("\nSkriv inn startstasjon for turen (Eksempelvis: Trondheim): "))
            endestasjon = sjekkStopp(input("Skriv inn endestasjon for turen (Eksempelvis: Fauske): "))
            try:
                dag = sjekkStopp(input("Hvilken dato vil du reise (Skriv: DD:MM:YYYY): ").split(":"))
                klokkeslett = sjekkStopp(input("Hvilket klokkeslett vil du reise (Skriv: HH:MM): ").split(":"))
                Idag = date(year=int(dag[2]), month=int(dag[1]), day=int(dag[0]))
                Imorgen = datetime(year=int(dag[2]), month=int(dag[1]), day=int(dag[0])) + timedelta(1)
                togtid = time(hour=int(klokkeslett[0]), minute=int(klokkeslett[1]))
                tid = togtid.strftime('%H:%M')
                
                togruter = henteTogruter(startstasjon, endestasjon, Idag, Imorgen, tid)
                if len(togruter) > 0:
                    print(f"\nFølgende tog tar deg fra {startstasjon} til {endestasjon} på {dager[Idag.weekday()]} eller {dager[Imorgen.weekday()]}")
                    print("+----------------------------------------------------------------------------+")
                    for i in range(len(togruter)):
                        if dager.index(togruter[i][1]) == Idag.weekday():
                            print(f"Forekomst {i + 1}: Tog med ID: {togruter[i][0]}, Dag: {togruter[i][1]}, Avgangstid: {togruter[i][2]}, Ankomsttid: {togruter[i][3]}")
                    for i in range(len(togruter)):
                        if dager.index(togruter[i][1]) == Imorgen.weekday():
                            print(f"Forekomst {i + 1}: Tog med ID: {togruter[i][0]}, Dag: {togruter[i][1]}, Avgangstid: {togruter[i][2]}, Ankomsttid: {togruter[i][3]}")
                    print("+----------------------------------------------------------------------------+")
    
                    valgtRute = sjekkStopp(int(input("Velg en ruteforekomst utifra indeksen på togrutetabellen (Eksempelvis Forekomst 3, Skriv: 3): ")))
                    if dager.index(togruter[valgtRute - 1][1]) == Idag.weekday():
                        ledigePlasser, vogntype = hentLedigePlasserPåTog(togruter[valgtRute - 1][0], Idag, startstasjon, endestasjon, Idag.strftime("%V"))
                    else:
                        ledigePlasser, vogntype = hentLedigePlasserPåTog(togruter[valgtRute - 1][0], Imorgen, startstasjon, endestasjon, Imorgen.strftime("%V"))
                    print("+----------------------------------------------------------------------+")
                    if len(ledigePlasser) > 0:
                        for key, val in ledigePlasser.items():
                            if vogntype == "sitte":
                                vognnr = int(cursor.execute('''SELECT VognNr FROM SittevognPåTog WHERE SittevognSerieNr = ?;''', (key,)).fetchone()[0])
                                print(f"Vogn {vognnr}: Seter {val}")
                            else:
                                vognnr = int(cursor.execute('''SELECT VognNr FROM SovevognPåTog WHERE SovevognSerieNr = ?;''', (key,)).fetchone()[0])
                                print(f"Vogn {vognnr}: Kupe {val}")
                    else:
                        print("Ingen ledige plasser for denne ruten")
                        break
                    print("+----------------------------------------------------------------------+")
                    valgtePlasser = sjekkStopp(input("Skriv inn vogn og plass du ønsker, separert med punktum og komma (Eksempelvis 1.3,1.4,1.7 for plass 3,4,7 i vogn 1): ").split(","))
                    if vogntype == "sitte":
                        for i in range(len(valgtePlasser)):
                            plass = valgtePlasser[i].split(".")
                            sete = plass[1]
                            sittevognserienr = int(cursor.execute('''SELECT SittevognSerieNr FROM SittevognPåTog WHERE RuteID = ? AND VognNr = ?;''', (togruter[valgtRute - 1][0], int(plass[0]))).fetchone()[0])
                            valgtePlasser[i] = f"{sittevognserienr}.{sete}"
                    else:
                        for i in range(len(valgtePlasser)):
                            plass = valgtePlasser[i].split(".")
                            kupe = plass[1]
                            sovevognserienr = int(cursor.execute('''SELECT SovevognSerieNr FROM SovevognPåTog WHERE RuteID = ? AND VognNr = ?;''', (togruter[valgtRute - 1][0], int(plass[0]))).fetchone()[0])
                            valgtePlasser[i] = f"{sovevognserienr}.{kupe}"
                
                    for plass in valgtePlasser:
                        if int(plass.split('.')[1]) not in ledigePlasser[int(plass[0])]:
                            print("Denne plassen finnes ikke, eller er ikke ledig")
                            break
                    if len(valgtePlasser) > 0: 
                        if dager.index(togruter[valgtRute - 1][1]) == Idag.weekday():
                            kjøpPlasser(vogntype, togruter[valgtRute - 1], valgtePlasser, kundeNr, dager[Idag.weekday()], Idag.strftime("%V"), dag[2], startstasjon, endestasjon)
                        else:
                            kjøpPlasser(vogntype, togruter[valgtRute - 1], valgtePlasser, kundeNr, dager[Imorgen.weekday()], Imorgen.strftime("%V"), dag[2], startstasjon, endestasjon)
                    else:
                        print("Du valgte ingen plasser")
                        break
                else:
                    print("\nIngen tog tilgjengelig for de valgte parameterne")
            except:
                print("Ikke riktig input på dag og klokkeslett eller du skrev inn en ugyldig forekomstindeks eller feil setevalg")            
        elif operasjon == "billetter": #Henter ut kommende billetter for en Kunde
            dato = sjekkStopp(input("\nØnsker du å bruke nåtid (Skriv: nå) eller ønsker du å bruke en simulert dato for testing? (Skriv: DD:MM:YYYY): ")).lower()
            if dato != "nå":
                try:
                    dato = dato.split(":")
                    dato = datetime(int(dato[2]), int(dato[1]), int(dato[0]), 0, 0)
                except:
                    print("\nUgyldig dato, OBS! : Dato vil bli satt til nåtid ved ugyldig input")
                    dato = datetime.now()
            else:
                dato = datetime.now()
                    
            billetter = hentKommendeBilletter(kundeNr, dato)
            if len(billetter) > 0:
                print("\nDine kommende billetter er:")
                print("+---------------------------------------------------------------------------------------------------------------------------------------------------+")
                for ordre in billetter:
                    if len(ordre) == 14: #Betyr at det er en sovekupe
                        start, stopp = ordre[9], ordre[10]
                        if int(ordre[13]) == 0:
                            start, stopp = stopp, start
                        if ordre[11] == 1 and ordre[12] == 1:
                            senger = "begge senger"
                        elif ordre[11] == 1:
                            senger = "øvre seng"
                        else:
                            senger = "nedre seng"
                            
                        print(f"Kundeordre: {ordre[0]} for Tog med ID: {ordre[4]}, Reise: {start} --> {stopp} på {ordre[1]} i uke {ordre[5]} {ordre[6]}. Vogn: {ordre[8]}, Sovekupe: {ordre[7]}, {senger}. Bestilt: {ordre[2]} {ordre[3]}") 
                    else: #Betyr at det er en sitteplass
                        start, stopp = ordre[8], ordre[9]
                        if int(ordre[12]) == 0 and cursor.execute("SELECT * FROM Delstrekning WHERE Stasjon1 = ? AND Stasjon2 = ?", (stopp, start)).fetchone() == None: #Spørringen tester edge case for om stasjonene ligger inntil hverandre (Kun en delstrekning mellom når toget går mot hovedretningen)
                            start, stopp = stopp, start
                        print(f"Kundeordre: {ordre[0]} for Tog med ID: {ordre[4]}, Reise: {start} --> {stopp} på {ordre[1]} i uke {ordre[5]} {ordre[6]}. Vogn: {ordre[11]}, Plass: {ordre[10]}. Bestilt: {ordre[2]} {ordre[3]}")
                print("+---------------------------------------------------------------------------------------------------------------------------------------------------+")
            else:
                print("\nIngen kommende billetter er registrert på deg som kunde")
        else:
            print("\nIkke et gyldig input. Sjekk om du har skrevet inn riktig")

        fortsette = sjekkStopp(input("\nØnsker du å fortsette? (Skriv Y/N): ")).lower()
        if fortsette == "n":
            stoppProgram()
        else:
            operasjon = "Prøv igjen"
    
    con.close()
    run = False
