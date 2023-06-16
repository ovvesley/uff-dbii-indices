use polroute_without_index;

#1. Qual o total de crimes por tipo e por segmento das ruas do distrito de IGUATEMI durante o ano de 2016?
SELECT
       SUM(crime.total_feminicide) as soma_total_feminicide,
       SUM(crime.total_homicide) as soma_total_homicide,
       SUM(crime.total_felony_murder) as soma_total_felony_murder,
       SUM(crime.total_bodily_harm) as soma_total_bodily_harm,
       SUM(crime.total_theft_cellphone) as soma_total_theft_cellphone,
       SUM(crime.total_armed_robbery_cellphone ) as soma_total_armed_robbery_cellphone,
       SUM(crime.total_theft_auto) as soma_total_theft_auto,
       SUM(crime.total_armed_robbery_auto) as soma_total_armed_robbery_auto,
       segment.id as 'segment_id'
FROM crime
JOIN segment ON segment.id = crime.segment_id
WHERE
    crime.time_id IN (SELECT id from time where year = 2016)
    AND
        (
                segment.start_vertice_id IN ( SELECT id FROM vertice where district_id = (SELECT id from district where district.name = 'IGUATEMI') )
            OR
                segment.final_vertice_id IN ( SELECT id FROM vertice where district_id = (SELECT id from district where district.name = 'IGUATEMI') )
        )
GROUP BY segment.id;


# 2. Qual o total de crimes por tipo e por segmento das ruas do distrito de IGUATEMI entre 2006 e 2016?
SELECT
       SUM(crime.total_feminicide) as soma_total_feminicide,
       SUM(crime.total_homicide) as soma_total_homicide,
       SUM(crime.total_felony_murder) as soma_total_felony_murder,
       SUM(crime.total_bodily_harm) as soma_total_bodily_harm,
       SUM(crime.total_theft_cellphone) as soma_total_theft_cellphone,
       SUM(crime.total_armed_robbery_cellphone ) as soma_total_armed_robbery_cellphone,
       SUM(crime.total_theft_auto) as soma_total_theft_auto,
       SUM(crime.total_armed_robbery_auto) as soma_total_armed_robbery_auto,
       segment.id as 'segment_id'
FROM crime
JOIN segment ON segment.id = crime.segment_id
WHERE
    crime.time_id IN (SELECT id from time where year > 2006 and year < 2016)
    AND
        (
                segment.start_vertice_id IN ( SELECT id FROM vertice where district_id = (SELECT id from district where district.name = 'IGUATEMI') )
            OR
                segment.final_vertice_id IN ( SELECT id FROM vertice where district_id = (SELECT id from district where district.name = 'IGUATEMI') )
        )
GROUP BY segment.id;

#3. Qual o total de ocorrências de Roubo de Celular e roubo de carro no bairro de SANTA EFIGÊNIA em 2015?

SELECT SUM(soma_total_theft_cellphone), SUM(soma_total_theft_auto), name
FROM (SELECT SUM(crime.total_theft_cellphone) AS soma_total_theft_cellphone,
             SUM(crime.total_theft_auto)      AS soma_total_theft_auto,
             n_final.name                       AS name
      FROM crime
               JOIN segment ON segment.id = crime.segment_id
               JOIN vertice AS vertice_final ON vertice_final.id = segment.final_vertice_id
               JOIN neighborhood n_final ON vertice_final.neighborhood_id = n_final.id
      WHERE n_final.name = 'Santa Efigenia'
      GROUP BY n_final.name
      UNION
      SELECT SUM(crime.total_theft_cellphone) AS soma_total_theft_cellphone,
             SUM(crime.total_theft_auto)      AS soma_total_theft_auto,
             n_start.name                       AS name
      FROM crime
               JOIN segment ON segment.id = crime.segment_id
               JOIN vertice as vertice_inicial ON vertice_inicial.id = segment.start_vertice_id
               JOIN neighborhood n_start on vertice_inicial.neighborhood_id = n_start.id
      WHERE n_start.name = 'Santa Efigenia'
      GROUP BY n_start.name) AS union_tables
