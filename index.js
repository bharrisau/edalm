module.exports = process.env.COV
  ? require('./lib-cov/edalm')
  : require('./lib/edalm');
