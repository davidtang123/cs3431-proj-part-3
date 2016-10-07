-- Hospital Data - Floors 1, 3, 5

drop table Floor cascade constraints;

create table Floor (
	FloorID		char(2),
	Building	varchar2(15),
	FloorLevel		number(1),
	constraint Floor_pk primary key (FloorID),
	constraint Floor_un unique(Building, FloorLevel),
	constraint BuildingVal check (Building in ('Faulkner', 'Belkin')),
	constraint LevelVal check (FloorLevel between 1 and 7)
);

drop table Location cascade constraints;

create table Location (
	LocationID		char(9),
	LocationName	varchar2(45),
	LocationType	varchar2(15),
	xcoord			number(3),
	ycoord			number(3),
	FloorID			char(2),
	constraint Location_pk primary key (LocationID),
	constraint Location_un1 unique (LocationName),
	constraint Location_un2 unique (xcoord, ycoord, FloorID),
	constraint LocationTypeVal check (LocationType in ('Office', 'Service', 'Hallway', 'Elevator')),
	constraint Location_fk foreign key (FloorID) references Floor (FloorID)
);

-- Location ID naming convention is
-- 1st char is the 1st letter of the Building
-- 2nd char is the floor level
-- 3rd char is the 1st letter of the location type
-- 4th to 9th chars are either the locationname or the xy coordinates
-- if the locationname or xycoordinates are shorter than 6 chars,
-- use 0 as a filler

-- Although it is possible to make Elevator a boolean-type attribute, adding it to the LocationType is more flexible

drop table Neighbor cascade constraints;

create table Neighbor (		-- Note this table is a collection of map edges
	Location1	char(9),
	Location2	char(9),
	constraint Neighbor_pk primary key (Location1, Location2),
	constraint Neighbor_fk1 foreign key (Location1) references Location(LocationID),
	constraint Neighbor_fk2 foreign key (Location2) references Location(LocationID)
	);

drop table Services cascade constraints;

create table Services (
	ServiceName	varchar2(50),
	HealthType	varchar2(15),
	constraint Services_pk primary key (ServiceName),
	constraint ServicesHealthVal check (HealthType in ('Service', 'Practice'))
);

drop table ResidesIn cascade constraints;

create table ResidesIn (
	ServiceName	varchar2(50),
	LocationID	char(9),
	constraint ResidesIn_pk primary key (ServiceName, LocationID),
	constraint ResidesInService_fk foreign key (ServiceName) references Services (ServiceName),
	constraint ResidesInLocation_fk foreign key (LocationID) references Location (LocationID)
);

drop table Provider cascade constraints;

create table Provider (
	ProviderID	number (4),
	FirstName	varchar2(15),
	LastName	varchar2(20),
	constraint Provider_pk primary key (ProviderID)
);

drop table Title cascade constraints;

create table Title (
	Acronym	varchar2(6),
	TitleName	varchar2(50),
	constraint Title_pk primary key (Acronym)
);

drop table ProviderTitle cascade constraints;

create table ProviderTitle (
	ProviderID	number(4),
	Acronym		varchar2(6),
	constraint ProviderTitle_pk primary key (ProviderID, Acronym),
	constraint ProviderTitleProv_fk foreign key (ProviderID) references Provider(ProviderID),
	constraint ProviderTitleAcr_fk foreign key (Acronym) references Title (Acronym)
);

drop table Office cascade constraints;

create table Office (
	ProviderID	number(4),
	LocationID		char(9),
	constraint Office_pk primary key (ProviderID, LocationID),
	constraint OfficeProv_fk foreign key (ProviderID) references Provider(ProviderID),
	constraint OfficeLocation_fk foreign key (LocationID) references Location (LocationID)
);

drop table Path cascade constraints;

create table Path (
	PathID	number(7), -- large enough for the software developers using it
	PathStart	varchar2(45),
	PathEnd		varchar2(45),
	constraint Path_pk primary key (PathID),
	constraint PathStart_fk foreign key (PathStart) references Location (LocationName),
	constraint PathEnd_fk foreign key (PathEnd) references Location (LocationName)
);

drop table PathContains cascade constraints;

create table PathContains (
	PathID		number(7),
	LocationID	char(9),
	PathOrder	number(4),
	EndPointType	varchar2(15),
	constraint PathContains_pk primary key (PathID, LocationID),
	constraint PathContainsPath_pk foreign key (PathID) references Path(PathID),
	constraint PathContainsLocation_fk foreign key (LocationID) references Location (LocationID),
	constraint PathOrderVal check (PathOrder >= 1),
	constraint PathEndPointVal check (EndPointType in ('Start', 'End', 'Midpoint'))
);

-- Entering the data for floors 1, 3, and 5
-- Services that specified a floor and did not appear in the map
-- were assigned to either the Atrium Lobby for the first floor
-- or the Hillside Lobby for the third floor.
insert into Floor values ('F1', 'Faulkner', 1);
insert into Floor values ('F2', 'Faulkner', 2);
insert into Floor values ('F3', 'Faulkner', 3);
insert into Floor values ('F4', 'Faulkner', 4);
insert into Floor values ('F5', 'Faulkner', 5);
insert into Floor values ('F6', 'Faulkner', 6);
insert into Floor values ('F7', 'Faulkner', 7);
insert into Floor values ('B1', 'Belkin', 1);
insert into Floor values ('B2', 'Belkin', 2);
insert into Floor values ('B3', 'Belkin', 3);
insert into Floor values ('B4', 'Belkin', 4);

