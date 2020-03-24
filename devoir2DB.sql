 LE BINOME: ABDESLAMI ZAYNA  
	    HMAIDDOUCH NADA
 GROUPE :   G1

  C7)PL/SQL offre la possibilité d’utiliser l’option CURRENT OF nom_curseur dans la clause WHERE des instructions UPDATE et DELETE. 
  Cette option permet de modifier ou de supprimer la ligne distribuée par la commande FETCH. Pour utiliser cette option 
  il faut ajouter la clause FOR UPDATE à la fin de la définition du curseur. Compléter le script suivant qui permet de modifiant 
  le salaire d’un pilote avec les contraintes suivantes : - Si la commission est supérieure au salaire alors on rajoute au salaire 
  la valeur de la commission et la commission sera mise à la valeur nulle. - Si la valeur de la commission est nulle alors supprimer 
  le pilote du curseur. DECLARE CURSOR C_pilote IS   SELECT nom, sal, comm FROM pilote WHERE nopilot BETWEEN 1280 AND 1999 FOR UPDATE;
  v_nom pilote.nom%type;  v_sal pilote.sal%type;  v_comm pilote.comm%type; BEGIN . . . END
 
 La Réponse :
 
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
 ************************************************************************************************************************************
 
  C8) Écrire une procédure PL/SQL qui réalise l’accès à la table PILOTE par l’attribut  nopilote.Si le numéro de pilote existe, 
  elle envoie dans la table ERREUR, le message « NOM PILOTE-OK » sinon le message « PILOTE INCONNU ». De plus si sal<comm,
  elle envoie dans la table ERREUR le message « « NOM PILOTE, COMM >SAL ». Indication : une erreur utilisateur doit être explicitement 
  déclenchée dans la procédure PL/SQL par l’ordre RAISE. La commande RAISE arrête l’exécution normale du bloc et transfert 
  le contrôle au traitement de l’exception. 
 
 La Réponse :
 
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
 
 *********************************CREATION DE VUE*********************************
 
 D1 )  Créer une vue (v-pilote) constituant une restriction de la table pilote, aux pilote qui habitent Paris. 
    
  La Réponse :
					    
  create view v_pilote as select * from pilote where VILLE = 'Paris';
   
 ************************************************************************************************************************************
					    
 D2 ) Vérifier est ce qu’il est possible de modifier les salaires des pilotes habitant Paris à travers la vue v-pilote.
 
  La Réponse :
 
  alter view v_pilote set SAL = 1.1 * SAL; // Il est impossible de modifier les salaires des pilotes habitant Paris � travers la vue v-pilot
					    
 **********************************************************************************************************************************
  
 D3 ) Créer une vue (dervol) qui donne la date du dernier vol réalisé par chaque avion.

 La Réponse :
 
 Create view dervol as Select AVION,max(DATE_VOL)  "Time_Maximum" from Affectation group by avion;
					    
 ************************************************************************************************************************************
 
 D4 )  Une vue peut être utilisée pour contrôler l’intégrité des données grâce à la clause ‘CHECK OPTION’. Créer une vue (cr_pilote)
     qui permette de vérifier lors de la modification ou de l’insertion d’un pilote dans la table PILOTE les critères suivants : 
    - Un pilote habitant Paris a toujours une commission - Un pilote qui n’habite pas Paris n’a jamais de valeur de commission. 

  La Réponse :

  create view cr_pilote as 
     select * from pilote where (comm is not null and ville = 'Paris') or (ville not in 'Paris' and comm is null)with 
     check option;
					    
 ************************************************************************************************************************************
    
 D5 ) Créer une vue (nomcomm) qui permette de valider, en saisie et mise à jour, le montant commission d’un pilote selon les critères 
     suivant : - Un pilote qui n’est affecté à au moins un vol, ne peut pas avoir de commission - Un pilote qui est affecté à au moins 
    un vol peut recevoir une commission. Vérifier les résultats par des mises à jour sur la vue nomcomm

  La Réponse :

 Create view nomcomm as 
    select * from pilote where 
    nopilot in (select pilote from affectation where comm is not null,select pilote from affectation where comm is null);
