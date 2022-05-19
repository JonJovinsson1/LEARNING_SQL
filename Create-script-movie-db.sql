-- Student Number(s):	10396563
-- Student Name(s):		Jon Sveinbjornsson

/*	Database Creation & Population Script (6 marks)
	Write a script to create the database you designed in Task 1 (incorporating any changes you have made since then).
	Be sure to give your columns the same data types, properties and constraints specified in your data dictionary, and be sure to name tables and columns consistently.
	Include any suitable default values and any necessary/appropriate CHECK or UNIQUE constraints.

	Make sure this script can be run multiple times without resulting in any errors (hint: drop the database if it exists before trying to create it).
	Use/adapt the code at the start of the creation scripts of the sample databases available in the unit materials to implement this.

	See the assignment brief for further information. 
*/

-- Write your creation script here

IF DB_ID('jjsveinAssesment2') IS NOT NULL             
BEGIN
    PRINT 'Database exists - dropping.';
    USE master;
    ALTER DATABASE jjsveinAssesment2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE jjsveinAssesment2;
END
GO

PRINT 'Creating database.';
CREATE DATABASE jjsveinAssesment2;
GO

USE jjsveinAssesment2;
GO


CREATE TABLE genre
(	genre_ID SMALLINT NOT NULL CONSTRAINT genre_pk PRIMARY KEY IDENTITY,
	genre_name VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE franchise 
(	franchise_ID SMALLINT NOT NULL CONSTRAINT franchise_pk PRIMARY KEY IDENTITY,
	franchise_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Customer
(	customer_ID INT NOT NULL CONSTRAINT customer_pk PRIMARY KEY IDENTITY,
	customer_email VARCHAR(50) NOT NULL UNIQUE CHECK (customer_email LIKE '_%@_%._%'),
	customer_password VARCHAR(512) NOT NULL, 
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birthday DATE NOT NULL -- CHECK ( NOW() - birthday < 12) -- FIX THIS);
);

CREATE TABLE classification
(	class VARCHAR(5) NOT NULL CONSTRAINT classification_pk PRIMARY KEY,
	class_name VARCHAR(50) NOT NULL UNIQUE,
	min_age TINYINT NOT NULL
);

CREATE TABLE movie
(	movie_id INT NOT NULL CONSTRAINT movie_pk PRIMARY KEY IDENTITY,
	movie_name VARCHAR(100) NOT NULL,
	release_date DATE NOT NULL DEFAULT GETDATE(),
	duration_in_min SMALLINT NOT NULL DEFAULT 0 CHECK (duration_in_min > 0),
	Summary VARCHAR(1000) NULL,
	class VARCHAR(5) NOT NULL CONSTRAINT movie_class_fk FOREIGN KEY REFERENCES classification(class),
	franchise_ID SMALLINT NULL CONSTRAINT movie_franchise_id FOREIGN KEY REFERENCES franchise(franchise_id),
	sequel_id INT NULL CONSTRAINT movie_sequel_id FOREIGN KEY REFERENCES movie(movie_id)
);

CREATE TABLE movie_genre
(	genre_ID SMALLINT NOT NULL FOREIGN KEY REFERENCES genre(genre_id),
	movie_id INT NOT NULL FOREIGN KEY REFERENCES movie(movie_id),
	CONSTRAINT movie_genre_pk PRIMARY KEY (genre_id,movie_id)
);

CREATE TABLE movie_review
(	movie_id INT NOT NULL FOREIGN KEY REFERENCES movie(movie_id),
	customer_ID INT NOT NULL FOREIGN KEY REFERENCES customer(customer_id),
	rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <=10),
	review_text TEXT NULL,
	review_date DATE DEFAULT GETDATE() NOT NULL
);

CREATE TABLE cinema_type
(	cin_type_id TINYINT NOT NULL CONSTRAINT cinema_type_pk PRIMARY KEY IDENTITY,
	c_type_name VARCHAR(50) NOT NULL UNIQUE,
);

CREATE TABLE cinema_rooms
(	cin_room_id TINYINT NOT NULL CONSTRAINT cinema_room_pk PRIMARY KEY IDENTITY,
	cin_room_name VARCHAR(50) NOT NULL UNIQUE,
	seat_capacity SMALLINT NOT NULL DEFAULT 0 CHECK (seat_capacity >=0),
	cin_type_id TINYINT NOT NULL FOREIGN KEY REFERENCES cinema_type(cin_type_id)
);