insert into Location values ('F1HATRELE', 'Atrium Elevators 1', 'Elevator', 422, 295, 'F1');
insert into Location values ('F1HATRLOB', 'Atrium Lobby', 'Hallway', 431, 228, 'F1');
insert into Location values ('F1SBLOODD', 'Blood Draw Special Testing', 'Service', 388, 332, 'F1');
insert into Location values ('F1SDAYSUR', 'Day Surgery', 'Service', 481, 450, 'F1');
insert into Location values ('F1SEMERGE', 'Emergency', 'Service', 303, 334, 'F1');
insert into Location values ('F1HEMERGE', 'Emergency Entrance', 'Hallway', 300, 290, 'F1');
insert into Location values ('F1SGIENDO', 'GI/Endoscopy', 'Service', 351, 437, 'F1');
insert into Location values ('F1HHILELE', 'Hillside Elevators 1', 'Elevator', 410, 549, 'F1');
insert into Location values ('F1SKIOSK0', 'Kiosk 1', 'Service', 420, 263, 'F1');
insert into Location values ('F1HMAINEN', 'Main Entrance', 'Hallway', 430, 209, 'F1');
insert into Location values ('F1SPATIEN', 'Patient Registration / Financial Counseling', 'Service', 380, 325, 'F1');
insert into Location values ('F1SPREOPE', 'Preoperative Evaluation', 'Service', 434, 349, 'F1');
insert into Location values ('F1SRADIOL', 'Radiology', 'Service', 501, 337, 'F1');
insert into Location values ('F1SSTARBU', 'Starbucks', 'Service', 375, 237, 'F1');
insert into Location values ('F1STAICLE', 'Taiclet Family Center', 'Service', 326, 326, 'F1');
insert into Location values ('F1VALETP', 'Valet Parking', 'Service', 429, 177, 'F1');
insert into Location values ('F1H000001', 'F1H1', 'Hallway', 434, 254, 'F1');
insert into Location values ('F1H000002', 'F1H2', 'Hallway', 434, 292, 'F1');
insert into Location values ('F1H000003', 'F1H3', 'Hallway', 434, 332, 'F1');
insert into Location values ('F1H000004', 'F1H4', 'Hallway', 478, 332, 'F1');
insert into Location values ('F1H000005', 'F1H5', 'Hallway', 434, 435, 'F1');
insert into Location values ('F1H000006', 'F1H6', 'Hallway', 478, 434, 'F1');
insert into Location values ('F1H000007', 'F1H7', 'Hallway', 434, 546, 'F1');
insert into Location values ('F3O3A0000', '3A', 'Office', 382, 135, 'F3');
insert into Location values ('F3O3B0000', '3B', 'Office', 437, 128, 'F3');
insert into Location values ('F3O3C0000', '3C', 'Office', 452, 135, 'F3');
insert into Location values ('F3HATRELE', 'Atrium Elevators 3', 'Elevator', 410, 168, 'F3');
insert into Location values ('F3SCAFETE', 'Cafeteria', 'Service', 422, 258, 'F3');
insert into Location values ('F3SHUVOSA', 'Huvos Auditorium', 'Service', 382, 268, 'F3');
insert into Location values ('F3SGIFTSH', 'Gift Shop', 'Service', 415, 343, 'F3');
insert into Location values ('F3SKIOSK0', 'Kiosk 3', 'Service', 411, 478, 'F3');
insert into Location values ('F3HHILLSI', 'Hillside Lobby', 'Hallway', 418, 489, 'F3');
insert into Location values ('F3SCHAPEL', 'Chapel', 'Service', 384, 486, 'F3');
insert into Location values ('F3SVOLUNT', 'Volunteer Services', 'Service', 456, 484, 'F3');
insert into Location values ('F3HHILELE', 'Hillside Elevators 3', 'Elevator', 400, 427, 'F3');
insert into Location values ('F3H000001', 'F3H1', 'Hallway', 420, 125, 'F3');
insert into Location values ('F3H000002', 'F3H2', 'Hallway', 418, 168, 'F3');
insert into Location values ('F3H000003', 'F3H3', 'Hallway', 403, 208, 'F3');
insert into Location values ('F3H000004', 'F3H4', 'Hallway', 403, 256, 'F3');
insert into Location values ('F3H000005', 'F3H5', 'Hallway', 418, 259, 'F3');
insert into Location values ('F3H000006', 'F3H6', 'Hallway', 418, 339, 'F3');
insert into Location values ('F3H000007', 'F3H7', 'Hallway', 418, 428, 'F3');
insert into Location values ('F3H000008', 'F3H8', 'Hallway', 418, 476, 'F3');
insert into Location values ('F5O5NORTH', '5 North', 'Office', 349, 565, 'F5');
insert into Location values ('F505SOUTH', '5 South', 'Office', 522, 565, 'F5');
insert into Location values ('F505A0000', '5A', 'Office', 444, 238, 'F5');
insert into Location values ('F505B0000', '5B', 'Office', 463, 180, 'F5');
insert into Location values ('F505C0000', '5C', 'Office', 491, 180, 'F5');
insert into Location values ('F505D0000', '5D', 'Office', 530, 180, 'F5');
insert into Location values ('F505E0000', '5E', 'Service', 530, 246, 'F5');
insert into Location values ('F505F0000', '5F', 'Office', 500, 272, 'F5');
insert into Location values ('F505G0000', '5G', 'Office', 490, 288, 'F5');
insert into Location values ('F505H0000', '5H', 'Office', 500, 317, 'F5');
insert into Location values ('F505I0000', '5I', 'Office', 490, 317, 'F5');
insert into Location values ('F505J0000', '5J', 'Office', 500, 346, 'F5');
insert into Location values ('F505K0000', '5K', 'Service', 490, 346, 'F5');
insert into Location values ('F505L0000', '5L', 'Service', 500, 500, 'F5');
insert into Location values ('F505M0000', '5M', 'Office', 500, 565, 'F5');
insert into Location values ('F505N0000', '5N', 'Service', 350, 565, 'F5');
insert into Location values ('F5H000001', 'F5H1', 'Hallway', 450, 190, 'F5');
insert into Location values ('F5H000002', 'F5H2', 'Hallway', 495, 230, 'F5');
insert into Location values ('F5H000003', 'F5H3', 'Hallway', 495, 282, 'F5');
insert into Location values ('F5H000004', 'F5H4', 'Hallway', 495, 317, 'F5');
insert into Location values ('F5H000005', 'F5H5', 'Hallway', 495, 347, 'F5');
insert into Location values ('F5H000006', 'F5H6', 'Hallway', 495, 515, 'F5');
insert into Location values ('F5H000007', 'F5H7', 'Hallway', 475, 515, 'F5');
insert into Location values ('F5H000008', 'F5H8', 'Hallway', 475, 540, 'F5');
insert into Location values ('F5H000009', 'F5H9', 'Hallway', 475, 560, 'F5');
insert into Location values ('F5HATRELE', 'Atrium Elevators 5', 'Elevator', 480, 230, 'F5');
insert into Location values ('F5HHILELE', 'Hillside Elevators 5', 'Elevator', 465, 540, 'F5');

