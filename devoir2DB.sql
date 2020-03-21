 LE BINOME: ABDESLAMI ZAYNA  
	   HMAIDDOUCH NADA
 GROUPE :   G1

 //C7
 DECLARE 
    CURSOR C_pilote IS SELECT nom, sal, comm FROM pilote WHERE nopilot BETWEEN 1280 AND 1999 FOR UPDATE; 
       v_nom pilote.nom%type;
       v_sal pilote.sal%type; 
       v_comm pilote.comm%type; 
 BEGIN 
  OPEN C_pilote; 
  loop
  fetch C_pilote into v_nom,v_sal,v_comm;
    if C_pilote%NOTFOUND then
       exit; 
    END if;
    if v_comm > v_sal then  update pilote set sal = comm + sal where current of C_pilote ; 
    elsif v_comm is null then 
      DELETE PILOTE WHERE CURRENT OF C_pilote;
    end if;
   end loop;
   close C_pilote; 
 End;
 
 //C8
 create table Table_Erreur (Erreur varchar2(80));
 create or replace procedure Procedure_Pilote(npilote pilote.nopilot%type ) is 
       v_npilot pilote.nopilot%type ;
       v_DT pilote%rowtype;
       v_except exception ;
 BEGIN
       select count (*) into v_npilot from pilote where nopilot=npilote ;
       if v_npilot=0 then 
          raise v_except ;
       else 
          select * into v_DT from pilote where nopilot = npilote ;
          if(v_DT.comm > v_DT.sal ) then 
             insert into Table_Erreur values ( v_DT.nom ||',COMM > SAL ');
          else 
             insert into Table_Erreur values ( v_DT.nom ||' -OK') ;
          end if;
       end if ;
 EXCEPTION 
       when v_except then
       insert into Table_Erreur values ('PILOTE INCONNU') ; 
 END;
 
 //*********************************CREATION DE VUE*********************************
 
 //D1
  create view v_pilote as select * from pilote where VILLE = 'Paris';
   
 //D2
  alter view v_pilote set SAL = 1.1 * SAL; // Il est impossible de modifier les salaires des pilotes habitant Paris � travers la vue v-pilote. 
  
 //D3
 Create view dervol as Select AVION,max(DATE_VOL)  "Time_Maximum" from Affectation group by avion;
 
 //D4
  create view cr_pilote as 
     select * from pilote where (comm is not null and ville = 'Paris') or (ville not in 'Paris' and comm is null)with 
     check option;
     
 //D5
 Create view nomcomm as 
    select * from pilote where 
    nopilot in (select pilote from affectation where comm is not null,select pilote from affectation where comm is null);