CREATE TABLE session
(	session_id INT NOT NULL CONSTRAINT session_pk PRIMARY KEY IDENTITY,
	session_date_time SMALLDATETIME NOT NULL,
	price SMALLMONEY NOT NULL DEFAULT 0 CHECK (price >=0),
	cin_room_id TINYINT NOT NULL FOREIGN KEY REFERENCES cinema_rooms(cin_room_id),
	movie_id INT NOT NULL FOREIGN KEY REFERENCES movie(movie_id)
);

CREATE TABLE ticket
(	customer_ID INT NOT NULL FOREIGN KEY REFERENCES customer(customer_id),
	session_id INT NOT NULL FOREIGN KEY REFERENCES session(session_id),
	quantity SMALLINT NOT NULL DEFAULT 1,
	CONSTRAINT  ticket_pk PRIMARY KEY (customer_id,session_id)
	
);


/*	Database Population Statements
	Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.
	You are only required to populate the database with enough data to make sure that all views and queries return meaningful results.
	
	You can start working on your views and queries and write INSERT statements as needed for testing as you go.
	The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.

	Since writing sample data is time-consuming and quite tedious, I have provided data for some of the tables below.
	Adapt the INSERT statements as needed, and write your own INSERT statements for the remaining tables at the end of the file.
*/



/*  The following statement inserts the details of 5 classifications into a table named "classification".
    It specifies values for columns named "class", "class_name" and "min_age".
	You may change the table and column names to match those in your database if needed, but must ensure that your columns can contain the specified data.
	You may use NULL instead of 0 for the first three classifications if preferred, but will need to account for this in certain queries if so.
*/

INSERT INTO classification (class, class_name, min_age)
VALUES ('G',  'General', 0),
       ('PG', 'Parental Guidance', 0),
       ('M',  'Mature', 0),
       ('MA', 'Mature Audiences', 15),
       ('R',  'Restricted', 18);




/*	The following statement inserts the details of 10 genres into a table named "genre". 
    It specifies values for a column named "genre_name", and it is assumed that the primary key column is an auto-incrementing integer.
	You may change the table and column names to match those in your database if needed, but must ensure that your columns can contain the specified data.
*/

INSERT INTO genre (genre_name)
VALUES ('Action'),     -- Genre 1
       ('Adventure'),  -- Genre 2
       ('Animation'),  -- Genre 3
       ('Comedy'),     -- Genre 4
       ('Crime'),      -- Genre 5
       ('Drama'),      -- Genre 6
       ('Fantasy'),    -- Genre 7
       ('Horror'),     -- Genre 8
       ('Romance'),    -- Genre 9
       ('Sci-Fi');     -- Genre 10



	   
/*	The following statement inserts the details of 3 cinema types into a table named "cinema_type". 
    It specifies values for a column named "c_type_name", and it is assumed that the primary key column is an auto-incrementing integer.
	You may change the table and column names to match those in your database if needed, but must ensure that your columns can contain the specified data.
*/

INSERT INTO cinema_type (c_type_name)
VALUES ('Budget'), 
	   ('Standard'), 
	   ('Gold Class');
	   



-- Write your INSERT statements for the remaining tables here.  See the assignment brief for further details and guidance.
-- Remember that you do not need to create a lot of data and it does not need to be realistic or comprehensive.

INSERT INTO franchise(franchise_name)
VALUES ('Marvel'), 
	   ('Alien'), 
	   ('American pie');



INSERT INTO movie(movie_name, release_date, duration_in_min, Summary, class,franchise_ID, sequel_id)
VALUES	('Spider man', '2010-03-05','100', 'this is the summary for spiderman blah blah blah', 'PG','1',null),
		('Spider man 2', '2011-04-06','135', 'lorem ipsum blah blah 45769', 'M','1','1'),
		('American Pie', '1980-07-01','85', 'American pie American pie American pie ', 'MA','3',null),
		('American Pie 2', '1982-11-03','99', 'Summary Summary Summary Summary Summary Summary Summary Summary  ', 'R','3','3'),
		('American Pie the final', '1990-06-28','145', 'The final A M The final A M The final A M The final A M   ', 'R','3','4'),
		('TOP GUN', '1996-08-10','200', 'fake movie fake movie', 'G',null,null),
		('ALIEN', '1978-12-01','280', 'The first alien movie', 'MA','2',null),
		('ALIEN 2', '1991-10-09','250', 'the sequal to alien movie', 'R','2','7'),
		('Shrek', '1997-11-29','125', 'DATA ENTRY DATA ENTRY DATA ENTRY ', 'G',NULL,NULL),
		('#1 Child movie under 90min', '1997-11-29','87', 'This should appear in query 1 ', 'G',NULL,NULL),
		('#2 Child movie under 90min', '2000-11-29','88', 'This should appear in query 1 ', 'PG',NULL,NULL),
		('#3 Child movie EXACTLY 90min', '2019-11-29','90', 'This MIGHT? appear in query 1 ', 'G',NULL,NULL),
		('#3 Child movie over 90min', '2019-11-29','91', 'This should NOT appear in query 1 ', 'PG',NULL,NULL)
		;


