#!/bin/bash

rm /paringud/memoriaal_ee.csv

mysql -umichelek -p${MYSQL_PASS} repis<<EOFMYSQL

SELECT * FROM repis.allikad
 INTO OUTFILE '/paringud/memoriaal_ee.csv'
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n';

 EOFMYSQL
