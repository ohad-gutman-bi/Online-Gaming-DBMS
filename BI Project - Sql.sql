
USE master;
DROP DATABASE IF EXISTS Online_Gaming_DBMS;


CREATE DATABASE Online_Gaming_DBMS;


CREATE TABLE Languages_Table (
    Language_id   INT        CONSTRAINT lang_id_pk 
	                         PRIMARY KEY 
							 IDENTITY (1,1),
    Language_Code VARCHAR(2) CONSTRAINT lang_code_nn NOT NULL    -- (למשל, 'en', 'fr') 
	);
GO

CREATE TABLE Currency (
    Currency_id        INT            CONSTRAINT curr_id_pk               
	                                  PRIMARY KEY  
	                                  IDENTITY(1,1) ,

    Currency_name      NVARCHAR(100)  CONSTRAINT curr_name_nn NOT NULL, 

    Currency_ratetousd DECIMAL(10, 3) CONSTRAINT curr_ratetousd_positive 
	                                  CHECK (currency_ratetousd > 0)
);
GO

CREATE TABLE Country_Table (
    Country_ID   INT         CONSTRAINT country_id_pk             
	                         PRIMARY KEY
							 IDENTITY (1,1),

	Currency_ID  INT         CONSTRAINT Country_CurrencyID_fk      
	                         FOREIGN KEY (Currency_ID)                                                                
							 REFERENCES Currency (Currency_ID),
    Country_Name VARCHAR(50) CONSTRAINT country_name_nn NOT NULL  
	);
GO

CREATE TABLE UserStatus (
    Status_ID     INT            CONSTRAINT Status_id_pk 
	                             PRIMARY KEY 
					             IDENTITY (1,1),
    Status_Desc   NVARCHAR(20)   CONSTRAINT Status_Desc_nn                           NOT NULL 
	);

GO


CREATE TABLE Users 
 (UserId                  INT  
                                           CONSTRAINT Users_id_pk
										                                             PRIMARY KEY
										                                             IDENTITY (1,1),

 Country_ID               INT              CONSTRAINT Country_id_fk  
                                                                                     FOREIGN KEY (Country_ID)  
										   REFERENCES Country_Table (Country_ID),

 UserName                 VARCHAR(50)      CONSTRAINT Users_Name_nn                  NOT NULL       
                                           CONSTRAINT Users_Name_Unique              UNIQUE,

 User_registration_date   DATETIME         CONSTRAINT Users_regdate_nn               NOT NULL       
                                                                                     DEFAULT GETDATE(),
 User_DOB                 DATE             CONSTRAINT Users_dob_nn                   NOT NULL,

 User_Email               VARCHAR(25)      CONSTRAINT Users_email_nn                 NOT NULL       
                                           CONSTRAINT Users_email_uq                 UNIQUE,    
										   CONSTRAINT Users_email_ck            
                                           CHECK  (User_Email LIKE '_%@_%._%'),


 User_Password           VARCHAR(12)       CONSTRAINT Users_password_nn               NOT NULL        
                                           CONSTRAINT Users_password_length_ck          
										   CHECK  (LEN(User_Password) >= 10) , 
                                           CONSTRAINT Users_Password_Security_ck      
										   CHECK  (User_Password LIKE '%[0-9]%'                   -- 1. Must contain at least one number
                                           AND User_Password LIKE '%[^a-zA-Z0-9]%'),               --2. Must contain at least one special character 
 User_login_date         DATETIME                                                     NULL,
 User_logoff_date        DATETIME                                                     NULL,
 User_status_id          INT              CONSTRAINT Users_Statusid_nn                NOT NULL,                 
                                          CONSTRAINT User_statusid_fk 
										  FOREIGN KEY (User_status_id) 
										  REFERENCES UserStatus(Status_ID),
 User_session_time       DECIMAL(10,2)    CONSTRAINT Users_session_time_nn            NOT NULL                 
                                          CONSTRAINT User_Session_time_min 
										  CHECK(User_Session_time >= 1),                           -- זמן משחק כולל בדקות
);
GO

SELECT *
FROM User_Balance

CREATE TABLE User_Balance (
    WalletID      INT                      CONSTRAINT Bal_Walletid_pk             PRIMARY KEY 
	                                       CONSTRAINT Bal_Walletid_nn             NOT NULL 
										   CONSTRAINT Bal_Walletid_identity       IDENTITY (1,1),

    UserId        INT                      CONSTRAINT Bal_UserId_fk            
	                                                                              FOREIGN KEY (UserId)        REFERENCES Users(UserId),
    Currency_code INT                      CONSTRAINT Bal_Currency_code_fk        FOREIGN KEY (Currency_code) REFERENCES Currency(Currency_ID),
	);
GO

CREATE TABLE Gaming_Platforms (
    PlatformID   INT          CONSTRAINT Gaming_Platforms_id_pk       PRIMARY KEY
	                          CONSTRAINT Gaming_Platforms_id_nn       NOT NULL 
					          CONSTRAINT Gaming_Platforms_id_identity IDENTITY(1,1),
    PlatformDESC VARCHAR(20)  CONSTRAINT Gaming_Platforms_desc_nn     NOT NULL,
	);