insert into Neighbor values ('F1HMAINEN', 'F1HATRLOB');
insert into Neighbor values ('F1HMAINEN', 'F1VALETP');
insert into Neighbor values ('F1VALETP', 'F1HMAINEN');
insert into Neighbor values ('F1HATRLOB', 'F1HMAINEN');
insert into Neighbor values ('F1HATRLOB', 'F1SSTARBU');
insert into Neighbor values ('F1HATRLOB', 'F1H000001');
insert into Neighbor values ('F1SSTARBU', 'F1HATRLOB');
insert into Neighbor values ('F1H000001', 'F1HATRLOB');
insert into Neighbor values ('F1H000001', 'F1SKIOSK0');
insert into Neighbor values ('F1H000001', 'F1H000002');
insert into Neighbor values ('F1SKIOSK0', 'F1H000001');
insert into Neighbor values ('F1H000002', 'F1H000001');
insert into Neighbor values ('F1H000002', 'F1HATRELE');
insert into Neighbor values ('F1H000002', 'F1H000003');
insert into Neighbor values ('F1HATRELE', 'F1H000002');
insert into Neighbor values ('F1H000003', 'F1H000002');
insert into Neighbor values ('F1H000003', 'F1SBLOODD');
insert into Neighbor values ('F1H000003', 'F1SPREOPE');
insert into Neighbor values ('F1H000003', 'F1H000004');
insert into Neighbor values ('F1SBLOODD', 'F1H000003');
insert into Neighbor values ('F1SBLOODD', 'F1SPATIEN');
insert into Neighbor values ('F1SPATIEN', 'F1SBLOODD');
insert into Neighbor values ('F1SPATIEN', 'F1STAICLE');
insert into Neighbor values ('F1STAICLE', 'F1SPATIEN');
insert into Neighbor values ('F1STAICLE', 'F1SEMERGE');
insert into Neighbor values ('F1SEMERGE', 'F1STAICLE');
insert into Neighbor values ('F1SEMERGE', 'F1HEMERGE');
insert into Neighbor values ('F1HEMERGE', 'F1SEMERGE');
insert into Neighbor values ('F1H000004', 'F1H000003');
insert into Neighbor values ('F1H000004', 'F1SRADIOL');
insert into Neighbor values ('F1H000004', 'F1H000006');
insert into Neighbor values ('F1SRADIOL', 'F1H000004');
insert into Neighbor values ('F1SPREOPE', 'F1H000003');
insert into Neighbor values ('F1SPREOPE', 'F1H000005');
insert into Neighbor values ('F1H000005', 'F1SPREOPE');
insert into Neighbor values ('F1H000005', 'F1SGIENDO');
insert into Neighbor values ('F1H000005', 'F1H000006');
insert into Neighbor values ('F1H000005', 'F1H000007');
insert into Neighbor values ('F1H000006', 'F1H000004');
insert into Neighbor values ('F1H000006', 'F1H000005');
insert into Neighbor values ('F1H000006', 'F1SDAYSUR');
insert into Neighbor values ('F1SDAYSUR', 'F1H000006');
insert into Neighbor values ('F1H000007', 'F1H000005');
insert into Neighbor values ('F1H000007', 'F1HHILELE');
insert into Neighbor values ('F1HHILELE', 'F1H000007');
insert into Neighbor values ('F3O3A0000', 'F3H000001');
insert into Neighbor values ('F3H000001', 'F3O3A0000');
insert into Neighbor values ('F3H000001', 'F3O3B0000');
insert into Neighbor values ('F3H000001', 'F3H000002');
insert into Neighbor values ('F3O3B0000', 'F3H000001');
insert into Neighbor values ('F3O3B0000', 'F3O3C0000');
insert into Neighbor values ('F3O3C0000', 'F3O3B0000');
insert into Neighbor values ('F3H000002', 'F3H000001');
insert into Neighbor values ('F3H000002', 'F3HATRELE');
insert into Neighbor values ('F3H000002', 'F3H000003');
insert into Neighbor values ('F3HATRELE', 'F3H000002');
insert into Neighbor values ('F3H000003', 'F3H000002');
insert into Neighbor values ('F3H000003', 'F3H000004');
insert into Neighbor values ('F3H000004', 'F3H000003');
insert into Neighbor values ('F3H000004', 'F3SHUVOSA');
insert into Neighbor values ('F3H000004', 'F3SCAFETE');
insert into Neighbor values ('F3H000004', 'F3H000005');
insert into Neighbor values ('F3SHUVOSA', 'F3H000004');
insert into Neighbor values ('F3SCAFETE', 'F3H000004');
insert into Neighbor values ('F3H000005', 'F3H000004');
insert into Neighbor values ('F3H000005', 'F3H000006');
insert into Neighbor values ('F3H000006', 'F3H000005');
insert into Neighbor values ('F3H000006', 'F3SGIFTSH');
insert into Neighbor values ('F3H000006', 'F3H000007');
insert into Neighbor values ('F3SGIFTSH', 'F3H000006');
insert into Neighbor values ('F3H000007', 'F3H000006');
insert into Neighbor values ('F3H000007', 'F3HHILELE');
insert into Neighbor values ('F3H000007', 'F3H000008');
insert into Neighbor values ('F3HHILELE', 'F3H000007');
insert into Neighbor values ('F3H000008', 'F3H000007');
insert into Neighbor values ('F3H000008', 'F3SKIOSK0');
insert into Neighbor values ('F3H000008', 'F3HHILLSI');
insert into Neighbor values ('F3SKIOSK0', 'F3H000008');
insert into Neighbor values ('F3HHILLSI', 'F3H000008');
insert into Neighbor values ('F3HHILLSI', 'F3SCHAPEL');
insert into Neighbor values ('F3HHILLSI', 'F3SVOLUNT');
insert into Neighbor values ('F3SCHAPEL', 'F3HHILLSI');
insert into Neighbor values ('F3SVOLUNT', 'F3HHILLSI');
insert into Neighbor values ('F1HATRELE', 'F3HATRELE');
insert into Neighbor values ('F1HATRELE', 'F5HATRELE');
insert into Neighbor values ('F1HHILELE', 'F3HHILELE');
insert into Neighbor values ('F1HHILELE', 'F5HHILELE');
insert into Neighbor values ('F3HATRELE', 'F1HATRELE');
insert into Neighbor values ('F3HATRELE', 'F5HATRELE');
insert into Neighbor values ('F3HHILELE', 'F1HHILELE');
insert into Neighbor values ('F3HHILELE', 'F5HHILELE');
insert into Neighbor values ('F5HATRELE', 'F1HATRELE');
insert into Neighbor values ('F5HATRELE', 'F5HATRELE');
insert into Neighbor values ('F5HHILELE', 'F1HHILELE');
insert into Neighbor values ('F5HHILELE', 'F3HHILELE');
insert into Neighbor values ('F505A0000', 'F5H000001');
insert into Neighbor values ('F5H000001', 'F505A0000');
insert into Neighbor values ('F5H000001', 'F505B0000');
insert into Neighbor values ('F505B0000', 'F5H000001');
insert into Neighbor values ('F505B0000', 'F505C0000');
insert into Neighbor values ('F505C0000', 'F505B0000');
insert into Neighbor values ('F505C0000', 'F5H000002');
insert into Neighbor values ('F505C0000', 'F505D0000');
insert into Neighbor values ('F505D0000', 'F505C0000');
insert into Neighbor values ('F505D0000', 'F505E0000');
insert into Neighbor values ('F5H000002', 'F505C0000');
insert into Neighbor values ('F5H000002', 'F5HATRELE');
insert into Neighbor values ('F5H000002', 'F5H000003');
insert into Neighbor values ('F5HATRELE', 'F5H000002');
insert into Neighbor values ('F5H000003', 'F5H000002');
insert into Neighbor values ('F5H000003', 'F505G0000');
insert into Neighbor values ('F5H000003', 'F505F0000');
insert into Neighbor values ('F5H000003', 'F5H000004');
insert into Neighbor values ('F505F0000', 'F5H000003');
insert into Neighbor values ('F505G0000', 'F5H000003');
insert into Neighbor values ('F5H000004', 'F5H000003');
insert into Neighbor values ('F5H000004', 'F505I0000');
insert into Neighbor values ('F5H000004', 'F505H0000');
insert into Neighbor values ('F5H000004', 'F5H000005');
insert into Neighbor values ('F505H0000', 'F5H000004');
insert into Neighbor values ('F505I0000', 'F5H000004');
insert into Neighbor values ('F5H000005', 'F5H000004');
insert into Neighbor values ('F5H000005', 'F505J0000');
insert into Neighbor values ('F5H000005', 'F505K0000');
insert into Neighbor values ('F5H000005', 'F5H000006');
insert into Neighbor values ('F505J0000', 'F5H000005');
insert into Neighbor values ('F505K0000', 'F5H000005');
insert into Neighbor values ('F5H000006', 'F5H000005');
insert into Neighbor values ('F5H000006', 'F505L0000');
insert into Neighbor values ('F5H000006', 'F5H000007');
insert into Neighbor values ('F505L0000', 'F5H000006');
insert into Neighbor values ('F5H000007', 'F5H000006');
insert into Neighbor values ('F5H000007', 'F5H000008');
insert into Neighbor values ('F5H000008', 'F5H000007');
insert into Neighbor values ('F5H000008', 'F5HHILELE');
insert into Neighbor values ('F5H000008', 'F5H000009');
insert into Neighbor values ('F5HHILELE', 'F5H000008');
insert into Neighbor values ('F5H000009', 'F5H000008');
insert into Neighbor values ('F5H000009', 'F505M0000');
insert into Neighbor values ('F5H000009', 'F505N0000');
insert into Neighbor values ('F505M0000', 'F5H000009');
insert into Neighbor values ('F505M0000', 'F505SOUTH');
insert into Neighbor values ('F505SOUTH', 'F505M0000');
insert into Neighbor values ('F505N0000', 'F5H000009');
insert into Neighbor values ('F505N0000', 'F5O5NORTH');
insert into Neighbor values ('F5O5NORTH', 'F505N0000');

