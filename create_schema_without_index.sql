create database polroute_without_index;

create table crime
(
    id                            int not null,
    total_feminicide              int null,
    total_homicide                int null,
    total_felony_murder           int null,
    total_bodily_harm             int null,
    total_theft_cellphone         int null,
    total_armed_robbery_cellphone int null,
    total_theft_auto              int null,
    total_armed_robbery_auto      int null,
    segment_id                    int null,
    time_id                       int null
);


create table district
(
    id       int      not null,
    name     text     null,
    geometry longtext null
);


create table neighborhood
(
    id       int      not null,
    name     text     null,
    geometry longtext null
);

create table segment
(
    id               int           not null,
    geometry         longtext      null,
    oneway           varchar(30)   null,
    length           varchar(10)   null,
    final_vertice_id int    null,
    start_vertice_id int    null
);


create table time
(
    id      int not  null,
    period  varchar(50) null,
    day     int  null,
    month   int  null,
    year    int  null,
    weekday varchar(50) null
);


create table vertice
(
    id              int not null,
    label           int null,
    district_id     int null,
    neighborhood_id int null,
    zone_id         int null
);
