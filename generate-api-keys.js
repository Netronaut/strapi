const crypto = require('crypto');

const fs = require('fs');
const path = require('path');
const template = require('lodash/template');

const generateASecret = () => crypto.randomBytes(16).toString('base64');

const tmpl = fs.readFileSync(path.join(__dirname, 'env.template'));
const compile = template(tmpl);

console.log(compile({
  appKeys: new Array(4)
    .fill()
    .map(generateASecret)
    .join(','),
  apiTokenSalt: generateASecret(),
  adminJwtToken: generateASecret(),
}));