GO

CREATE TABLE Game_Genres (
    GenereId   INT         CONSTRAINT Genres_id_pk                  PRIMARY KEY
	                       CONSTRAINT Genres_id_nn                  NOT NULL 
					       CONSTRAINT Genres_id_identity            IDENTITY (1,1),
    GenereDESC VARCHAR(20) CONSTRAINT Genres_id_desc                NOT NULL,
	);
GO


CREATE TABLE Games 
 (GameID                   INT                 CONSTRAINT Games_id_pk                            PRIMARY KEY                 
                                               CONSTRAINT Games_id_identity                      IDENTITY (1,1),
  GameName                 VARCHAR(50)         CONSTRAINT Games_id_nn                            NOT NULL             
                                               CONSTRAINT Games_id_uq                            UNIQUE,
  GameDev                  VARCHAR(25)         CONSTRAINT Games_id_nn                            NOT NULL,                                                                                             
  Genere_ID                INT                 CONSTRAINT Games_Genre_id_fk                      FOREIGN KEY(Genere_ID) 
                                                                                                 REFERENCES Game_Genres (GenereId )NOT NULL ,
  GameDescription          VARCHAR(50)         CONSTRAINT Games_desc_nn                          NOT NULL,
  MultiPlayer              BIT                 CONSTRAINT Games_multiplayer_nn                   NOT NULL,
  GameRealeseDate          DATETIME            CONSTRAINT Games_release_date_df                  DEFAULT GETDATE()                                      
                                               CONSTRAINT Games_release_date_nn                  NOT NULL,
  GamePrice                DECIMAL(5,2)        CONSTRAINT Games_Price_min 
                                               CHECK(GamePrice >= 100)                           NULL,
  GameReview               INT                 CONSTRAINT Games_rev_nn                           NOT NULL 
                                               CONSTRAINT Games_Rev_ck
											   CHECK(GameReview BETWEEN 1 AND 5),
);
GO



CREATE TABLE Game_Platform (
    PlatformID   INT     CONSTRAINT   Game_Platform_id_fk               
	                     FOREIGN KEY  (PlatformID) REFERENCES Gaming_Platforms(PlatformID)
						 CONSTRAINT   Game_Platform_id_nn                                    NOT NULL, 
	Game_ID       INT    CONSTRAINT   Game_Game_id_fk        
	                     FOREIGN KEY  (Game_ID)    REFERENCES Games(GameID)                 
						 CONSTRAINT   Game_Game_id_nn                                        NOT NULL,
	                     CONSTRAINT   Game_Platform_id  
						 PRIMARY KEY (PlatformID, Game_ID),
	);
GO


CREATE TABLE Game_Sessions 
 (Game_Sessions_ID                  INT       CONSTRAINT Game_sessions_Id_pk                            PRIMARY KEY   
                                              CONSTRAINT Game_sessions_Id_identity                      IDENTITY (1,1)    ,
  UserId                            INT       CONSTRAINT Game_session_UserId_fk                         FOREIGN KEY (UserId) 
                                                                                                        REFERENCES Users(UserId),
  Game_ID                           INT       CONSTRAINT Game_session_GameID                            FOREIGN KEY (Game_ID) 
                                                                                                        REFERENCES Games(GameID),
  Session_starttime                 DATETIME  CONSTRAINT Game_session_start_time_nn                     NOT NULL,
  Session_endtime                   DATETIME,
  SessionDuration AS  (DATEDIFF(MINUTE, session_starttime, session_endtime)),
           
 XP_Points                          INT,
 LevelReached                       INT,
 SessionResult                      VARCHAR(4),
 PlatformID                         INT  CONSTRAINT Game_session_PlatformID_fk                         FOREIGN KEY (PlatformID) 
                                                                                                       REFERENCES Gaming_Platforms(PlatformID),
 
);
GO