insert into Services values ('Information1', 'Service');
insert into Services values ('Information3', 'Service');
insert into Services values ('Admitting/Registration', 'Service');
insert into Services values ('Atrium Café', 'Service');
insert into Services values ('Audiology', 'Practice');
insert into Services values ('Cardiac Rehabilitation', 'Practice');
insert into Services values ('Center for Preoperative Evaluation', 'Practice');
insert into Services values ('Emergency Department', 'Practice');
insert into Services values ('GI Endoscopy', 'Practice');
insert into Services values ('Laboratory', 'Practice');
insert into Services values ('Patient Financial Services', 'Service');
insert into Services values ('Radiology', 'Practice');
insert into Services values ('Special Testing', 'Practice');
insert into Services values ('Taiclet Family Center', 'Service');
insert into Services values ('Valet Parking', 'Service');
insert into Services values ('Roslindale Pediatric Associates ', 'Practice');
insert into Services values ('Eye Care Specialists ', 'Practice');
insert into Services values ('Suburban Eye Specialists ', 'Practice');
insert into Services values ('Obstetrics and Gynecology Associates', 'Practice');
insert into Services values ('ATM', 'Service');
insert into Services values ('Cafeteria', 'Service');
insert into Services values ('Chapel and Chaplaincy Services', 'Service');
insert into Services values ('Gift Shop', 'Service');
insert into Services values ('Huvos Auditorium', 'Service');
insert into Services values ('Patient Relations', 'Service');
insert into Services values ('Volunteer Services', 'Service');
insert into Services values ('ICU', 'Practice');
insert into Services values ('Inpatient Hemodialysis', 'Practice');
insert into Services values ('Outpatient Infusion Center', 'Practice');
insert into Services values ('Foot and Ankle Center  ', 'Practice');
insert into Services values ('Hand and Upper Extremity Service', 'Practice');
insert into Services values ('Neurosurgery', 'Practice');
insert into Services values ('Orthopedics Center', 'Practice');
insert into Services values ('Spine Center', 'Practice');
insert into Services values ('Nutrition Clinic', 'Practice');
insert into Services values ('Boston ENT Associates', 'Practice');
insert into Services values ('Orthopaedics Associates', 'Practice');
insert into Services values ('Center for Metabolic Health and Bariatric Surgery', 'Practice');
insert into Services values ('Colorectal Surgery', 'Practice');
insert into Services values ('General Surgery  ', 'Practice');
insert into Services values ('Nutrition - Weight Loss Surgery', 'Practice');
insert into Services values ('Psychology - Weight Loss Surgery', 'Practice');
insert into Services values ('Surgical Specialties', 'Practice');
insert into Services values ('Vascular Surgery  ', 'Practice');
insert into Services values ('Brigham Dermatology Associates', 'Practice');
insert into Services values ('Family Care Associates', 'Practice');
insert into Services values ('Sleep Testing Center', 'Practice');
insert into Services values ('Brigham and Women''s Primary Physicians', 'Practice');

insert into ResidesIn values ('Information1', 'F1HATRLOB');
insert into ResidesIn values ('Information3', 'F3HHILLSI');
insert into ResidesIn values ('Admitting/Registration', 'F1SPATIEN');
insert into ResidesIn values ('Atrium Café', 'F1SSTARBU');
insert into ResidesIn values ('Audiology', 'F1HATRLOB');
insert into ResidesIn values ('Cardiac Rehabilitation', 'F1HATRLOB');
insert into ResidesIn values ('Center for Preoperative Evaluation', 'F1SPREOPE');
insert into ResidesIn values ('Emergency Department', 'F1SEMERGE');
insert into ResidesIn values ('GI Endoscopy', 'F1SGIENDO');
insert into ResidesIn values ('Laboratory', 'F1HATRLOB');
insert into ResidesIn values ('Patient Financial Services', 'F1SPATIEN');
insert into ResidesIn values ('Radiology', 'F1SRADIOL');
insert into ResidesIn values ('Special Testing', 'F1SBLOODD');
insert into ResidesIn values ('Taiclet Family Center', 'F1STAICLE');
insert into ResidesIn values ('Valet Parking', 'F1VALETP');
insert into ResidesIn values ('Roslindale Pediatric Associates ', 'F3O3A0000');
insert into ResidesIn values ('Eye Care Specialists ', 'F3O3B0000');
insert into ResidesIn values ('Suburban Eye Specialists ', 'F3O3B0000');
insert into ResidesIn values ('Obstetrics and Gynecology Associates', 'F3O3C0000');
insert into ResidesIn values ('ATM', 'F3HHILLSI');
insert into ResidesIn values ('Cafeteria', 'F3SCAFETE');
insert into ResidesIn values ('Chapel and Chaplaincy Services', 'F3SCHAPEL');
insert into ResidesIn values ('Gift Shop', 'F3SGIFTSH');
insert into ResidesIn values ('Huvos Auditorium', 'F3SHUVOSA');
insert into ResidesIn values ('Patient Relations', 'F3HHILLSI');
insert into ResidesIn values ('Volunteer Services', 'F3SVOLUNT');
insert into ResidesIn values ('ICU', 'F5O5NORTH');
insert into ResidesIn values ('Inpatient Hemodialysis', 'F5O5NORTH');
insert into ResidesIn values ('Outpatient Infusion Center', 'F5O5NORTH');
insert into ResidesIn values ('Foot and Ankle Center  ', 'F505SOUTH');
insert into ResidesIn values ('Hand and Upper Extremity Service', 'F505SOUTH');
insert into ResidesIn values ('Neurosurgery', 'F505SOUTH');
insert into ResidesIn values ('Orthopedics Center', 'F505SOUTH');
insert into ResidesIn values ('Spine Center', 'F505SOUTH');
insert into ResidesIn values ('Nutrition Clinic', 'F505A0000');
insert into ResidesIn values ('Boston ENT Associates', 'F505B0000');
insert into ResidesIn values ('Orthopaedics Associates', 'F505C0000');
insert into ResidesIn values ('Center for Metabolic Health and Bariatric Surgery', 'F505D0000');
insert into ResidesIn values ('Colorectal Surgery', 'F505D0000');
insert into ResidesIn values ('General Surgery  ', 'F505D0000');
insert into ResidesIn values ('Nutrition - Weight Loss Surgery', 'F505D0000');
insert into ResidesIn values ('Psychology - Weight Loss Surgery', 'F505D0000');
insert into ResidesIn values ('Surgical Specialties', 'F505D0000');
insert into ResidesIn values ('Vascular Surgery  ', 'F505D0000');
insert into ResidesIn values ('Brigham Dermatology Associates', 'F505G0000');
insert into ResidesIn values ('Family Care Associates', 'F505H0000');
insert into ResidesIn values ('Sleep Testing Center', 'F505M0000');
insert into ResidesIn values ('Brigham and Women''s Primary Physicians', 'F505J0000');

