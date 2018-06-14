#!/bin/bash

rm /paringud/memoriaal_ee.csv

mysql -umichelek -p${MYSQL_PASS} repis<<EOFMYSQL

SELECT   nk.kirjekood AS id,
         nk.perenimi,
         nk.eesnimi,
         nk.isanimi,
         nk.emanimi,
         LEFT(nk.sünd,4) AS sünd,
         LEFT(nk.surm,4) AS surm,
         IF(ks.silt IS NULL, '', '!') AS kivi,
         IFNULL(REPLACE (
           group_concat(DISTINCT
             IF(
               a.prioriteetkirje = 0, NULL, concat_ws('#|',
                 k.persoon,
                 k.kirjekood,
                 k.kirje,
                 a.allikas,
                 a.nimetus,
                 concat('{ "labels": ["',concat_ws('", "',
                   IF(k.EiArvesta = '!', 'skip', NULL),
                   IF(k.EkslikKanne = '!', 'wrong', NULL)
                 ) , '"] }')
               )
             )
             ORDER BY a.prioriteetkirje DESC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS kirjed,
         IFNULL(REPLACE(
           group_concat( DISTINCT
             IF(
               kp.kirjekood IS NULL, NULL, concat_ws('#|',
                 kp.persoon,
                 kp.kirjekood,
                 kp.kirje,
                 a.allikas,
                 a.nimetus,
                 concat('{ "labels": ["',concat_ws('", "',
                   IF(kp.EiArvesta = '!', 'skip', NULL),
                   IF(kp.EkslikKanne = '!', 'wrong', NULL)
                 ) , '"] }')
               )
             )
             ORDER BY kp.kirjekood ASC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS pereseos
 FROM repis.kirjed AS k
 LEFT JOIN repis.allikad AS a ON a.kood = k.allikas
 LEFT JOIN repis.kirjed AS kp ON kp.RaamatuPere <> '' AND kp.RaamatuPere = k.RaamatuPere AND kp.allikas != 'Persoon'
 LEFT JOIN repis.kirjed AS nk ON nk.persoon = k.persoon AND nk.allikas = 'Persoon'
 LEFT JOIN repis.v_kirjesildid AS ks ON ks.kirjekood = nk.persoon AND ks.silt = 'x - kivi' AND ks.deleted_at = '0000-00-00 00:00:00'
 WHERE k.ekslikkanne = ''
 AND k.puudulik = ''
 AND k.peatatud = ''
 AND nk.persoon IS NOT NULL
 AND a.kood != 'Persoon'
 GROUP BY k.persoon
 HAVING perenimi != ''
 INTO OUTFILE '/paringud/memoriaal_ee.csv'
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n';

 EOFMYSQL