CREATE TABLE Transactions
 (TransactionID           INT   
                                CONSTRAINT Transactions_id_pk                        PRIMARY KEY 
                                CONSTRAINT Transactions_id_nn                        NOT NULL             
                                CONSTRAINT Transactions_id_identity                  IDENTITY (1,1),                       
								  
  UserId                  INT                                              
                               CONSTRAINT Transactions_userid_nn                     NOT NULL             
                               CONSTRAINT Transactions_userid_fk                     FOREIGN KEY (UserId)            
							                                                         REFERENCES Users(UserId),




  GameId                  INT  
                               CONSTRAINT Transactions_Gameid_nn                     NOT NULL             
                               CONSTRAINT Transactions_Gameid_fk                     FOREIGN KEY (GameId)            
							                                                         REFERENCES Games(GameId),


  Currency_code           INT  
                              CONSTRAINT Transactions_Currency_code_nn              NOT NULL               
                              CONSTRAINT Transactions_Currency_code_fk              FOREIGN KEY (Currency_code) 
						                                                            REFERENCES Currency(Currency_ID),


  Balance                 INT  
                              CONSTRAINT Transactions_Balance_nn                    NOT NULL             
							  CONSTRAINT Transactions_Balance_ck_min                CHECK (Balance >=0),


  Transaction_Amount      DECIMAL(10,2)     
                              CONSTRAINT Transactions_Balance_nn                    NOT NULL ,

  Transaction_Date        DATETIMEOFFSET                                            NOT NULL             
                              CONSTRAINT Transactions_date_df                       DEFAULT  GETDATE(),  
  PaymentMethod           VARCHAR(30)    
                              CONSTRAINT Transactions_paymentmethod_nn              NOT NULL,
  TransActionType         VARCHAR(30)                                       
                             CONSTRAINT Transactions_type_nn                        NOT NULL,
  ItemName                VARCHAR(30)                                       
                             CONSTRAINT Transactions_ItemName_nn                    NOT NULL,
  TransActionStatus       VARCHAR(10)                                       NOT NULL,
 CHECK (Balance >=Transaction_Amount),
);
GO


CREATE TABLE Achievments 
 (AchievmentID                              INT                        IDENTITY (1,1)                     PRIMARY KEY,
  GameID                                    INT  NOT NULL              CONSTRAINT check_Ach_GameID        FOREIGN KEY (GameID) REFERENCES Games(GameID),
  AchievmentName                            VARCHAR(20),
  AchievmentDesc                            VARCHAR(50),
  XpReward                                  INT,
	);
GO																						

CREATE TABLE User_Achievments 

 (
  UserID                            INT   NOT NULL CONSTRAINT check_ach_table_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID),
  AchievmentID                      INT    NOT NULL  CONSTRAINT check_ach_AchievmentID FOREIGN KEY (AchievmentID) REFERENCES Achievments(AchievmentID),
  AchievmentDate                    DATETIME NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_user_achievement  PRIMARY KEY (UserID, AchievmentID) 
	);
GO		

CREATE TABLE CountryLanguages (
    CountryID INT NOT NULL,
    LanguageID INT NOT NULL,
    CONSTRAINT PK_CountryLanguages PRIMARY KEY (CountryID, LanguageID),
    CONSTRAINT FK_CountryLanguages_Country FOREIGN KEY (CountryID) REFERENCES Country_Table(Country_ID),
    CONSTRAINT FK_CountryLanguages_Language FOREIGN KEY (LanguageID) REFERENCES [Languages_Table](Language_ID)
);
GO



-- Map the language codes to your specific Country IDs
INSERT INTO CountryLanguages (CountryID, LanguageID)
VALUES 
-- 1. United States ('en')
(1, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'en')),

-- 2. Germany ('de')
(2, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'de')),

-- 3. United Kingdom ('en')
(3, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code =  'en')),

-- 4. Japan ('ja')
(4, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'ja')),

-- 5. Australia ('en')
(5, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code  = 'en')),

-- 6. Canada ('en', 'fr')
(6, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'en')),
(6, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'fr')),

-- 7. Switzerland ('de', 'fr', 'it')
(7, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'de')),
(7, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'fr')),
(7, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'it')),

-- 8. China ('zh')
(8, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'zh')),

-- 9. Sweden ('sv')
(9, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'sv')),

-- 10. New Zealand ('en')
(10, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code  = 'en')),

-- 11. Israel ('he', 'ar')
(11, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'he')),
(11, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'ar')),

-- 12. Brazil ('pt')
(12, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='pt')),

-- 13. India ('hi', 'en')
(13, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='hi')),
(13, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='en')),

-- 14. South Korea ('ko')
(14, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='ko')),

-- 15. South Africa ('en') -- (From your available 20 codes, 'en' fits best)
(15, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='en')),

-- 16. Turkey ('tr')
(16, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'tr')),

-- 17. Russia ('ru')
(17, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'ru')),

-- 18. Mexico ('es')
(18, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'es')),

-- 19. Singapore ('en', 'zh')
(19, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code = 'en')),
(19, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='zh')),

-- 20. Hong Kong ('zh', 'en')
(20, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='zh')),
(20, (SELECT Language_ID FROM [Languages_Table] WHERE Language_code ='en'));
GO













INSERT INTO Languages_Table (Language_Code) VALUES 
('en'), ('es'), ('fr'), ('de'), ('it'), ('ja'), ('ko'), ('zh'), ('ru'), ('pt'),
('he'), ('ar'), ('nl'), ('pl'), ('tr'), ('sv'), ('no'), ('fi'), ('da'), ('hi');
GO

SELECT *
FROM Country_Table