insert into Provider values (1, 'Jennifer', 'Byrne');
insert into Provider values (2, 'Harriet', 'Dann');
insert into Provider values (3, 'George', 'Frangieh');
insert into Provider values (4, 'James Adam', 'Greenberg');
insert into Provider values (5, 'Lisa', 'Grossi');
insert into Provider values (6, 'Elisabeth', 'Keller');
insert into Provider values (7, 'Linda', 'Malone');
insert into Provider values (8, 'Bruce', 'Micley');
insert into Provider values (9, 'Julie', 'Miner');
insert into Provider values (10, 'Beverly', 'Morrison');
insert into Provider values (11, 'Sarah', 'Nadarajah');
insert into Provider values (12, 'Elizabeth', 'O''Connor');
insert into Provider values (13, 'James', 'Patten');
insert into Provider values (14, 'Andrew', 'Saluti');
insert into Provider values (15, 'David', 'Scheff');
insert into Provider values (16, 'Leila', 'Schueler');
insert into Provider values (17, 'Shannon', 'Smith');
insert into Provider values (18, 'Robert', 'Stacks');
insert into Provider values (19, 'Mitchell', 'Tunick');
insert into Provider values (20, 'Julianne', 'Viola');
insert into Provider values (21, 'Arnold', 'Alqueza');
insert into Provider values (22, 'Nomee', 'Altschul');
insert into Provider values (23, 'Shamik', 'Bhattacharyya');
insert into Provider values (24, 'Phil', 'Blazar');
insert into Provider values (25, 'Eric', 'Bluman');
insert into Provider values (26, 'Christopher', 'Bono');
insert into Provider values (27, 'Gregory', 'Brick');
insert into Provider values (28, 'Mary Anne', 'Carleen');
insert into Provider values (29, 'Christopher', 'Chiodo');
insert into Provider values (30, 'Garth Rees', 'Cosgrove');
insert into Provider values (31, 'Courtney', 'Dawson');
insert into Provider values (32, 'Michael', 'Drew');
insert into Provider values (33, 'George', 'Dyer');
insert into Provider values (34, 'Brandon', 'Earp');
insert into Provider values (35, 'Joerg', 'Ermann');
insert into Provider values (36, 'Wolfgang', 'Fitz');
insert into Provider values (37, 'Michael', 'Groff');
insert into Provider values (38, 'Mitchel', 'Harris');
insert into Provider values (39, 'Joseph', 'Hartigan');
insert into Provider values (40, 'Laurence', 'Higgins');
insert into Provider values (41, 'Yi', 'Lu');
insert into Provider values (42, 'Elizabeth', 'Matzkin');
insert into Provider values (43, 'Mallory', 'Pingeton');
insert into Provider values (44, 'Andrew', 'Schoenfeld');
insert into Provider values (45, 'Jeremy', 'Smith');
insert into Provider values (46, 'Cristin', 'Taylor');
insert into Provider values (47, 'Adam', 'Tenforde');
insert into Provider values (48, 'Shari', 'Vigneau');
insert into Provider values (49, 'Kaitlyn', 'Whitlock');
insert into Provider values (50, 'Jay', 'Zampini');
insert into Provider values (51, 'Zacharia', 'Isaac');
insert into Provider values (52, 'Ehren', 'Nelson');
insert into Provider values (53, 'Jason', 'Yong');
insert into Provider values (54, 'Nancy', 'Oliveira');
insert into Provider values (55, 'Joseph', 'Groden');
insert into Provider values (56, 'William', 'Innis');
insert into Provider values (57, 'Joshua', 'Kessler');
insert into Provider values (58, 'William', 'Mason');
insert into Provider values (59, 'Halie', 'Paperno');
insert into Provider values (60, 'Mariah', 'Samara');
insert into Provider values (61, 'Rebecca', 'Stone');
insert into Provider values (62, 'Joseph Jr.', 'Barr');
insert into Provider values (63, 'Matthew', 'Butler');
insert into Provider values (64, 'Fulton', 'Kornack');
insert into Provider values (65, 'Robert', 'Savage');
insert into Provider values (66, 'Anthony', 'Webber');
insert into Provider values (67, 'Laura', 'Andromalos');
insert into Provider values (68, 'Meghan', 'Ariagno');
insert into Provider values (69, 'Michael', 'Belkin');
insert into Provider values (70, 'Paul', 'Davidson');
insert into Provider values (71, 'Katy', 'Hartman');
insert into Provider values (72, 'Jennifer', 'Irani');
insert into Provider values (73, 'Kellene', 'Isom');
insert into Provider values (74, 'Pardon', 'Kenney');
insert into Provider values (75, 'Allison', 'Kleifield');
insert into Provider values (76, 'Robert', 'Matthews');
insert into Provider values (77, 'Neyla', 'Melnitchouk');
insert into Provider values (78, 'Matthew', 'Nehs');
insert into Provider values (79, 'Erika', 'Rangel');
insert into Provider values (80, 'Erin', 'Reil');
insert into Provider values (81, 'Malcolm', 'Robinson');
insert into Provider values (82, 'Eric', 'Sheu');
insert into Provider values (83, 'Brent', 'Shoji');
insert into Provider values (84, 'David', 'Spector');
insert into Provider values (85, 'Ali', 'Tavakkoli');
insert into Provider values (86, 'Ashley', 'Vernon');
insert into Provider values (87, 'James', 'Warth');
insert into Provider values (88, 'Maria', 'Warth');
insert into Provider values (89, 'Eva', 'Balash');
insert into Provider values (90, 'Sherrie', 'Divito');
insert into Provider values (91, 'Jason', 'Frangos');
insert into Provider values (92, 'Colleen', 'Monaghan');
insert into Provider values (93, 'Kitty', 'O''Hare');
insert into Provider values (94, 'Niraj', 'Sharma');
insert into Provider values (95, 'Dhirendra', 'Bana');
insert into Provider values (96, 'David', 'Cahan');
insert into Provider values (97, 'Malavalli', 'Gopal');
insert into Provider values (98, 'Stephanie', 'Berman');
insert into Provider values (99, 'Michael', 'Healey');
insert into Provider values (100, 'Karl', 'Laskowski');
insert into Provider values (101, 'Katy', 'Litwak');
insert into Provider values (102, 'Orietta', 'Miatto');
insert into Provider values (103, 'Neil', 'Wagle');
insert into Provider values (104, 'Eileen', 'Joyce');
insert into Provider values (105, 'Mohammed', 'Issa');
insert into Provider values (106, 'Trevor', 'Angell');

