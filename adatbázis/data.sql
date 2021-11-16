INSERT INTO `vasarlo` (`nev`,`email`,`jelszo`,`csatlakozas_datuma`)
VALUES
  ("Kane Gonzales","aliquam.eros@turpisnec.net","NST16DMC1OQ","Jan 13, 2021"),
  ("Vernon Hewitt","molestie.sodales@natoquepenatibuset.co.uk","KNP01PRN6AV","Jan 11, 2021"),
  ("Dara Freeman","metus.in@namac.co.uk","RHF39JQC2GE","Aug 16, 2022"),
  ("Garrett Haney","molestie.tortor.nibh@tortornunccommodo.com","WJT15VKJ5FC","Dec 24, 2020"),
  ("Evelyn Blackwell","turpis.vitae@consectetuer.com","EDM82OCP9MQ","Feb 6, 2022");
  
INSERT INTO `szallitasi_cim` (`vasarloID`,`megnevezes`,`telefonszam`,`orszag`,`megye`,`varos`,`utca_hazszam`,`iranyitoszam`)
VALUES
  (5,"mollis.","1-515-414-6243","Germany","Phú Thọ","Develi","P.O. Box 703, 2944 Vulputate Road","91864"),
  (3,"sed","1-177-255-9675","France","Caquetá","Niort","Ap #160-5600 Vitae Rd.","51526-487"),
  (5,"convallis","(418) 222-8675","France","South Island","Wals-Siezenheim","P.O. Box 692, 3683 Tempor Rd.","3872"),
  (2,"lacus.","(367) 883-2825","China","Poitou-Charentes","Sudhanoti","P.O. Box 558, 6486 Quam St.","G6H 5E2"),
  (3,"egestas","(801) 951-1405","Italy","Dalarnas län","Paillaco","Ap #513-3835 Dui St.","53214-80577");
  
INSERT INTO `arus` (`nev`,`email`,`jelszo`,`telefonszam`,`bemutatkozas`,`csatlakozas_datuma`)
VALUES
  ("Amity Anderson","rutrum.lorem@odionaminterdum.org","XZO81YRB5ED","1-210-851-4203","ac urna. Ut tincidunt vehicula risus. Nulla","Aug 16, 2021"),
  ("Aquila Cabrera","nunc.lectus@proin.ca","JQD36DAM3ND","1-175-545-5833","ligula consectetuer rhoncus. Nullam velit","Jun 10, 2021"),
  ("Felix Lloyd","donec.felis.orci@nullamscelerisque.ca","DMC73JQO4YP","(723) 432-0154","Nunc","Feb 21, 2021"),
  ("Octavius Whitley","nunc.mauris@ipsumsuspendisse.org","INF74GCI4GW","1-582-337-4820","Vestibulum ante ipsum primis in faucibus","Nov 10, 2021"),
  ("Brianna Moran","mauris.ut@eumetusin.net","LDL26FKB4BA","(557) 118-5955","in faucibus orci luctus et ultrices posuere","Oct 23, 2021");
  
INSERT INTO `termek` (`megnevezes`,`leiras`,`ar`,`mennyiseg_raktaron`,`arusID`,`learazas`,`felvetel_ideje`)
VALUES
  ("eu dolor","commodo tincidunt",73673,29,1,50,"Oct 29, 2022"),
  ("ornare lectus","nec tempus scelerisque,",40003,205,2,20,"Dec 28, 2021"),
  ("enim, condimentum","varius. Nam porttitor scelerisque",13251,40,4,10,"Jun 14, 2021"),
  ("et ipsum","magna sed dui. Fusce aliquam, enim nec",6669,235,1,0,"Nov 7, 2020"),
  ("sem ut","Suspendisse sed dolor. Fusce",29319,230,3,10,"May 9, 2022");
  
INSERT INTO `kategoria` (`megnevezes`,`leiras`)
VALUES
  ("Pékáru","fermentum risus, at fringilla purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum"),
  ("Zöldség, gyümölcs","condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis"),
  ("Hús, hal","orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu"),
  ("Tejtermék","diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus"),
  ("Italok","dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna");
  
INSERT INTO `termekfoto` (`link`,`indexkep`,`termekID`)
VALUES
  ("XVN69OHI5WQ","0",1),
  ("SDD05YDF4VV","1",3),
  ("MDE01HMM2GZ","0",3),
  ("MNS21TLW2QV","1",1),
  ("OOS45QRM3ST","1",2);
  
INSERT INTO `arus_szamlaja` (`vasarloID`,`szallitasID`,`arusID`,`aru_osszerteke`,`kiallitas_ideje`)
VALUES
  (2,3,5,52529,"Nov 6, 2021"),
  (3,3,1,70155,"Sep 27, 2021"),
  (5,1,2,8526,"May 17, 2022"),
  (3,5,5,21532,"Apr 22, 2022"),
  (2,4,4,96946,"Mar 19, 2022");
  
INSERT INTO `kosar` (`vasarloID`,`szallitasID`,`vegosszeg`,`statusz`,`fizetesi_forma`,`megrendeles_ideje`)
VALUES
  (4,3,30727,"parturient","tempus","Sep 27, 2022"),
  (5,1,45459,"Nullam","lobortis","Mar 6, 2021"),
  (1,3,45303,"lacus.","Nunc","Jul 8, 2022"),
  (2,2,52798,"Aenean","tempus","Oct 1, 2021"),
  (1,2,65752,"semper","feugiat.","Jul 11, 2021");
  
INSERT INTO `szamla_termek` (`szamlaID`,`termekID`,`mennyiseg`)
VALUES
  (3,4,7),
  (3,3,1),
  (1,5,20),
  (3,1,11),
  (3,2,30);
  
INSERT INTO `kosar_termek` (`kosarID`,`termekID`,`mennyiseg`)
VALUES
  (5,2,4),
  (1,3,39),
  (3,3,31),
  (5,1,31),
  (3,4,5);
  
INSERT INTO `termek_kategoria` (`termekID`,`kategoriaID`)
VALUES
  (4,3),
  (5,1),
  (1,3),
  (2,2),
  (1,2);