INSERT INTO Currency (Currency_name, Currency_ratetousd) VALUES 
(N'US Dollar', 1.000), (N'Euro', 1.080), (N'British Pound', 1.270), (N'Japanese Yen', 0.006), (N'Australian Dollar', 0.660),
(N'Canadian Dollar', 0.730), (N'Swiss Franc', 1.110), (N'Chinese Yuan', 0.140), (N'Swedish Krona', 0.095), (N'New Zealand Dollar', 0.610),
(N'Israeli New Shekel', 0.270), (N'Brazilian Real', 0.190), (N'Indian Rupee', 0.012), (N'South Korean Won', 0.0007), (N'South African Rand', 0.054),
(N'Turkish Lira', 0.031), (N'Russian Ruble', 0.011), (N'Mexican Peso', 0.059), (N'Singapore Dollar', 0.740), (N'Hong Kong Dollar', 0.130);
GO

INSERT INTO Country_Table (Country_ID, Currency_ID, Country_Name) VALUES 
(1, 1, 'United States'), (2, 2, 'Germany'), (3, 3, 'United Kingdom'), (4, 4, 'Japan'), (5, 5, 'Australia'),
(6, 6, 'Canada'), (7, 7, 'Switzerland'), (8, 8, 'China'), (9, 9, 'Sweden'), (10, 10, 'New Zealand'),
(11, 11, 'Israel'), (12, 12, 'Brazil'), (13, 13, 'India'), (14, 14, 'South Korea'), (15, 15, 'South Africa'),
(16, 16, 'Turkey'), (17, 17, 'Russia'), (18, 18, 'Mexico'), (19, 19, 'Singapore'), (20, 20, 'Hong Kong');
GO

INSERT INTO UserStatus (Status_Desc) VALUES 
(N'Active'), (N'Inactive'), (N'Banned');
GO

INSERT INTO Users (Language_ID, Country_ID, UserName, User_registration_date, UserDOB, User_Email, User_Password, User_latest_login_date, User_latest_logoff_date, User_status_id, User_session_time) VALUES 
(1, 1, 'AlphaGamer', '2025-01-10 14:30:00', '2000-05-15', 'alpha@gmail.com', 'P@ssword123!', '2026-06-25 10:00:00', '2026-06-25 12:00:00', 1, 120.0),
(2, 2, 'ShadowBlader', '2025-02-12 16:45:00', '1998-11-22', 'shad@gmail.com', 'Bl@deRunner1', '2026-06-24 15:30:00', '2026-06-24 18:15:00', 1, 165.0),
(3, 3, 'QuantumForce', '2025-03-01 09:15:00', '1995-03-30', 'quant@gmail.com', 'Str0ng#Pass!', '2026-06-20 08:00:00', '2026-06-20 09:30:00', 2, 90.0),
(4, 4, 'CyberNinja', '2025-03-15 21:00:00', '2002-07-09', 'ninja@gmail.com', 'Sh0riken_99', '2026-06-26 01:00:00', '2026-06-26 04:00:00', 1, 180.0),
(5, 5, 'VortexRider', '2025-04-05 11:20:00', '2001-01-25', 'vort@gmail.com', 'Sp1n_Cycle$', '2026-06-22 19:00:00', '2026-06-22 20:30:00', 1, 90.0),
(6, 6, 'BlazePhoenix', '2025-04-20 18:10:00', '1997-12-12', 'blaze@gmail.com', 'Fiery#12345', '2026-06-25 23:00:00', NULL, 3, 300.0),
(7, 7, 'FrostByte', '2025-05-01 06:40:00', '2004-04-04', 'frost@gmail.com', 'Ic3_C0ld!!!!', '2026-06-15 14:00:00', '2026-06-15 14:45:00', 3, 45.0),
(8, 8, 'DragonClaw', '2025-05-19 13:55:00', '1993-08-18', 'drag@gmail.com', 'Myth1c_Dr@g', '2026-06-26 09:00:00', NULL, 2, 150.0),
(9, 9, 'StormBringer', '2025-06-02 10:05:00', '1999-10-10', 'storm@gmail.com', 'Thund3r$t0rm', '2026-06-23 11:11:00', '2026-06-23 13:11:00', 2, 120.0),
(10, 10, 'MysticSorcerer', '2025-06-22 17:50:00', '1996-02-28', 'myst@gmail.com', 'M@g1c_Wand1', '2026-06-24 20:00:00', '2026-06-24 23:45:00', 1, 225.0),
(11, 11, 'IronTitan', '2025-07-04 08:30:00', '1990-06-01', 'iron@gmail.com', 'St33l_W@ll!', '2026-06-26 10:30:00', NULL, 1, 30.0),
(12, 12, 'NovaStar', '2025-07-29 23:15:00', '2003-09-14', 'nova@gmail.com', 'Sup3rn0va*1', '2026-06-21 17:00:00', '2026-06-21 19:00:00', 3, 120.0),
(13, 13, 'RogueHunter', '2025-08-11 12:00:00', '2001-11-05', 'rogue@gmail.com', 'St3@lth_M0d', '2026-06-25 04:00:00', '2026-06-25 05:30:00', 1, 90.0),
(14, 14, 'PixelArtisan', '2025-08-30 15:40:00', '1994-04-20', 'pixel@gmail.com', '8B1t_M@st3r', '2026-06-18 13:00:00', '2026-06-18 16:00:00', 2, 180.0),
(15, 15, 'ApexPredator', '2025-09-14 20:25:00', '2000-01-01', 'apex@gmail.com', 'Ch@mp1on_#1', '2026-06-26 08:00:00', '2026-06-26 11:00:00', 1, 180.0),
(16, 16, 'CosmicVoyager', '2025-10-02 11:10:00', '1992-05-17', 'cosm@gmail.com', 'G@l@xy_Tr0p', '2026-06-24 12:00:00', '2026-06-24 15:00:00', 1, 180.0),
(17, 17, 'NeonKnight', '2025-10-25 19:50:00', '1999-03-23', 'neon@gmail.com', 'Gl0w_Sw0rd1', '2026-06-25 21:00:00', '2026-06-25 23:30:00', 2, 150.0),
(18, 18, 'BulletStorm', '2025-11-12 14:00:00', '1995-07-07', 'bull@gmail.com', 'R3@dy_F1r3!', '2026-06-26 05:00:00', '2026-06-26 07:30:00', 1, 150.0),
(19, 19, 'ZephyrWind', '2025-12-05 09:30:00', '2005-10-30', 'zeph@gmail.com', 'B r33z3_99!', '2026-06-23 16:00:00', '2026-06-23 17:45:00', 1, 105.0),
(20, 20, 'OmegaZero', '2025-12-28 16:15:00', '1991-12-25', 'omeg@gmail.com', 'Th3_3nd_12#', '2026-06-26 09:45:00', NULL, 3, 75.0);
GO