insert into Title values ('CPNP', 'Certified Pediatric Nurse Practitioner');
insert into Title values ('DNP', 'Doctor of Nursing Practice');
insert into Title values ('DO', 'Doctor of Osteopathic Medicine');
insert into Title values ('MD', 'Doctor of Medicine');
insert into Title values ('MS', 'Master of Science');
insert into Title values ('RN', 'Registered Nurse');
insert into Title values ('WHNP', 'Women''s Health Nurse Practitioner');
insert into Title values ('Au.D', 'Doctor of Audiology');
insert into Title values ('DPM', 'Doctor of Podiatric Medicine');
insert into Title values ('LICSW', 'Licensed Independent Clinical Social Worker');
insert into Title values ('PhD', 'Doctor of Philosophy');
insert into Title values ('RD', 'Registered Dietitian');
insert into Title values ('LDN', 'Licensed Dietitian Nutritionist');
insert into Title values ('PA-C', 'Physician Assistant Certified');
insert into Title values ('CCC-A', 'Certificate of Clinical Competence in Audiology');
insert into Title values ('RDN', 'Registered Dietitian Nutritionist');

insert into ProviderTitle values (1, 'RN');
insert into ProviderTitle values (1, 'CPNP');
insert into ProviderTitle values (2, 'MD');
insert into ProviderTitle values (3, 'MD');
insert into ProviderTitle values (4, 'MD');
insert into ProviderTitle values (5, 'RN');
insert into ProviderTitle values (5, 'MS');
insert into ProviderTitle values (5, 'CPNP');
insert into ProviderTitle values (6, 'MD');
insert into ProviderTitle values (7, 'DNP');
insert into ProviderTitle values (7, 'RN');
insert into ProviderTitle values (7, 'CPNP');
insert into ProviderTitle values (8, 'MD');
insert into ProviderTitle values (9, 'MD');
insert into ProviderTitle values (10, 'MD');
insert into ProviderTitle values (11, 'WHNP');
insert into ProviderTitle values (12, 'MD');
insert into ProviderTitle values (13, 'MD');
insert into ProviderTitle values (14, 'DO');
insert into ProviderTitle values (15, 'MD');
insert into ProviderTitle values (16, 'MD');
insert into ProviderTitle values (17, 'MD');
insert into ProviderTitle values (18, 'MD');
insert into ProviderTitle values (19, 'MD');
insert into ProviderTitle values (20, 'MD');
insert into ProviderTitle values (21, 'MD');
insert into ProviderTitle values (22, 'PA-C');
insert into ProviderTitle values (23, 'MD');
insert into ProviderTitle values (24, 'MD');
insert into ProviderTitle values (25, 'MD');
insert into ProviderTitle values (26, 'MD');
insert into ProviderTitle values (27, 'MD');
insert into ProviderTitle values (28, 'PA-C');
insert into ProviderTitle values (29, 'MD');
insert into ProviderTitle values (30, 'MD');
insert into ProviderTitle values (31, 'MD');
insert into ProviderTitle values (32, 'MD');
insert into ProviderTitle values (33, 'MD');
insert into ProviderTitle values (34, 'MD');
insert into ProviderTitle values (35, 'MD');
insert into ProviderTitle values (36, 'MD');
insert into ProviderTitle values (37, 'MD');
insert into ProviderTitle values (38, 'MD');
insert into ProviderTitle values (39, 'DPM');
insert into ProviderTitle values (40, 'MD');
insert into ProviderTitle values (41, 'MD');
insert into ProviderTitle values (42, 'MD');
insert into ProviderTitle values (43, 'PA-C');
insert into ProviderTitle values (44, 'MD');
insert into ProviderTitle values (45, 'MD');
insert into ProviderTitle values (46, 'PA-C');
insert into ProviderTitle values (47, 'MD');
insert into ProviderTitle values (48, 'PA-C');
insert into ProviderTitle values (49, 'PA-C');
insert into ProviderTitle values (50, 'MD');
insert into ProviderTitle values (51, 'MD');
insert into ProviderTitle values (52, 'MD');
insert into ProviderTitle values (53, 'MD');
insert into ProviderTitle values (54, 'MS');
insert into ProviderTitle values (54, 'RDN');
insert into ProviderTitle values (54, 'LDN');
insert into ProviderTitle values (55, 'MD');
insert into ProviderTitle values (56, 'MD');
insert into ProviderTitle values (57, 'MD');
insert into ProviderTitle values (58, 'MD');
insert into ProviderTitle values (59, 'Au.D');
insert into ProviderTitle values (59, 'CCC-A');
insert into ProviderTitle values (60, 'MD');
insert into ProviderTitle values (61, 'MD');
insert into ProviderTitle values (62, 'MD');
insert into ProviderTitle values (63, 'DPM');
insert into ProviderTitle values (64, 'MD');
insert into ProviderTitle values (65, 'MD');
insert into ProviderTitle values (66, 'MD');
insert into ProviderTitle values (67, 'RD');
insert into ProviderTitle values (67, 'LDN');
insert into ProviderTitle values (68, 'RD');
insert into ProviderTitle values (68, 'LDN');
insert into ProviderTitle values (69, 'MD');
insert into ProviderTitle values (70, 'PhD');
insert into ProviderTitle values (71, 'MS');
insert into ProviderTitle values (71, 'RD');
insert into ProviderTitle values (71, 'LDN');
insert into ProviderTitle values (72, 'MD');
insert into ProviderTitle values (73, 'MS');
insert into ProviderTitle values (73, 'RN');
insert into ProviderTitle values (73, 'LDN');
insert into ProviderTitle values (74, 'MD');
insert into ProviderTitle values (75, 'PA-C');
insert into ProviderTitle values (76, 'PA-C');
insert into ProviderTitle values (77, 'MD');
insert into ProviderTitle values (78, 'MD');
insert into ProviderTitle values (79, 'MD');
insert into ProviderTitle values (80, 'RD');
insert into ProviderTitle values (80, 'LDN');
insert into ProviderTitle values (81, 'MD');
insert into ProviderTitle values (82, 'MD');
insert into ProviderTitle values (83, 'MD');
insert into ProviderTitle values (84, 'MD');
insert into ProviderTitle values (85, 'MD');
insert into ProviderTitle values (86, 'MD');
insert into ProviderTitle values (87, 'MD');
insert into ProviderTitle values (88, 'MD');
insert into ProviderTitle values (89, 'MD');
insert into ProviderTitle values (90, 'MD');
insert into ProviderTitle values (90, 'PhD');
insert into ProviderTitle values (91, 'MD');
insert into ProviderTitle values (92, 'MD');
insert into ProviderTitle values (93, 'MD');
insert into ProviderTitle values (94, 'MD');
insert into ProviderTitle values (95, 'MD');
insert into ProviderTitle values (96, 'MD');
insert into ProviderTitle values (97, 'MD');
insert into ProviderTitle values (98, 'MD');
insert into ProviderTitle values (99, 'MD');
insert into ProviderTitle values (100, 'MD');
insert into ProviderTitle values (101, 'LICSW');
insert into ProviderTitle values (102, 'MD');
insert into ProviderTitle values (103, 'MD');
insert into ProviderTitle values (104, 'LICSW');
insert into ProviderTitle values (105, 'MD');
insert into ProviderTitle values (106, 'MD');