INSERT INTO cinema_rooms(cin_room_name,seat_capacity,cin_type_id)
VALUES	('Cinema 1', '75', '1'),
		('Cinema 2', '100','2'),
		('Cinema GOLD', '150','3');


INSERT INTO movie_genre(movie_id,genre_ID)
VALUES	('1','1'),
		('1','10'),
		('1','9'),
		('2','1'),
		('2','10'),
		('2','9'),
		('3','4'),
		('3','6'),
		('4','4'),
		('4','2'),
		('5','4'),
		('5','6'),
		('5','2'),
		('6','1'),
		('6','5'),
		('7','10'),
		('7','8'),
		('8','10'),
		('8','8'),
		('9','2'),
		('9','3'),
		('10','3'),
		('10','5'),
		('11','3'),
		('11','4'),
		('12','3'),
		('12','7');

INSERT INTO session(session_date_time, price, cin_room_id, movie_id)
VALUES	('2022-04-12 17:00','15',1,1),
		('2022-04-12 19:00','15',1,2),
		('2022-05-11 12:00','20',2,7),
		('2022-04-12 13:00','45',3,2),
		('2022-04-12 14:20','10',1,3),
		('2022-02-07 21:47','36',2,3),
		('2023-10-02 21:55','19',2,8),
		('2022-11-03 19:31','40',3,8),
		('2023-01-19 21:16','20',2,5),
		('2023-11-22 21:57','44',2,6),
		('2023-01-26 13:51','42',1,4),
		('2022-10-04 22:43','16',2,5),
		('2023-01-23 14:14','20',3,6),
		('2022-08-30 00:26','32',2,1),
		('2022-06-23 00:44','18',2,3),
		('2022-05-09 04:02','33',2,4),
		('2023-05-01 17:11','34',3,3),
		('2022-08-14 15:20','15',2,2),
		('2023-07-23 14:24','36',1,7),
		('2022-07-30 15:01','26',1,8),
		('2023-11-28 01:40','38',3,1),
		('2022-08-21 15:31','31',2,4),
		('2022-09-02 06:04','25',3,2),
		('2021-12-30 15:50','37',2,3),
		('2021-05-22 00:23','32',2,6),
		('2023-01-04 14:08','14',2,4),
		('2022-03-12 03:44','33',2,2),
		('2021-09-07 22:59','40',3,2),
		('2022-03-10 19:02','23',3,3),
		('2021-07-28 11:39','29',2,5),
		('2021-11-10 09:10','37',1,2),
		('2022-07-09 22:53','31',3,4),
		('2022-06-24 15:58','11',1,4),
		('2022-02-07 01:33','9',1,8),
		('2021-11-26 04:58','11',2,4);
		