INSERT INTO User_Balance (UserId, Currency_code) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(11, 11), (12, 12), (13, 13), (14, 14), (15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20);
GO

INSERT INTO Gaming_Platforms (PlatformDESC) VALUES 
('PC'), ('PlayStation 5'), ('Xbox Series X'), ('Nintendo Switch'), ('PlayStation 4'), ('Xbox One'), ('Nintendo 3DS'), ('Steam Deck');
GO

INSERT INTO Game_Genres (GenereDESC) VALUES 
('RPG'), ('FPS'), ('Survival'), ('Strategy'),
('Sports'), ('Racing'), ('Puzzle'), ('Horror'),
('Fighting'), ('Simulation'), ('Action-Adventure'), ('Sandbox'),
('Battle Royale'), ('Card Game'), ('Rhythm'), ('Stealth'), ('Educational');
GO

INSERT INTO Games (GameName, GameDev, Genere_ID, GameDescription, MultiPlayer, GameRealeseDate, GamePrice, GameReview) VALUES 
('World of Quest', 'Epic Interactive', 1, 'An open world massive fantasy RPG.', 1, '2024-01-15', 120.00, 5),
('Frag Zone', 'BulletProof Studio', 2, 'Tactical fast paced shooter.', 1, '2024-03-20', 100.00, 4),
('Arena of Legends', 'Nexus Games', 3, '5v5 competitive online arena.', 1, '2023-11-05', 149.99, 4),
('Wilderness', 'Greenwood Dev', 4, 'Survive the harsh arctic tundra environment.', 0, '2024-05-12', 110.00, 3),
('Empire Builder X', 'Strategy Lab', 10, 'Turn-based global conquest simulation.', 1, '2022-08-18', 159.50, 5),
('Grid Iron 2026', 'EA Sports Labs', 5, 'The most realistic football sim.', 1, '2025-09-01', 199.99, 2),
('Asphalt Burner', 'Nitro Kings', 6, 'Hyper realistic street legal racing.', 1, '2024-07-22', 125.00, 4),
('Bounce Knight', 'Pixel Flex', 12, 'Hardcore indie 2D knight quest.', 0, '2023-02-14', 105.00, 5),
('Enigma Box', 'MindMelt', 7, 'Mind-bending psychological puzzle gameplay.', 0, '2024-10-31', 115.00, 4),
('Don''t Breathe', 'Phobia Interactive', 8, 'Co-op psychological horror experience.', 1, '2025-10-15', 130.00, 5),
('Galaxy Reborn', 'Cosmos Interactive', 17, 'Explore billions of procedurally stars.', 1, '2021-04-20', 250.00, 3),
('Street Clash v', 'Iron Fist Dev', 9, 'Arcade style fighting tournament.', 1, '2025-02-11', 140.00, 4),
('Flight Sim 2026', 'Aero Simulation', 10, 'Highly accurate civil aviation simulation.', 0, '2025-12-25', 299.99, 5),
('Shadow Creed', 'Stealth Works', 11, 'Historical third-person action story.', 1, '2023-06-30', 160.00, 4),
('Block Craft Infinite', 'Cube World', 12, 'Infinite block building sandbox.', 1, '2020-05-17', 100.00, 5),
('Drop Zone Royale', 'Titan Games', 13, '100 players land, only one survives.', 1, '2024-02-28', 110.00, 4),
('Spell Cards Online', 'Mythos Lab', 14, 'Strategic trading card deck-builder.', 1, '2023-04-19', 100.00, 4),
('Beat Dropper', 'Neon Pulse', 15, 'Synthwave fast-paced rhythm hitting.', 1, '2025-05-05', 119.00, 5),
('Silent Assassin', 'Ghost Team', 16, 'Infiltrate secure compounds undetected.', 1, '2024-08-14', 145.00, 4),
('Math Quest Odyssey', 'EduKids', 17, 'Gamified advanced algebra learning RPG.', 0, '2025-01-01', 100.00, 3);
GO