insert into Office values (1, 'F3O3A0000');
insert into Office values (2, 'F3O3B0000');
insert into Office values (3, 'F3O3B0000');
insert into Office values (4, 'F3O3C0000');
insert into Office values (5, 'F3O3A0000');
insert into Office values (6, 'F3O3A0000');
insert into Office values (7, 'F3O3A0000');
insert into Office values (8, 'F3O3B0000');
insert into Office values (9, 'F3O3C0000');
insert into Office values (10, 'F3O3A0000');
insert into Office values (11, 'F3O3C0000');
insert into Office values (12, 'F3O3A0000');
insert into Office values (13, 'F3O3B0000');
insert into Office values (14, 'F3O3A0000');
insert into Office values (15, 'F3O3A0000');
insert into Office values (16, 'F3O3C0000');
insert into Office values (17, 'F3O3C0000');
insert into Office values (18, 'F3O3A0000');
insert into Office values (19, 'F3O3A0000');
insert into Office values (20, 'F3O3A0000');
insert into Office values (21, 'F505SOUTH');
insert into Office values (22, 'F505SOUTH');
insert into Office values (23, 'F505SOUTH');
insert into Office values (24, 'F505SOUTH');
insert into Office values (25, 'F505SOUTH');
insert into Office values (26, 'F505SOUTH');
insert into Office values (27, 'F505SOUTH');
insert into Office values (28, 'F505SOUTH');
insert into Office values (29, 'F505SOUTH');
insert into Office values (30, 'F505SOUTH');
insert into Office values (31, 'F505SOUTH');
insert into Office values (32, 'F505SOUTH');
insert into Office values (33, 'F505SOUTH');
insert into Office values (34, 'F505SOUTH');
insert into Office values (35, 'F505SOUTH');
insert into Office values (36, 'F505SOUTH');
insert into Office values (37, 'F505SOUTH');
insert into Office values (38, 'F505SOUTH');
insert into Office values (39, 'F505SOUTH');
insert into Office values (40, 'F505SOUTH');
insert into Office values (41, 'F505SOUTH');
insert into Office values (42, 'F505SOUTH');
insert into Office values (43, 'F505SOUTH');
insert into Office values (44, 'F505SOUTH');
insert into Office values (45, 'F505SOUTH');
insert into Office values (46, 'F505SOUTH');
insert into Office values (47, 'F505SOUTH');
insert into Office values (48, 'F505SOUTH');
insert into Office values (49, 'F505SOUTH');
insert into Office values (50, 'F505SOUTH');
insert into Office values (51, 'F505SOUTH');
insert into Office values (52, 'F505SOUTH');
insert into Office values (53, 'F505SOUTH');
insert into Office values (54, 'F505A0000');
insert into Office values (55, 'F505B0000');
insert into Office values (56, 'F505B0000');
insert into Office values (57, 'F505B0000');
insert into Office values (58, 'F505B0000');
insert into Office values (59, 'F505B0000');
insert into Office values (60, 'F505B0000');
insert into Office values (61, 'F505B0000');
insert into Office values (62, 'F505C0000');
insert into Office values (63, 'F505C0000');
insert into Office values (64, 'F505C0000');
insert into Office values (65, 'F505C0000');
insert into Office values (66, 'F505C0000');
insert into Office values (67, 'F505D0000');
insert into Office values (68, 'F505D0000');
insert into Office values (69, 'F505D0000');
insert into Office values (70, 'F505D0000');
insert into Office values (71, 'F505D0000');
insert into Office values (72, 'F505D0000');
insert into Office values (73, 'F505D0000');
insert into Office values (74, 'F505D0000');
insert into Office values (75, 'F505D0000');
insert into Office values (76, 'F505D0000');
insert into Office values (77, 'F505D0000');
insert into Office values (78, 'F505D0000');
insert into Office values (79, 'F505D0000');
insert into Office values (80, 'F505D0000');
insert into Office values (81, 'F505D0000');
insert into Office values (82, 'F505D0000');
insert into Office values (83, 'F505D0000');
insert into Office values (84, 'F505D0000');
insert into Office values (85, 'F505D0000');
insert into Office values (86, 'F505D0000');
insert into Office values (87, 'F505F0000');
insert into Office values (88, 'F505F0000');
insert into Office values (89, 'F505G0000');
insert into Office values (90, 'F505G0000');
insert into Office values (91, 'F505G0000');
insert into Office values (92, 'F505H0000');
insert into Office values (93, 'F505H0000');
insert into Office values (94, 'F505H0000');
insert into Office values (95, 'F505I0000');
insert into Office values (96, 'F505I0000');
insert into Office values (97, 'F505I0000');
insert into Office values (98, 'F505J0000');
insert into Office values (99, 'F505J0000');
insert into Office values (100, 'F505J0000');
insert into Office values (101, 'F505J0000');
insert into Office values (102, 'F505J0000');
insert into Office values (103, 'F505J0000');
insert into Office values (104, 'F505H0000');
insert into Office values (105, 'F505SOUTH');
insert into Office values (106, 'F505D0000');

insert into Path values (1, 'Atrium Lobby', 'Day Surgery');
insert into Path values (2, 'Emergency', 'GI/Endoscopy');
insert into Path values (3, 'Cafeteria', 'Volunteer Services');
insert into Path values (4, '5A', '5 South');
insert into Path values (5, 'Radiology', '5J');
insert into Path values (6, '3C', 'Hillside Elevators 3');
insert into Path values (7, 'Radiology', '5J');
insert into Path values (8, 'Radiology', '5J');
insert into Path values (9, 'Starbucks', '5 North');
insert into Path values (10, 'Hillside Elevators 3', 'Atrium Elevators 3');