INSERT INTO Customer (customer_email,customer_password,first_name,last_name,birthday)
VALUES	  ('sagittis.placerat@yahoo.net','FVF32EYU9FC7YPK49DSF8NI9EVC76PRN5SK0','Aristotle','Alexander','1993-08-10 '),
  ('nullam.enim@icloud.ca','APS29HVJ4TF6PHR74YAK4IG4QAE38DVP5QO3','Dexter','Donaldson','1987-06-20 '),
  ('sapien.nunc.pulvinar@yahoo.com','MHW73MUH8KE2MLT29FZQ6FL7ZTH82CZN6OD2','Tanek','Armstrong','2002-04-22 '),
  ('vel.lectus.cum@hotmail.couk','XLN23RJQ3SY5CUV77PRP7CQ0XQH68UZV2RW8','Naomi','House','1965-01-29 '),
  ('eleifend.cras@google.org','TXG11AOL8BB7YXB57XPP5CL5JEC68LVQ7QF1','Tatum','Melendez','1959-06-30 '),
  ('mus.proin@hotmail.edu','XOP66RXH6WL1QMW19JNF4RE5TOP18CWX5RK0','Ria','Farrell','1983-07-08 '),
  ('dictum.augue@google.org','WEG34LCD4IG6SMQ32PIM4IV5QGY61KNY7ZR4','Lance','Massey','1982-06-13 '),
  ('nunc.ut@yahoo.org','HAC34VWY4PM3JHR90XXB2EK1WOL97VNP1QN1','Lionel','Noble','1987-04-06 '),
  ('imperdiet.erat@hotmail.org','KED44MOZ7NJ2TQM13BRW6YE4XNM67EPX2ZH1','Ruth','Sutton','1974-09-23 '),
  ('sit.amet@google.edu','ZYL30DVG2SA7ZOA32VYS9DM7GWM44TJL8DR6','Jerome','Warren','1962-01-27 '),
  ('dolor.fusce@yahoo.ca','IHJ45OQQ9KD2ORL75SVN7TW5AIU50RNY9JX7','Katell','Jimenez','1984-01-27 '),
  ('luctus.ipsum.leo@yahoo.ca','JSE24FTW0LS2EDR26LGF4PX7YVW79OTA8PJ4','Yael','Calhoun','1958-08-21 '),
  ('ante.maecenas@aol.couk','WXW32QFY3BS8CBM12FVJ2OK9SPL05PIC1ZO4','Deanna','Hamilton','2005-10-05 '),
  ('vehicula.aliquet.libero@hotmail.com','CNR88VHT8CP3BVK08YDI3PU4SBE85BGU2TJ5','Ulla','Richmond','2008-11-27 '),
  ('morbi.non@aol.net','XWA48MOV9BW5QMI64MAA7PL6GEP37NOA5EV2','Sacha','Brock','2000-04-26 '),
  ('lorem.eget.mollis@icloud.ca','KNB36FPQ3BW8CEY69KDJ2JD7YIJ24RML7RO6','Sara','Romero','1987-05-28 '),
  ('placerat.cras.dictum@protonmail.ca','TVC35WXR6SR8JPV97IIJ1KO1WYI84EMA7MS5','Chaim','Bradford','1996-11-27 '),
  ('aliquam.erat@hotmail.ca','PYH50LPQ8WQ3GXN96DWV4VK5MOH76QPI7VB0','Astra','Strong','1979-07-28 '),
  ('odio@yahoo.org','SOQ68QPO7OL2DUC32JBF7BL4FZE46GSG3FB2','Lael','Harrell','1987-03-15 '),
  ('donec.non.justo@protonmail.org','BOF17IUM6KN4OSW84XJN9ZF4FOA43XDW4NI6','Geraldine','Wong','2007-04-13 '),
  ('mus.aenean.eget@yahoo.couk','CGQ14XNF8YN6MCG36WPJ4YY2XQL47UEU0XV4','Nigel','Thompson','1997-05-24 '),
  ('mollis@aol.ca','OWV81UAC2MI7QNB66ZDP3TO8FMU70SFK7RX4','Hunter','Brooks','1993-10-09 '),
  ('commodo.tincidunt.nibh@aol.ca','VIJ53OKL5JQ6RSY21XFH8GU9RGE89IDG9TR3','Laura','Mooney','1970-12-08 '),
  ('nonummy@google.couk','OFX75TKZ6LE5ARW96DEQ2WG1MUC83DGP2SC8','Illiana','Schroeder','1984-05-21 '),
  ('nulla.tempor.augue@protonmail.edu','EOW00ATZ0JG9UMW65HNR4TQ7YXS35BLE8PV5','Amena','Carey','1986-11-17 '),
  ('dolor.quam.elementum@icloud.edu','XGQ26REY3DC6YNG77LUY3DN0HXT46IHL8II9','Yardley','Maldonado','1962-12-29 '),
  ('dignissim.pharetra@aol.edu','FUA33UOP0EY4GXR12NJM0VQ7CDK72GUH1YT4','Clark','Pitts','2005-05-24 '),
  ('nulla@protonmail.net','PWW47QER7LT6QWF52SHT5JS1NIC72PVK3KO8','Marah','Newton','1980-05-01 '),
  ('mi.lorem@google.couk','EPT25KBO6SQ1LOD13FKU2IP5CBK92TTL5IX6','Kyla','Holman','2008-06-06 '),
  ('vel.arcu.eu@hotmail.net','LUD15GVW6XS3JBO47WTW6AQ2OMG63OXK6IT4','Robin','Sellers','1976-08-30 '),
  ('lacus.etiam@protonmail.edu','PLF37OKN5UO8WKN49IOK1PL7NXE68GZK6GN8','Keegan','Yang','1988-09-13 '),
  ('venenatis.a@google.couk','HAR73NNG3BS8MJI69QRR4IF1PQQ87YWC9RW0','Samantha','Barnett','1983-11-08 '),
  ('ac.mi.eleifend@yahoo.net','JDE62EEE7XJ9LJW91HXG0GB5BOX31KRH4YM4','Murphy','Fields','1994-09-16 '),
  ('dictum.eu@outlook.com','HXK44TEJ4QX5QTD70GMO9US5WXB41BTF7KJ8','Tana','Williams','1977-07-26 '),
  ('luctus.lobortis.class@yahoo.org','CDP25GLB1FY3LRL28LGD4AI4IBH76HOA0VH6','Simon','Moore','1974-07-28 '),
  ('a.tortor@protonmail.org','VYH62TNY7CL7FDE15RYE7QP4PNG61MFI7YR4','Holmes','Chavez','1966-09-25 '),
  ('interdum.sed.auctor@yahoo.net','RBD86WXU5HZ6UQT48AVO1LU5FQO51ANQ5UY8','Meghan','Carr','1969-05-16 '),
  ('diam.pellentesque@hotmail.edu','ANP54HJT5ZK1IMU12GSX5RR5VMP25OGT3PI4','Germane','Pratt','1966-05-19 '),
  ('augue.malesuada.malesuada@protonmail.edu','PXI38RCN4KL7WDO72NBX4WN2TJE11CGB2QN8','Darryl','Justice','1988-12-27 '),
  ('velit.in@yahoo.net','SKS31SWV1IP3UCI60PWU2PC1LIV97TJX1SY2','Harding','Booker','1967-11-12 '),
  ('luctus.et@aol.ca','OKJ75SSA6MD2RCC48HWB1BN7NBV82UQZ4FA7','Prescott','Erickson','1977-03-06 '),
  ('euismod.mauris@protonmail.com','KTR68HLF4JX9YBI86ZXE9UN9OGQ02YVN6XN4','Lareina','Burris','1994-04-22 '),
  ('dictum@google.edu','KGG41MAQ5HL7PNU83KWC3OM0NXF65QMD0QH7','Cara','Mcdaniel','1977-12-28 '),
  ('tincidunt.pede.ac@outlook.couk','ADC87FGY5NA3WWE35SQX6OM2XPK67UGO4IB3','Malachi','Kim','1961-10-15 '),
  ('ad@icloud.ca','IGE32YLN4RJ1YNR81HEK3RN8HBH47WTG3MN6','Merritt','Harrell','1966-09-07 '),
  ('interdum.libero.dui@outlook.ca','UVR87LAA0XX8MSG34NNQ9IG3BRS49MMR7TQ4','Kylynn','Kelly','1970-05-24 '),
  ('tincidunt@protonmail.com','CED21MNV5KW0UVA69WIP0HI7VME27BKY1SH9','Uma','Pena','1984-10-06 '),
  ('a@google.edu','ORR40GDK5AK2RQB13VLS4RD3HIM62NGX2IU3','Irene','Price','1969-06-26 '),
  ('sed.orci.lobortis@hotmail.net','ANU84PRN2JM0KQU42WED3QD2HDC40YRU5HS4','Risa','Mason','1964-09-28 '),
  ('in@outlook.ca','WIB25CKI3PS2EUL78DUR2LU1ASV66PYA5ET2','Ariana','Clements','1965-07-15 '),
  ('vel.venenatis@icloud.com','RJW62KEH1IY9EXI08EGX2VI6BED47TEJ1VT5','Beverly','Black','2004-03-17 '),
  ('sed.facilisis@hotmail.com','EQX67ALD7YD5DOE63HAZ6LZ3OVE28BHN6MS2','Dora','Emerson','1983-10-11 '),
  ('pellentesque.habitant@google.net','BHX16JQI3MF8GPL84UWF7IB7ZHC54SLC2UR8','Daryl','Stokes','2000-04-19 '),
  ('sagittis.duis@hotmail.net','EGB38CKI8WY9WCM46YXZ8NG4SNF64MDT5LS4','Jermaine','Bailey','1973-11-09 '),
  ('donec@outlook.edu','YEG16NXL0TI6SOC35ZXU6IG0NOX58WMI6GO6','Jameson','Howell','1958-10-06 '),
  ('elit.nulla@outlook.net','KTB53QOX3DC8QLI79KZN2VF5EAU25MEW2WW2','Nichole','Monroe','1965-01-23 '),
  ('interdum.nunc@protonmail.couk','GHP58CBL6UP4KQQ64YZM8YV1DMM28WJK0PB9','Kaseem','Cooper','1968-01-08 '),
  ('odio.nam.interdum@yahoo.couk','TGR63XHK6NF6CGN16RAN7TD5AHY67QLX4FG4','Cyrus','Maddox','1986-12-02 '),
  ('tellus@icloud.couk','VHL68OVY4YI8WFL48XRG6ZP4IGL11SND3AX8','Malcolm','Justice','1971-11-21 '),
  ('dictum.sapien@yahoo.com','WSC52FXT6IX8KHG69IIZ2VV5RNQ04WOJ8QS5','Hillary','Carr','1964-02-11 '),
  ('velit.aliquam@aol.net','QPB14QES0SM8PQE35PKA1RK1ELD61PMW5NF4','Dolan','Wells','1974-10-13 '),
  ('ligula.elit.pretium@google.edu','DQC56CKR2HT0SGQ22NKP5RU8RBC94EIT3JR7','Quyn','Norton','1995-05-22 '),
  ('risus.nunc@outlook.com','QRB13HCW4XU2VXI84TIS2TB4DOW68JXU1DJ2','Yeo','Langley','1983-10-05 '),
  ('cursus.et@aol.couk','QIO73EAO7RD0YSL41UGA5BN2CNL36EFW8GQ6','Aline','Small','1981-05-18 '),
  ('arcu@icloud.org','EUL17EWA1GZ2DFQ41KJY7DE1CGY81GVQ4VB7','Emmanuel','Bradley','2008-09-04 '),
  ('neque.morbi@icloud.edu','IFG83WRO7LU1EVK56KDJ3DP1ERD03IRT2GV6','Frances','Schwartz','1993-12-19 '),
  ('et@outlook.couk','PHP79WHN1TG5UEH23DHQ1QG3AUK33BYO2MF0','Candice','Humphrey','2003-04-29 '),
  ('est.tempor@protonmail.couk','QPT65ETA2YD2TIE01UIQ1PM9NQE59STV3UH7','Tatyana','Drake','1997-03-13 '),
  ('sed.neque.sed@outlook.com','DNT47VKE3UH2UOH73HSL3EG4WRN66SPF8SM2','Colette','Herrera','1980-04-01 '),
  ('libero.donec.consectetuer@icloud.couk','UHJ78FOQ1JX4SDB92NNK6BL4LOQ84HZB8KU6','Erica','Hendrix','2006-09-04 '),
  ('tellus@icloud.net','SOE65KSR0ZF7BJK97DCJ3OX7KSW11YLQ1WI1','Aiko','Kim','1969-05-22 '),
  ('metus.sit@protonmail.ca','TLJ86RHJ0BP7BIB80EAG2EJ0TTQ95YIP5FB2','Azalia','Tate','1979-10-06 '),
  ('feugiat.placerat.velit@icloud.edu','RQS77BVX9KQ6GPE81XTC3IY5KFB85FQF8LL5','Aphrodite','Stephenson','1988-09-11 '),
  ('eget.metus@outlook.org','GCC65HQN5LD7EEL72WJQ8NK7LIS79IOE7EY5','Mira','Russo','1995-10-07 '),
  ('donec.est@aol.ca','YLA74XTQ1IK3ZLD21ERR4BO4TYG04RYY1GO7','Desiree','Skinner','2007-04-03 '),
  ('dapibus.id@google.ca','OBT73XSZ4PM0RVF27AHG4UC7MGH24BPR2FN0','Urielle','Walters','1988-04-19 '),
  ('dui.augue@aol.couk','LEO61RCT5YJ2OEL67JEO6ND3CWV56FMF5FH5','Harriet','Foreman','1995-06-07 '),
  ('per.inceptos@icloud.edu','AOY86VOJ6HX6NLB84UFX1HS7DDJ71JBK2MI4','Christine','Wheeler','2003-08-17 '),
  ('ipsum.dolor@aol.edu','WON41DVG0FD2GQT34GME2DC8FBP67FKO2GJ2','Wayne','Burnett','1988-01-28 '),
  ('lorem.semper@hotmail.org','WXU16YOR8GF8SNY44TPE2QB0YVS52DNB0SM2','May','Carroll','1985-04-21 '),
  ('dolor@hotmail.net','OCD56LCJ4RR8FUM03PJU2IX7JMJ12PWR2VT5','Shad','Tyson','1990-09-05 '),
  ('fusce.mi.lorem@google.org','ZBQ42ILD0GM3SGX54HSI6WX6MMT79OWI2HS3','Jeanette','Garza','1995-02-17 '),
  ('venenatis@outlook.edu','INI26RON3EQ5QPK26SNS5UZ7SBM43HQV5ZH6','Kevin','Berger','1996-04-12 '),
  ('semper@hotmail.couk','UUO25YGX5XM4KVS83GJN3KJ1GEF31TZG1ZH6','Ivor','Howe','1985-11-05 '),
  ('nec.mauris.blandit@aol.org','NRE74MOE6SH6JYK20CSM5LR8VQL88IQW3KH0','Cally','Michael','1979-04-01 '),
  ('varius.orci.in@protonmail.edu','ECZ40PIR0KM4GPV65LCO0NN6JMD70SMW6HQ1','Leah','Christensen','1976-11-17 '),
  ('neque.nullam.ut@outlook.net','VFG04GSP6HR6IUE88SUW7LW8SNS56MDU6QB0','Ava','Wilkins','1995-10-18 '),
  ('feugiat.nec.diam@outlook.com','KBS56QOV3IH3RQJ74ZLK1IG2NUR77XZW6CL8','Theodore','Hoover','1966-07-31 '),
  ('luctus.curabitur@outlook.ca','CKF74FGY1OU4JWS15SSM7RO1GPN36QJH2LJ2','Uriah','Lucas','1970-08-08 '),
  ('sapien.cursus@yahoo.edu','BYZ68BYU8VG1KAI03YDM7XZ8JRQ60BCB8CA1','Ingrid','Newman','1997-12-15 '),
  ('magna.lorem@hotmail.ca','XJD27JXF3DW8SWQ77ETC5TP9DSW77UKI6CK6','Tasha','Randolph','2008-10-01 '),
  ('ullamcorper.eu@aol.ca','OGN75GPC3PM2GPN33BGQ8IC3CTA22BCV1HD6','Fredericka','Hayden','1975-09-24 '),
  ('tristique@aol.couk','CGF63HQC3BG4RPS41DSG5RU3MFV88GWU4MH1','Bo','Pratt','1962-03-19 '),
  ('cum.sociis@google.ca','RFM26BHW3PJ0MWW42LKS8MJ7OPI76RVI2WP7','Ria','Simmons','1978-10-23 '),
  ('fusce.mollis@hotmail.com','UUB30VEM6NM5QPK52SJY8KE2OGT77FSE5KN6','Vielka','Mcneil','1976-08-22 '),
  ('ac.eleifend.vitae@yahoo.ca','UGY56OOQ2MJ7JQO63GNE3OO3DAS88RTV5HD1','Bradley','Garrett','1971-04-23 '),
  ('vivamus.nisi@yahoo.org','QAP68OFH8CO5KAI68WJO8MF5UBG65NYF6PB5','Warren','Barnett','1975-09-28 '),
  ('curabitur@google.org','FQL86USC0PL8TKR98DCP3OQ3OWQ38TZJ5OI1','Baker','Vargas','1961-02-15 '),
  ('magnis.dis.parturient@outlook.ca','SVT28EGY3JK0YPK76HWP9OJ8JOX84WQU3KK6','Lysandra','Sparks','1971-12-12 '),
  ('ut.mi.duis@hotmail.ca','PGJ76GID3FP4MSG42HOC3GT7XQU72BLC3SC2','Lois','Alston','1990-10-16 ');

