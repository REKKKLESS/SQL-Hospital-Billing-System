drop table bill;
drop table patient;
drop table room;
drop table doctor;


create table doctor
    (
        d_name          varchar2(20)
      , d_id          varchar2(20)
      , address       varchar2(50)
      , phone_number  number(10)
      , doc_designation varchar2(20)
      , gender        varchar2(20)
      , constraint pk_doctor primary key(d_id)
    )
;



create table room
    (
        room_id   varchar2(5)
      , room_type varchar2(20)
      , room_charges number(10)
      , constraint pk_room primary key(room_id)
    )
;




create table patient
    (
        p_id           varchar2(10)
      , p_name         varchar2(20)
      , p_age          number(3)
      , p_gender       varchar2(10)
      , p_address        varchar2(50)
      , d_id         varchar2(20)
      , date_admission date
      , phone_number   number(10)
      , room_id        varchar2(5)
      , constraint pk_patient primary key(p_id)
      , constraint fk_p1 foreign key(room_id) references room
    )
;


create table bill
    (
        bill_no        varchar2(10)
      , bill_date      date
      ,p_name       varchar(20)
      , p_id           varchar2(10)
      , p_gender       varchar2(10)
      , p_address        varchar2(50)
      , d_name          varchar2(20)
      , date_admission date
      , date_discharge date
      , days_admitted number(5)
      , room_charges   number(10)
      , pathology_fees number(10)
      , d_fees         number(10)
      , miscellaneous  number(10)
      , total_amount   number(10)
      , constraint pk_bill primary key(bill_no)
      , constraint fk_b1 foreign key(p_id) references patient(p_id)
    )
;


insert into doctor values('Dr.Rohit','D001','H1/10, Hauz Khas, New Delhi, Delhi',8878988955,'Cardiologist','Male');
insert into doctor values('Dr.Tarun','D002','94/4,Gurugram, Haryana 122001',7778988955,'Allergist','Male');
insert into doctor values('Dr.Shivani','D003','Sector 14, Gurugram, Haryana',8854346756,'Oral Surgeon','Female');

insert into room values('R001','Private',1000);
insert into room values('R002','Private',1000);
insert into room values('R003','General',500);

insert into patient values('P001','Raghav',17,'Male','Agra','D001','17-apr-21',9965467889,'R001');
insert into patient values('P002','Manish',25,'Male','Surat','D002','10-jan-20',5467890767,'R002');
insert into patient values('P003','John',45,'Female','Mumbai','D003','10-dec-20',7765478908,'R003');

DROP SEQUENCE BILL_NO_SEQ;

CREATE SEQUENCE BILL_NO_SEQ
  MINVALUE 1
  MAXVALUE 100000
  START WITH 1
  INCREMENT BY 1;
/ 


CREATE OR REPLACE TRIGGER BILL_TRG
BEFORE INSERT ON bill
FOR EACH ROW 
DECLARE
d_id VARCHAR2(20);
doc_id VARCHAR2(20);
R_ID VARCHAR2(20);
p_name varchar2(20);
BEGIN
IF :NEW.BILL_NO IS NULL THEN
      :NEW.BILL_NO := NVL(:NEW.BILL_NO,BILL_NO_SEQ.NEXTVAL);
END IF;
IF :NEW.BILL_DATE IS NULL THEN
    SELECT TO_CHAR(SYSDATE) INTO :NEW.BILL_DATE FROM DUAL;
       --UPDATE BILL set BILL_DATE=TO_CHAR(SYSDATE); 
END IF;
IF :NEW.p_name IS NULL THEN
     SELECT p_name INTO :NEW.P_NAME FROM PATIENT WHERE P_ID=:NEW.P_ID;
END IF;
IF :NEW.P_GENDER IS NULL THEN
     SELECT P_GENDER INTO :NEW.P_GENDER FROM PATIENT WHERE P_ID=:NEW.P_ID;
END IF;
IF :NEW.P_ADDRESS IS NULL THEN
     SELECT P_ADDRESS INTO :NEW.P_ADDRESS FROM PATIENT WHERE P_ID=:NEW.P_ID;
END IF;
IF :NEW.D_NAME IS NULL THEN
     SELECT D_NAME INTO :NEW.D_NAME FROM DOCTOR D, PATIENT P WHERE D.D_ID = P.D_ID AND P.P_ID = :NEW.P_ID;