INSERT INTO Game_Platform (PlatformID, Game_ID) VALUES 
(1, 1), (1, 2), (2, 2), (3, 2), (4, 4),
(1, 5), (2, 6), (3, 6), (1, 7), (2, 7),
(4, 8), (1, 9), (1, 10), (2, 10), (3, 10),
(1, 11), (2, 12), (3, 12), (1, 13), (2, 14);
GO

SELECT *
FROM Users

INSERT INTO Game_Sessions (UserId, Game_ID, Session_starttime, Session_endtime, XP_Points, LevelReached, SessionResult, PlatformID) VALUES 
(1, 1, '2026-06-25 10:00:00', '2026-06-25 12:00:00', 1500, 5, 'WIN', 1),
(2, 2, '2026-06-24 15:30:00', '2026-06-24 18:15:00', 2200, 12, 'LOSS', 1),
(3, 3, '2026-06-20 08:00:00', '2026-06-20 09:30:00', 800, 2, 'DRAW', 1),
(4, 2, '2026-06-26 01:00:00', '2026-06-26 04:00:00', 3500, 20, 'WIN', 2),
(5, 4, '2026-06-22 19:00:00', '2026-06-22 20:30:00', 600, 4, 'WIN', 4),
(6, 5, '2026-06-25 23:00:00', '2026-06-26 02:00:00', 4000, 45, 'WIN', 1),
(7, 2, '2026-06-15 14:00:00', '2026-06-15 14:45:00', 150, 1, 'LOSS', 3),
(8, 1, '2026-06-26 09:00:00', '2026-06-26 11:30:00', 1800, 8, 'WIN', 1),
(9, 7, '2026-06-23 11:11:00', '2026-06-23 13:11:00', 1200, 6, 'WIN', 2),
(10, 1, '2026-06-24 20:00:00', '2026-06-24 23:45:00', 2900, 15, 'LOSS', 1),
(11, 2, '2026-06-26 10:30:00', '2026-06-26 11:00:00', 400, 3, 'WIN', 1),
(12, 6, '2026-06-21 17:00:00', '2026-06-21 19:00:00', 1000, 10, 'LOSS', 2),
(13, 2, '2026-06-25 04:00:00', '2026-06-25 05:30:00', 950, 7, 'WIN', 3),
(14, 8, '2026-06-18 13:00:00', '2026-06-18 16:00:00', 5000, 50, 'WIN', 4),
(15, 6, '2026-06-26 08:00:00', '2026-06-26 11:00:00', 2100, 14, 'WIN', 3),
(16, 7, '2026-06-24 12:00:00', '2026-06-24 15:00:00', 1300, 9, 'LOSS', 1),
(17, 10, '2026-06-25 21:00:00', '2026-06-25 23:30:00', 1700, 11, 'WIN', 2),
(18, 12, '2026-06-26 05:00:00', '2026-06-26 07:30:00', 2500, 18, 'WIN', 3),
(19, 14, '2026-06-23 16:00:00', '2026-06-23 17:45:00', 1100, 5, 'LOSS', 2),
(20, 13, '2026-06-26 09:45:00', '2026-06-26 11:00:00', 850, 4, 'WIN', 1);
GO

