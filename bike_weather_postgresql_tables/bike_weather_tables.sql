CREATE TABLE IF NOT EXISTS citi_bike_weather.date_info
(
    datekey text COLLATE pg_catalog."default" NOT NULL,
    date timestamp without time zone,
    month bigint,
    day bigint,
    month_name text COLLATE pg_catalog."default",
    day_name text COLLATE pg_catalog."default",
    weekend boolean,
    financial_qtr bigint,
    CONSTRAINT date_info_pkey PRIMARY KEY (datekey)
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.date_info
(
    datekey text COLLATE pg_catalog."default" NOT NULL,
    date timestamp without time zone,
    month bigint,
    day bigint,
    month_name text COLLATE pg_catalog."default",
    day_name text COLLATE pg_catalog."default",
    weekend boolean,
    financial_qtr bigint,
    CONSTRAINT date_info_pkey PRIMARY KEY (datekey)
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.gender
(
    id bigint NOT NULL,
    gender text COLLATE pg_catalog."default",
    CONSTRAINT gender_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.trip_info
(
    trip_id text COLLATE pg_catalog."default" NOT NULL,
    duration_seconds bigint,
    duration_minutes double precision,
    duration_hours double precision,
    datekey text COLLATE pg_catalog."default",
    start_time timestamp without time zone,
    stop_time timestamp without time zone,
    start_station_id bigint,
    end_station_id bigint,
    bike_id bigint,
    CONSTRAINT trip_info_pkey PRIMARY KEY (trip_id),
    CONSTRAINT datekey_trip FOREIGN KEY (datekey)
        REFERENCES citi_bike_weather.date_info (datekey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT end_station_id FOREIGN KEY (end_station_id)
        REFERENCES citi_bike_weather.bike_station (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT start_station_id FOREIGN KEY (start_station_id)
        REFERENCES citi_bike_weather.bike_station (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.trip_user_info
(
    trip_id text COLLATE pg_catalog."default" NOT NULL,
    birth_year double precision,
    gender_id bigint,
    user_type_id bigint,
    age integer GENERATED ALWAYS AS (((2016)::double precision - birth_year)) STORED,
    CONSTRAINT trip_user_info_pkey PRIMARY KEY (trip_id),
    CONSTRAINT gender_id_user FOREIGN KEY (gender_id)
        REFERENCES citi_bike_weather.gender (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT trip_info_user FOREIGN KEY (trip_id)
        REFERENCES citi_bike_weather.trip_info (trip_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT user_type_id FOREIGN KEY (user_type_id)
        REFERENCES citi_bike_weather.user_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.user_type
(
    id bigint NOT NULL,
    user_type text COLLATE pg_catalog."default",
    CONSTRAINT user_type_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.weather_info
(
    station_id text COLLATE pg_catalog."default" NOT NULL,
    datekey text COLLATE pg_catalog."default" NOT NULL,
    awnd double precision,
    prcp double precision,
    snow double precision,
    rain_fall boolean,
    snow_fall boolean,
    snwd double precision,
    tavg bigint,
    tmax bigint,
    tmin bigint,
    wdf2 bigint,
    wdf5 double precision,
    wsf2 double precision,
    wsf5 double precision,
    CONSTRAINT weather_info_pkey PRIMARY KEY (station_id, datekey),
    CONSTRAINT datekey_id FOREIGN KEY (datekey)
        REFERENCES citi_bike_weather.date_info (datekey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT weather_station_id FOREIGN KEY (station_id)
        REFERENCES citi_bike_weather.weather_station (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS citi_bike_weather.weather_station
(
    id text COLLATE pg_catalog."default" NOT NULL,
    airport text COLLATE pg_catalog."default",
    state text COLLATE pg_catalog."default",
    country text COLLATE pg_catalog."default",
    CONSTRAINT weather_station_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;