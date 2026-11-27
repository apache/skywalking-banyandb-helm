/*
# Licensed to Apache Software Foundation (ASF) under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Apache Software Foundation (ASF) licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*/
// Test-only identity provider; never deploy outside an isolated e2e cluster.
const http = require('node:http');
const crypto = require('node:crypto');
const issuer = 'http://canopy-sso-idp:8080';
const keys = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 });
const codes = new Map();
const tokens = new Map();
let healthy = true;
const b64 = value => Buffer.from(JSON.stringify(value)).toString('base64url');
http.createServer((req, res) => {
  const url = new URL(req.url, issuer);
  const json = (status, body) => { res.writeHead(status, { 'content-type': 'application/json' }); res.end(JSON.stringify(body)); };
  if (url.pathname === '/outage') { healthy = false; return json(200, {}); }
  if (!healthy) return json(503, {});
  if (url.pathname === '/.well-known/openid-configuration') return json(200, {
    issuer, authorization_endpoint: issuer + '/authorize', token_endpoint: issuer + '/token',
    jwks_uri: issuer + '/jwks', userinfo_endpoint: issuer + '/userinfo',
    token_endpoint_auth_methods_supported: ['client_secret_post'],
  });
  if (url.pathname === '/jwks') return json(200, { keys: [{ ...keys.publicKey.export({ format: 'jwk' }), kid: 'e2e', use: 'sig', alg: 'RS256' }] });
  if (url.pathname === '/authorize') {
    const code = crypto.randomBytes(16).toString('hex');
    codes.set(code, { challenge: url.searchParams.get('code_challenge'), nonce: url.searchParams.get('nonce'), email: url.searchParams.get('test_email') });
    const callback = new URL(url.searchParams.get('redirect_uri'));
    callback.searchParams.set('code', code);
    callback.searchParams.set('state', url.searchParams.get('state'));
    res.writeHead(302, { location: callback.href }); return res.end();
  }
  if (url.pathname === '/token' && req.method === 'POST') {
    let raw = '';
    req.on('data', chunk => raw += chunk);
    req.on('end', () => {
      const form = new URLSearchParams(raw);
      const code = codes.get(form.get('code'));
      codes.delete(form.get('code'));
      const challenge = crypto.createHash('sha256').update(form.get('code_verifier') || '').digest('base64url');
      if (!code || challenge !== code.challenge || form.get('client_secret') !== 'e2e-provider-secret') return json(400, { error: 'invalid_grant' });
      const token = crypto.randomBytes(16).toString('hex');
      tokens.set(token, code.email);
      const claims = { iss: issuer, aud: 'canopy-e2e', sub: code.email, email: code.email, email_verified: true,
        nonce: code.nonce, iat: Math.floor(Date.now()/1000), exp: Math.floor(Date.now()/1000)+300 };
      const data = b64({ alg: 'RS256', kid: 'e2e' }) + '.' + b64(claims);
      const signature = crypto.sign('sha256', Buffer.from(data), keys.privateKey).toString('base64url');
      json(200, { access_token: token, token_type: 'Bearer', id_token: data + '.' + signature });
    });
    return;
  }
  const email = tokens.get((req.headers.authorization || '').replace(/^Bearer /, ''));
  if (url.pathname === '/userinfo') return email ? json(200, { id: email, login: email, sub: email, email, email_verified: true }) : json(401, {});
  if (url.pathname === '/emails') return email ? json(200, [{ email, primary: true, verified: true }]) : json(401, {});
  json(404, {});
}).listen(8080, '0.0.0.0');