INSERT INTO Game_Sessions (UserId, Game_ID, Session_starttime, Session_endtime, XP_Points, LevelReached, SessionResult, PlatformID) VALUES 
(6, 1, '2026-06-25 13:00:00', '2026-06-25 14:30:00', 1500, 5, 'WIN', 1),
(4, 5, '2026-06-24 15:30:00', '2026-06-24 18:15:00', 2200, 12, 'LOSS', 1),
(3, 3, '2026-06-20 08:00:00', '2026-06-20 09:30:00', 800, 2, 'DRAW', 1),
(4, 2, '2026-06-26 01:00:00', '2026-06-26 04:00:00', 3500, 20, 'WIN', 2),
(5, 4, '2026-06-22 19:00:00', '2026-06-22 20:30:00', 600, 4, 'WIN', 4),
(18, 3, '2026-06-25 23:00:00', '2026-06-26 02:00:00', 4000, 45, 'WIN', 1),
(9, 2, '2026-06-15 14:00:00', '2026-06-15 14:45:00', 150, 1, 'LOSS', 3),
(8, 1, '2026-06-26 09:00:00', '2026-06-26 11:30:00', 1800, 8, 'WIN', 1),
(9, 7, '2026-06-23 11:11:00', '2026-06-23 13:11:00', 1200, 6, 'WIN', 2),
(10, 1, '2026-06-24 20:00:00', '2026-06-24 23:45:00', 2900, 15, 'LOSS', 1),
(10, 2, '2026-06-26 10:30:00', '2026-06-26 11:00:00', 400, 3, 'WIN', 1),
(12, 6, '2026-06-21 17:00:00', '2026-06-21 19:00:00', 1000, 10, 'LOSS', 2),
(13, 2, '2026-06-25 04:00:00', '2026-06-25 05:30:00', 950, 7, 'WIN', 3),
(14, 8, '2026-06-18 13:00:00', '2026-06-18 16:00:00', 5000, 50, 'WIN', 4),
(15, 6, '2026-06-26 08:00:00', '2026-06-26 11:00:00', 2100, 14, 'WIN', 3),
(13, 7, '2026-06-24 12:00:00', '2026-06-24 15:00:00', 1300, 9, 'LOSS', 1),
(12, 10, '2026-06-25 21:00:00', '2026-06-25 23:30:00', 1700, 11, 'WIN', 2),
(18, 12, '2026-06-26 05:00:00', '2026-06-26 07:30:00', 2500, 18, 'WIN', 3),
(19, 14, '2026-06-23 16:00:00', '2026-06-23 17:45:00', 1100, 5, 'LOSS', 2),
(20, 13, '2026-06-26 09:45:00', '2026-06-26 11:00:00', 850, 4, 'WIN', 1);
GO



-- Constraint: Balance >= Transaction_Amount and Balance >= 0
INSERT INTO Transactions (UserId, GameId, Currency_code, Balance, Transaction_Amount, Transaction_Date, PaymentMethod, TransActionType, ItemName, TransActionStatus) VALUES 
(1, 1, 1, 500, 50.00, '2026-01-15 12:00:00 +00:00', 'Credit Card', 'Purchase', 'Expansion Pack 1', 'Success'),
(2, 2, 2, 1000, 12.50, '2026-02-20 14:30:00 +01:00', 'PayPal', 'Microtransaction', 'Weapon Skin', 'Success'),
(3, 3, 3, 250, 150.00, '2026-03-05 09:00:00 +00:00', 'Credit Card', 'Purchase', 'Season Pass', 'Success'),
(4, 2, 4, 15000, 3000.00, '2026-03-25 18:15:00 +09:00', 'Crypto', 'Purchase', 'In-game Coins Bundle', 'Success'),
(5, 4, 5, 300, 45.00, '2026-04-10 11:00:00 +10:00', 'Debit Card', 'Purchase', 'DLC Arctic Outpost', 'Success'),
(6, 5, 6, 800, 159.50, '2026-04-22 15:20:00 -04:00', 'PayPal', 'Game Purchase', 'Empire Builder Game', 'Success'),
(7, 2, 7, 100, 20.00, '2026-05-02 08:45:00 +02:00', 'Credit Card', 'Microtransaction', 'Loot Box x5', 'Success'),
(8, 1, 8, 450, 120.00, '2026-05-20 13:00:00 +08:00', 'Alipay', 'Game Purchase', 'World of Quest Game', 'Success'),
(9, 7, 9, 2000, 125.00, '2026-06-03 10:10:00 +01:00', 'Bank Transfer', 'Game Purchase', 'Asphalt Burner Game', 'Success'),
(10, 1, 10, 600, 60.00, '2026-06-24 19:30:00 +12:00', 'Credit Card', 'Purchase', 'Mount Unlock', 'Success'),
(11, 2, 11, 150, 50.00, '2026-06-25 09:00:00 +03:00', 'Debit Card', 'Microtransaction', 'Battle Pass Level Up', 'Success'),
(12, 6, 12, 1200, 199.99, '2026-06-21 16:30:00 -03:00', 'Credit Card', 'Game Purchase', 'Grid Iron 2026 Game', 'Success'),
(13, 2, 13, 5000, 2500.00, '2026-06-24 22:00:00 +05:30', 'UPI', 'Purchase', 'Ruby Diamond Pack', 'Success'),
(14, 8, 14, 90000, 45000.00, '2026-06-18 12:00:00 +09:00', 'Mobile Pay', 'Purchase', 'Collector Gold Pack', 'Success'),
(15, 6, 15, 750, 199.99, '2026-06-25 07:00:00 +02:00', 'Credit Card', 'Game Purchase', 'Grid Iron 2026 Game', 'Success'),
(16, 7, 16, 400, 125.00, '2026-06-23 11:00:00 +03:00', 'PayPal', 'Game Purchase', 'Asphalt Burner Game', 'Success'),
(17, 10, 17, 3400, 130.00, '2026-06-25 20:00:00 +03:00', 'Credit Card', 'Game Purchase', 'Don''t Breathe Game', 'Success'),
(18, 12, 18, 800, 140.00, '2026-06-25 23:45:00 -06:00', 'Debit Card', 'Game Purchase', 'Street Clash v Game', 'Success'),
(19, 14, 19, 500, 160.00, '2026-06-23 15:00:00 +08:00', 'Credit Card', 'Game Purchase', 'Shadow Creed Game', 'Success'),
(20, 13, 20, 1500, 299.99, '2026-06-26 09:00:00 +08:00', 'PayPal', 'Game Purchase', 'Flight Sim 2026 Game', 'Success');
GO


