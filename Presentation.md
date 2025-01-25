1. Presentera oss själva. 
2. Planering och uppbyggnad av projektet. Indelning i delfiler och deluppgifter, med hjälp av github.
3. Delade upp koden i mindre funktioner. 
4. Bestämde oss för att använda dialog.
5. Byggde upp undermenyer och huvudmeny på samma sätt med en loopad struktur. Behöver trycka på avbryt.
6. Omhändertog felmedellanden och formaterade felrutor så det ser likadant ut överallt. 
7. Byggde ihop Directory view och modify.

Uppdelning program:
    - Generellt:
    Input från användare om en grupp och användar kollas alltid om den finns innan ett kommando körs. 
    Det görs alltid en koll om dialog rutan vid input har gått igenom OK eller om användare tryckt på avbryt.
    User kollas i /etc/passwd, group i /etc/group. Exitcodes kollas med $?.
    Exitcodes kollas efter dialogrutor. Kollas när vi söker upp användare/grupper. Efter kommandon är körda.
    GID/UID >= 1000 && GID/UID <= 60000 är systemanvändare/systemgrupper.

    - Network information:
    Datorns namn skrivs ut på skärmen och all information om datorns nätverksinterface skrivs ut med hjälp av loop.
    Datornamn skrivs ut med kommando hostname.
    Namn på alla nätverkskort nås genom att kolla i /sys/class/net.
    Hittar IP-address och status med ip addr show.
    Gateway nås genom ip route kommandot.
    Mac adress nås i filen /sys/class/net/$namn/address.

    - Group management: 
    Meny som är strukturerad på samma sätt som huvudmenyn. 
    Add group så får användare mata in gruppnamn. Kollar i /etc/group så att den inte redan finns. groupadd $group. Felkoder.
    List group lägger vi alla användarskapade grupper i /etc/group och formaterar det med hjälp av en loop ut på skärmen.
    View group listar alla medlemmar och skriver även GID. Om användare i /etc/passwd har den som primärgrupp läggs hen till.
    Add user lägger till en användare i en grupp och tar hand om eventuella felkoder. Redan i grupp, grupp/användare fel etc.
    Remove user uppbyggd på samma sätt fast här tar vi bort en användare istället. deluser vs usermod -aG
    Change GID ändrar grupp id på grupp. Ser till att alla medlammar i den gruppen också följer med. 
    Delete group ser till så att bara användarskapade grupper tas bort. GID >= 1000 && GID <= 60000.

    - User management:
    Även här en meny som är strukturerad på samma sätt som huvudmenyn.
    Skapar användare genom att be om namn och lösenord. Krypterat lösenord görs med openssl och skickas när useradd körs.
    List users skriver ut alla icke systemanvändare formatterat med en loop på skärmen. 
    View user skriver ut all information som finns i /etc/passwd formaterat på ett snyggt sätt och grupper hen är medlem i. 
    Modify user visar en ny undermeny där man får välja vilket attribut i /etc/passwd som ska ändras. 
    Alla attribut från /etc/password kan ändras och felkoder tas hand om.
    Delete user tar bort en användare och ger felkod om det inte gick igenom.

    - Directory management: 
    Visar en ny undermeny strukturerad på samma sätt som huvudmenyn. 
    Add directory får man först leta upp vart man vill skapa ny mapp med hjälp av dialogs dselect. Sen skriva mappnamn.
    List directory använder vi dialogs fselect för att visa all information i en mapp och låta användare röra sig runt.
    View/modify skriver ut all information om en mapp. All information från "ls $PATH" formatteras om och skrivs ut.
        Modify delen kommer man till om man klickar på change. En ny undermeny visas. Permissions ändras med hjälp av en buildlist i dialog där användare får checka exakt de permissions de vill ska sättas. 
    Delete directory får användare välja mapp med fselect sedan tas den bort om man inte trycker avbryt.