GROUP BY name;

#4. Qual o total de crimes por tipo em vias de mão única da cidade durante o ano de 2012?

SELECT SUM(soma_total_feminicide),
       SUM(soma_total_homicide),
       SUM(soma_total_felony_murder),
       SUM(soma_total_bodily_harm),
       SUM(soma_total_theft_cellphone),
       SUM(soma_total_armed_robbery_cellphone),
       SUM(soma_total_theft_auto),
       SUM(soma_total_armed_robbery_auto)
from (SELECT SUM(crime.total_feminicide)              as soma_total_feminicide,
             SUM(crime.total_homicide)                as soma_total_homicide,
             SUM(crime.total_felony_murder)           as soma_total_felony_murder,
             SUM(crime.total_bodily_harm)             as soma_total_bodily_harm,
             SUM(crime.total_theft_cellphone)         as soma_total_theft_cellphone,
             SUM(crime.total_armed_robbery_cellphone) as soma_total_armed_robbery_cellphone,
             SUM(crime.total_theft_auto)              as soma_total_theft_auto,
             SUM(crime.total_armed_robbery_auto)      as soma_total_armed_robbery_auto
      FROM crime
               JOIN segment ON segment.id = crime.segment_id
      WHERE segment.oneway = 'yes'
        and crime.time_id IN (SELECT id from time where year = 2012)
      GROUP BY segment.id) as total_crime_per_segment;


#5. Qual o total de roubos de carro e celular em todos os segmentos durante o ano de 2017?

SELECT
       (SUM(soma_total_theft_cellphone)+SUM(soma_total_armed_robbery_cellphone)) as total_roubos_celular,
       (SUM(soma_total_theft_auto)+ SUM(soma_total_armed_robbery_auto)) as total_roubos_carros
FROM (SELECT
             SUM(crime.total_theft_cellphone)         as soma_total_theft_cellphone,
             SUM(crime.total_armed_robbery_cellphone) as soma_total_armed_robbery_cellphone,
             SUM(crime.total_theft_auto)              as soma_total_theft_auto,
             SUM(crime.total_armed_robbery_auto)      as soma_total_armed_robbery_auto
      FROM crime
               JOIN segment ON segment.id = crime.segment_id
      WHERE segment.oneway = 'yes'
        and crime.time_id IN (SELECT id from time where year = 2017)
      GROUP BY segment.id) as total_crime_per_segment;

# 6. Quais os IDs de segmentos que possuíam o maior índice criminal (soma de ocorrências de todos os tipos de crimes), durante o mês de Novembro de 2010?
SELECT (SUM(crime.total_feminicide) + SUM(crime.total_homicide) + SUM(crime.total_felony_murder) +
        SUM(crime.total_bodily_harm) + SUM(crime.total_theft_cellphone) + SUM(crime.total_armed_robbery_cellphone) +
        SUM(crime.total_theft_auto) + SUM(crime.total_armed_robbery_auto)) as total_crimes,
        segment.id
FROM crime
         JOIN segment ON segment.id = crime.segment_id
WHERE crime.time_id IN (SELECT id from time where year = 2010 and month = 11)
GROUP BY segment.id
ORDER BY total_crimes DESC
LIMIT 10;

# 7. Quais os IDs dos segmentos que possuíam o maior índice criminal (soma de ocorrências de todos os tipos de crimes) durante os finais de semana do ano de 2018?

SELECT (SUM(crime.total_feminicide) + SUM(crime.total_homicide) + SUM(crime.total_felony_murder) +
        SUM(crime.total_bodily_harm) + SUM(crime.total_theft_cellphone) + SUM(crime.total_armed_robbery_cellphone) +
        SUM(crime.total_theft_auto) + SUM(crime.total_armed_robbery_auto)) as total_crimes,
        segment.id
FROM crime
         JOIN segment ON segment.id = crime.segment_id
WHERE crime.time_id IN (SELECT id from time where year = 2018 and (weekday = 'saturday' or weekday = 'sunday'))
GROUP BY segment.id
ORDER BY total_crimes DESC
LIMIT 10