END IF;
IF :NEW.DATE_ADMISSION IS NULL THEN
     SELECT DATE_ADMISSION INTO :NEW.DATE_ADMISSION FROM PATIENT WHERE P_ID=:NEW.P_ID;
END IF;
IF :NEW.days_admitted IS NULL THEN
        UPDATE BILL SET DAYS_ADMITTED=abs(to_date(date_admission)-to_date(date_discharge));
    --select to_date( b.date_discharge)-to_date( b.date_admission)  INTO :NEW.days_admitted from bill b;
    --:NEW.days_admitted := NVL(:NEW.days_admitted,select to_date(date_discharge) from bill);
END IF;
IF :NEW.room_charges IS NULL THEN
     --SELECT room_charges INTO :NEW.ROOM_CHARGES FROM room r,patient p where r.room_id=p.room_id and p.P_ID=:NEW.P_ID;
      --:NEW.ROOM_CHARGES :=NVL(:NEW.ROOM_CHARGES,R_ID*DAYS_ADMITTED);
     SELECT room_id INTO R_ID FROM PATIENT WHERE P_ID=:NEW.P_ID;
      SELECT room_charges INTO :NEW.room_charges FROM room WHERE room_id=R_ID;
      --UPDATE BILL SET ROOM_CHARGES=ROOM_CHARGES*DAYS_ADMITTED;
END IF;
--IF :NEW.total_amount IS NULL THEN
    --UPDATE BILL SET TOTAL_AMOUNT=ROOM_CHARGES+PATHOLOGY_FEES+D_FEES+MISCELLANEOUS;
--END IF;
END;
/

--CREATE OR REPLACE TRIGGER BILL_TRG1
--AFTER INSERT ON bill
--FOR EACH ROW 
--DECLARE
--R_ID VARCHAR2(20);
--days_admitted number(5);
--BEGIN
--IF bill.days_admitted IS NULL THEN
--        UPDATE BILL SET DAYS_ADMITTED=abs(to_date(date_admission)-to_date(date_discharge));
--END IF;
--END;
--/


--Bill (To be inserted after trigger creation)
INSERT INTO BILL (P_ID,PATHOLOGY_FEES,MISCELLANEOUS,D_FEES,date_discharge) values ('P001',300,100,500,'30-04-21');
INSERT INTO BILL (P_ID,PATHOLOGY_FEES,MISCELLANEOUS,D_FEES,date_discharge) values ('P002',500,100,500,'15-01-20');
INSERT INTO BILL (P_ID,PATHOLOGY_FEES,MISCELLANEOUS,D_FEES,date_discharge) values ('P003',250,100,500,'25-12-20');


update bill set days_admitted=to_date(date_discharge)-to_date(date_admission);
UPDATE BILL SET ROOM_CHARGES=ROOM_CHARGES*DAYS_ADMITTED;
UPDATE BILL SET TOTAL_AMOUNT=ROOM_CHARGES+PATHOLOGY_FEES+D_FEES+MISCELLANEOUS;

select * from doctor;
select * from room;
select * from patient;
select * from bill;




--create table doctor(name varchar2(20),d_id varchar2(20),address varchar2(50),phone_number number(10),qualification varchar2(20),
--gender varchar2(20),constraint pk_doctor primary key(d_id));
--
--create table room(room_id varchar2(5),room_type varchar2(20),constraint pk_room primary key(room_id));
--
--create table patient(p_id varchar2(10),p_name varchar2(20),p_age number(3),p_gender varchar2(10),address varchar2(50),
--date_admission date,phone_number number(10),room_id varchar2(5),
--constraint pk_patient primary key(p_id),constraint fk_p1 foreign key(room_id) references room);
--
--create table bill(bill_no varchar2(10),bill_date date,p_id varchar2(10),p_name varchar2(20),p_age number(3),p_gender varchar2(10),
--date_admission date,date_discharge date,room_charges number(10),pathology_fees number(10),d_fees number(10),
--miscellaneous number(10),total_amount number(10),constraint pk_bill primary key(bill_no),
--constraint fk_b1 foreign key(p_id) references patient,constraint fk_b2 foreign key(p_name) references patient,
--constraint fk_b3 foreign key(p_age) references patient,constraint fk_b4 foreign key(p_gender) references patient,
--constraint fk_b5 foreign key(date_admission) references patient);
