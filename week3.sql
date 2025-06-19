-- q13
create table Supplier (
    supplierName varchar(30) primary key,
    city varchar(30)
)

create table Part (
    num integer primary key,
    colour varchar(30)
)

create table Supplies (
    quantity integer,
    supplier varchar(30) references Supplier(name),
    part integer references Part(number),
    primary key(supplier, part)
)

-- q15
create table Player (
    name varchar(30) primary key,
)
create table Team (
    name varchar(30) primary key,
    captain varchar(30) references Player(name)
)

Alter table Player add foreign key playsFor references Team(name)

create table Fan (
    name varchar(30) primary key
)

create table favPlayer(
    fan varchar(30) references Fan(name),
    player varchar(30) references Player(name),
    primary key(fan, player)
)

create table favTeam(
    fan varchar(30) references Fan(name),
    team varchar(30) references Team(name),
    primary key(fan, team)
)

create table TeamColours(
    team varchar(30) references Team(name),
    colour varchar(30),
    primary key(team, colour)
)

-- q16

create table Truck (
    truckNo integer primary key,
    maxVol float,
    maxWt float,
)

create table Warehouse (
    loc varchar(100) primary key,
)

create table Store (
    addr varchar(100) primary key,
    storeName varchar(30),
)

create table Trip (
    tripNo integer primary key,
    date date,
    truck integer references Truck(truckNo)
)

create table Source (
    warehouse varchar(100) references Warehouse(location),
    trip integer references Trip(tripNo),
    primary key (warehouse,trip)
)

create table Shipment (
    shipNo integer primary key,
    vol float,
    weight float,
    trip integer references Trip(tripNo),
    store varchar(100) references Store(addr)
)

-- q18 - Using ER-style mapping for subclasses of Person

create table Person (
	ssn         integer,
	name        varchar(50) not null,
	address     varchar(100),
	primary key (ssn)
);

-- subclasses are overlapping; a Person could thus be
-- in any combination of the Doctor, Patient or Pharmacist tables

create table Doctor (
	ssn         integer,
	yearsExp    integer,
	primary key (ssn),
	foreign key (ssn) references Person(ssn)
);

create table Specialties (
	doctor      integer,
	specialty   varchar(20) check
	              (specialty in ('Feet','Ears','Throat')),
	primary key (doctor,specialty),
	foreign key (doctor) references Doctor(ssn)
);

create table Patient (
	ssn         integer,
	birthdate   date,

	primary key (ssn),
	foreign key (ssn) references Person(ssn),
	foreign key (primaryPhys) references Doctor(ssn)
);

create table Pharmacist (
	ssn         integer,
	phName      varchar(30),
	phAddress   varchar(100),
	qual        varchar(30),
	primary key (ssn),
	foreign key (ssn) references Person(ssn)
);
-- Using single table with nulls 
create table Person (
	ssn         integer,
	name        varchar(50) not null,
	address     varchar(100),
    -- what they are
    isPatient boolean,
    isDoctor boolean,
    isPharmacist boolean,
    -- stuff for patient
	birthdate   date,
    primaryPhys integer,
    -- stuff for doctor
	yearsExp    integer,
    -- stuff for pharmacist
	qual        varchar(30),
	primary key (ssn)
    foreign key (primaryPhys) references Person(ssn)
    constraint checkOneofThings 
    (check (isPatient = true) or (isDoctor = true) or (isPharmacist = true))
);

create table Specialties (
	doctor      integer,
	specialty   varchar(20) check
	              (specialty in ('Feet','Ears','Throat')),
	primary key (doctor,specialty),
	foreign key (doctor) references Person(ssn)
);

create table Pharmacy (
    name 
    address
    phone
    manager references Person(ssn)
)

create table Drug (
    tradeName varchar(30) primary key,
    formula text
)

create table Prescribes (
    doctor
    patient
    drug
    primary key (doctor, patient, drug)
)

create table Treats (
    doctor
    patient
    treatmentDate
)



create table SoldIn (
    drug
    Pharmacy
    price
)

-- prac exam q
create table User (
    id serial primary key,
    name text not null,
    email text not null,
)

create table Recipe (
    id serial primary key,
    title text not null,
    ownedBy integer references User(id) not null
)

create table Ingredient (
    id serial primary key,
    name text not null
)

create table Uses (
    recipe integer references Recipe(id),
    ingredient integer references Ingredient(id),
    amount integer (check amount > 0),
    unit text not null,
    primary key (recipe, ingredient)
)

create table Tags (
    recipe integer references Recipe(id),
    tag text,
    primary key (recipe,tag)
)