INSERT INTO movie_review(movie_id, customer_id, rating, review_text,review_date)
VALUES    (1,1,2.5,'adipiscing ligula. Aenean gravida nunc sed pede.','2021-09-29 '),
  (1,1,3.5,'laoreet lectus quis massa. Mauris vestibulum, neque sed dictum','2019-02-24 '),
  (1,1,0.5,'Sed eget lacus. Mauris non dui nec urna suscipit','2013-07-21 '),
  (1,1,1,'lobortis quam a felis ullamcorper viverra. Maecenas iaculis aliquet diam.','2019-04-11 '),
  (1,2,2,'pharetra nibh. Aliquam ornare, libero at auctor ullamcorper,','2013-11-21 '),
  (2,2,2,'Sed eget lacus. Mauris non','2022-07-26 '),
  (2,2,1,'Nulla semper tellus id nunc','2020-08-21 '),
  (2,3,4.5,'In nec orci. Donec nibh. Quisque nonummy ipsum non','2021-02-15 '),
  (2,3,1.5,'Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum','2015-06-15 '),
  (2,3,1,'pharetra sed, hendrerit a, arcu. Sed','2017-03-08 '),
  (3,3,2,'Sed eget lacus. Mauris non','2003-07-29 '),
  (3,3,1,'Nulla semper tellus id nunc','1993-01-01 '),
  (3,3,4.5,'In nec orci. Donec nibh. Quisque nonummy ipsum non','2019-01-28 '),
  (3,4,1.5,'Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum','2015-12-03 '),
  (3,4,1,'pharetra sed, hendrerit a, arcu. Sed','1989-10-24 '),
  (3,95,3,'Sed eget lacus. Mauris non','1997-06-20 '),
  (3,77,3,'Nulla semper tellus id nunc','2010-02-24 '),
  (3,84,4.5,'In nec orci. Donec nibh. Quisque nonummy ipsum non','2022-01-14 '),
  (3,16,1.5,'Aenean eget metus. In nec orci. Donec nibh. Quisque nonummy ipsum','1986-01-01 '),
  (3,5,1,'pharetra sed, hendrerit a, arcu. Sed','1985-11-16 '),
  (4,22,3.5,'Mauris blandit enim consequat purus. Maecenas libero est, congue a, aliquet','2015-07-05 '),
  (4,17,1,'placerat. Cras dictum ultricies ligula. Nullam enim. Sed nulla ante,','2004-03-17 '),
  (4,17,3,'ut eros non enim commodo','2017-04-12 '),
  (4,85,3,'mattis ornare, lectus ante dictum mi, ac mattis','2006-11-27 '),
  (4,85,4.5,'elit sed consequat auctor, nunc nulla vulputate dui, nec tempus','2014-11-18 '),
  (5,28,1,'accumsan sed, facilisis vitae, orci. Phasellus dapibus quam quis diam.','2016-06-03 '),
  (5,28,4.5,'neque. Sed eget lacus. Mauris non dui nec','1995-10-31 '),
  (5,61,4,'purus. Nullam scelerisque neque sed sem','2002-10-01 '),
  (5,78,1,'ante. Vivamus non lorem vitae','2002-08-18 '),
  (5,62,2,'at, libero. Morbi accumsan laoreet ipsum. Curabitur','1996-12-05 '),
  (6,58,2.5,'ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam nec enim.','2020-08-13 '),
  (6,28,4,'mattis. Integer eu lacus. Quisque imperdiet, erat nonummy ultricies ornare, elit elit','2014-01-21 '),
  (6,61,4,'Nunc ac sem ut dolor dapibus','2005-02-16 '),
  (6,29,3.5,'lacinia orci, consectetuer euismod est','2008-02-19 '),
  (6,71,4.5,'augue id ante dictum cursus. Nunc','2013-05-10 '),
  (7,88,1,'urna justo faucibus lectus, a sollicitudin orci sem eget massa.','1994-01-22 '),
  (7,88,4,'lacinia vitae, sodales at, velit.','2003-12-08 '),
  (7,28,2,'pellentesque a, facilisis non, bibendum sed, est. Nunc','2017-04-12 '),
  (7,28,3.5,'ultrices, mauris ipsum porta elit,','1997-12-08 '),
  (7,50,1,'Sed pharetra, felis eget varius ultrices, mauris ipsum porta elit, a','1993-04-26 '),
  (8,23,2.5,'turpis non enim. Mauris quis turpis vitae purus gravida sagittis. Duis','1996-12-11 '),
  (8,84,2,'nibh vulputate mauris sagittis placerat. Cras','2005-08-17 '),
  (8,18,4,'in consectetuer ipsum nunc id','2015-10-01 '),
  (8,94,1.5,'Vivamus non lorem vitae odio sagittis semper. Nam tempor','1998-03-06 '),
  (8,24,4,'cursus. Nunc mauris elit, dictum','2015-11-27 ');