insert into PathContains values (1, 'F1HATRLOB', 1, 'Start');
insert into PathContains values (1, 'F1H000001', 2, 'Midpoint');
insert into PathContains values (1, 'F1H000002', 3, 'Midpoint');
insert into PathContains values (1, 'F1H000003', 4, 'Midpoint');
insert into PathContains values (1, 'F1H000004', 5, 'Midpoint');
insert into PathContains values (1, 'F1H000006', 6, 'Midpoint');
insert into PathContains values (1, 'F1SDAYSUR', 7, 'End');
insert into PathContains values (2, 'F1SEMERGE', 1, 'Start');
insert into PathContains values (2, 'F1STAICLE', 2, 'Midpoint');
insert into PathContains values (2, 'F1SPATIEN', 3, 'Midpoint');
insert into PathContains values (2, 'F1SBLOODD', 4, 'Midpoint');
insert into PathContains values (2, 'F1H000003', 5, 'Midpoint');
insert into PathContains values (2, 'F1SPREOPE', 6, 'Midpoint');
insert into PathContains values (2, 'F1H000005', 7, 'Midpoint');
insert into PathContains values (2, 'F1SGIENDO', 8, 'End');
insert into PathContains values (3, 'F3SCAFETE', 1, 'Start');
insert into PathContains values (3, 'F3H000004', 2, 'Midpoint');
insert into PathContains values (3, 'F3H000005', 3, 'Midpoint');
insert into PathContains values (3, 'F3H000006', 4, 'Midpoint');
insert into PathContains values (3, 'F3H000007', 5, 'Midpoint');
insert into PathContains values (3, 'F3H000008', 6, 'Midpoint');
insert into PathContains values (3, 'F3HHILLSI', 7, 'Midpoint');
insert into PathContains values (3, 'F3SVOLUNT', 8, 'End');
insert into PathContains values (4, 'F505A0000', 1, 'Start');
insert into PathContains values (4, 'F5H000001', 2, 'Midpoint');
insert into PathContains values (4, 'F505B0000', 3, 'Midpoint');
insert into PathContains values (4, 'F505C0000', 4, 'Midpoint');
insert into PathContains values (4, 'F5H000002', 5, 'Midpoint');
insert into PathContains values (4, 'F5H000003', 6, 'Midpoint');
insert into PathContains values (4, 'F5H000004', 7, 'Midpoint');
insert into PathContains values (4, 'F5H000005', 8, 'Midpoint');
insert into PathContains values (4, 'F5H000006', 9, 'Midpoint');
insert into PathContains values (4, 'F5H000007', 10, 'Midpoint');
insert into PathContains values (4, 'F5H000008', 11, 'Midpoint');
insert into PathContains values (4, 'F5H000009', 12, 'Midpoint');
insert into PathContains values (4, 'F505M0000', 13, 'Midpoint');
insert into PathContains values (4, 'F505SOUTH', 14, 'End');
insert into PathContains values (5, 'F1SRADIOL', 1, 'Start');
insert into PathContains values (5, 'F1H000004', 2, 'Midpoint');
insert into PathContains values (5, 'F1H000003', 3, 'Midpoint');
insert into PathContains values (5, 'F1H000002', 4, 'Midpoint');
insert into PathContains values (5, 'F1HATRELE', 5, 'Midpoint');
insert into PathContains values (5, 'F5HATRELE', 6, 'Midpoint');
insert into PathContains values (5, 'F5H000002', 7, 'Midpoint');
insert into PathContains values (5, 'F5H000003', 8, 'Midpoint');
insert into PathContains values (5, 'F5H000004', 9, 'Midpoint');
insert into PathContains values (5, 'F5H000005', 10, 'Midpoint');
insert into PathContains values (5, 'F505J0000', 11, 'End');
insert into PathContains values (6, 'F3O3C0000', 1, 'Start');
insert into PathContains values (6, 'F3O3B0000', 2, 'Midpoint');
insert into PathContains values (6, 'F3H000001', 3, 'Midpoint');
insert into PathContains values (6, 'F3H000002', 4, 'Midpoint');
insert into PathContains values (6, 'F3H000003', 5, 'Midpoint');
insert into PathContains values (6, 'F3H000004', 6, 'Midpoint');
insert into PathContains values (6, 'F3H000005', 7, 'Midpoint');
insert into PathContains values (6, 'F3H000006', 8, 'Midpoint');
insert into PathContains values (6, 'F3H000007', 9, 'Midpoint');
insert into PathContains values (6, 'F3HHILELE', 10, 'End');
insert into PathContains values (7, 'F1SRADIOL', 1, 'Start');
insert into PathContains values (7, 'F1H000004', 2, 'Midpoint');
insert into PathContains values (7, 'F1H000006', 3, 'Midpoint');
insert into PathContains values (7, 'F1H000005', 4, 'Midpoint');
insert into PathContains values (7, 'F1H000007', 5, 'Midpoint');
insert into PathContains values (7, 'F1HHILELE', 6, 'Midpoint');
insert into PathContains values (7, 'F5HHILELE', 7, 'Midpoint');
insert into PathContains values (7, 'F5H000008', 8, 'Midpoint');
insert into PathContains values (7, 'F5H000007', 9, 'Midpoint');
insert into PathContains values (7, 'F5H000006', 10, 'Midpoint');
insert into PathContains values (7, 'F5H000005', 11, 'Midpoint');
insert into PathContains values (7, 'F505J0000', 12, 'End');
insert into PathContains values (8, 'F1SRADIOL', 1, 'Start');
insert into PathContains values (8, 'F1H000004', 2, 'Midpoint');
insert into PathContains values (8, 'F1H000003', 3, 'Midpoint');
insert into PathContains values (8, 'F1H000002', 4, 'Midpoint');
insert into PathContains values (8, 'F1HATRELE', 5, 'Midpoint');
insert into PathContains values (8, 'F3HATRELE', 6, 'Midpoint');
insert into PathContains values (8, 'F3H000002', 7, 'Midpoint');
insert into PathContains values (8, 'F3H000003', 8, 'Midpoint');
insert into PathContains values (8, 'F3H000004', 9, 'Midpoint');
insert into PathContains values (8, 'F3H000005', 10, 'Midpoint');
insert into PathContains values (8, 'F3H000006', 11, 'Midpoint');
insert into PathContains values (8, 'F3H000007', 12, 'Midpoint');
insert into PathContains values (8, 'F3HHILELE', 13, 'Midpoint');
insert into PathContains values (8, 'F5HHILELE', 14, 'Midpoint');
insert into PathContains values (8, 'F5H000008', 15, 'Midpoint');
insert into PathContains values (8, 'F5H000007', 16, 'Midpoint');
insert into PathContains values (8, 'F5H000006', 17, 'Midpoint');
insert into PathContains values (8, 'F5H000005', 18, 'Midpoint');
insert into PathContains values (8, 'F505J0000', 19, 'End');
insert into PathContains values (9, 'F1SSTARBU', 1, 'Start');
insert into PathContains values (9, 'F1HATRLOB', 2, 'Midpoint');
insert into PathContains values (9, 'F1H000001', 3, 'Midpoint');
insert into PathContains values (9, 'F1H000002', 4, 'Midpoint');
insert into PathContains values (9, 'F1H000003', 5, 'Midpoint');
insert into PathContains values (9, 'F1H000004', 6, 'Midpoint');
insert into PathContains values (9, 'F1H000005', 7, 'Midpoint');
insert into PathContains values (9, 'F1H000006', 8, 'Midpoint');
insert into PathContains values (9, 'F1H000007', 9, 'Midpoint');
insert into PathContains values (9, 'F1HHILELE', 10, 'Midpoint');
insert into PathContains values (9, 'F5HHILELE', 11, 'Midpoint');
insert into PathContains values (9, 'F5H000008', 12, 'Midpoint');
insert into PathContains values (9, 'F5H000009', 13, 'Midpoint');
insert into PathContains values (9, 'F505N0000', 14, 'Midpoint');
insert into PathContains values (9, 'F5O5NORTH', 15, 'End');
insert into PathContains values (10, 'F3HHILELE', 1, 'Start');
insert into PathContains values (10, 'F3H000007', 2, 'Midpoint');
insert into PathContains values (10, 'F3H000006', 3, 'Midpoint');
insert into PathContains values (10, 'F3H000005', 4, 'Midpoint');
insert into PathContains values (10, 'F3H000004', 5, 'Midpoint');
insert into PathContains values (10, 'F3H000003', 6, 'Midpoint');
insert into PathContains values (10, 'F3H000002', 7, 'Midpoint');
insert into PathContains values (10, 'F3HATRELE', 8, 'End');






