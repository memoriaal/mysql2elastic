// var raven = require('raven')

if (!process.env.MYSQL_PASS) {
  throw new Error('"MYSQL_PASS" missing in environment')
}
if (!process.env.ELASTIC_PASS) {
  throw new Error('"ELASTIC_PASS" missing in environment')
}

console.log('Mastered');