INSERT INTO ticket(customer_ID,session_id,quantity)
VALUES  (70,33,2),
  (3,11,1),(3,10,2),(3,20,1),(3,15,3),(3,12,2),
  (28,11,1),(28,22,2),(28,16,1),(28,14,1),(28,6,1),
  (28,9,1),
  (70,32,1),
  (1,1,1),
  (1,2,3),
  (2,1,2),
  (70,35,2),
  (35,30,2),
  (19,32,3),
  (48,34,1),
  (39,18,2),
  (33,8,2),
  (8,11,2),
  (74,15,3),
  (26,4,1),
  (50,28,1),
  (21,34,3),
  (90,34,1),
  (40,3,3),
  (41,11,2),
  (24,7,3),
  (37,28,2),
  (8,26,2),
  (25,30,1),
  (8,31,2),
  (80,8,3),
  (11,8,3),
  (67,27,2),
  (14,10,2),
  (77,9,1),
  (9,3,3),
  (93,23,3),
  (44,18,3),
  (16,28,2),
  (86,26,2),
  (84,11,2),
  (14,13,2),
  (60,9,2),
  (85,32,1),
  (37,4,2),
  (83,3,1),
  (8,20,2),
  (100,14,3),
  (39,28,3),
  (29,8,2),
  (17,18,1),
  (49,4,1);
  