INSERT INTO Achievments (GameID, AchievmentName, AchievmentDesc, XpReward) VALUES 
(1, 'First Steps', 'Complete the tutorial quest.', 100),
(1, 'Dragon Slayer', 'Defeat the mythical red dragon.', 1000),
(2, 'Sharpshooter', 'Get 5 headshots in a single session.', 250),
(2, 'Unstoppable', 'Win 10 matches without dying.', 1500),
(3, 'Pentakill', 'Eliminate all 5 enemy heroes.', 800),
(4, 'Survive the Night', 'Survive your first freezing night.', 150),
(4, 'Happy Camper', 'Build your first camp.', 100),
(5, 'World Conqueror', 'Conquer all factions in a map.', 2000),
(6, 'Touchdown King', 'Score 5 touchdowns in one game.', 300),
(7, 'Speed Demon', 'Reach a speed of 300 km/h.', 200),
(7, 'Test Drive', 'Finish the Tutorial.', 150),
(7, 'Winner Takes it All', 'Win Your First Car .', 300),
(8, 'Flawless Run', 'Complete stage 1 without resetting.', 500),
(9, 'Big Brain', 'Solve the master cube under 2 minutes.', 400),
(10, 'Ghost Buster', 'Exorcise your first spirit.', 350),
(11, 'Deep Space Explorer', 'Visit 100 unique star systems.', 1200),
(12, 'Perfect KO', 'Win a round with full health.', 300),
(13, 'Safe Landing', 'Land a commercial plane during a storm.', 600),
(14, 'Master of Stealth', 'Complete a mission completely unseen.', 700),
(15, 'Diamond Miner', 'Find your first block of diamond ore.', 200),
(16, 'Lone Survivor', 'Be the last player standing in Royale.', 1000),
(17, 'Deck Master', 'Win a match using only basic cards.', 500),
(18, 'Perfect Rhythm', 'Hit 100% of notes correctly.', 600),
(19, 'Legend', 'Infiltrate and  Recover Secured Goverment Files.', 500),
(20, 'Einstein', 'Solve 100 Question Level 10 OR Above', 500);
GO


INSERT INTO User_Achievments (UserID, AchievmentID, AchievmentDate) VALUES 
(1, 1, '2026-06-25 11:00:00'),
(1, 2, '2026-06-25 11:55:00'),
(2, 3, '2026-06-24 16:30:00'),
(4, 4, '2026-06-26 03:30:00'),
(5, 6, '2026-06-22 19:45:00'),
(6, 7, '2026-06-26 01:15:00'),
(8, 1, '2026-06-26 09:30:00'),
(9, 9, '2026-06-23 12:00:00'),
(10, 1, '2026-06-24 21:00:00'),
(11, 3, '2026-06-26 10:45:00'),
(14, 10, '2026-06-18 14:20:00'),
(15, 8, '2026-06-26 09:10:00'),
(17, 12, '2026-06-25 22:15:00'),
(18, 14, '2026-06-26 06:20:00'),
(20, 15, '2026-06-26 10:30:00'),
(2, 4, '2026-06-24 17:45:00'),
(4, 3, '2026-06-26 02:00:00'),
(6, 8, '2026-06-26 01:45:00'),
(8, 2, '2026-06-26 11:00:00'),
(14, 11, '2026-06-18 15:30:00');
GO

-- All Game Sessions for a Specific User
SELECT Session_starttime,Session_endtime, UserId
FROM Game_Sessions 
ORDER BY UserId

--Most Popular Games by Sessioin Count
SELECT Count(*) Sessions_Amt, G.GameID, G.GameName
FROM Game_Sessions GS JOIN Games G
ON G.GameId = GS.Game_ID
GROUP BY G.GameID, G.GameName
ORDER BY Count(*)  DESC

--In-Game Purchases By User
SELECT Sum(Transaction_Amount*Currency_ratetousd) AS 'Amt Spent in $', 
B.UserId
FROM User_Balance B
JOIN Transactions T
ON B.Currency_code = T.Currency_code
JOIN Currency C ON C.Currency_ID =  T.Currency_code
GROUP BY B.UserId

SELECT 
    c.Country_Name AS [Country Name], 
    l.Language_code AS [Language Code]
FROM 
    CountryLanguages cl
INNER JOIN 
    Country_Table c ON cl.CountryID = c.Country_ID
INNER JOIN 
    [Languages_Table] l ON cl.LanguageID = l.Language_ID;