const jwt = require('jsonwebtoken');

const SECRET  = process.env.JWT_SECRET || 'dev-secret-change-in-production';
const EXPIRY  = '24h';
const ALG     = 'HS256';

/**
 * Issue a signed JWT for the given user row.
 * The compact JWT form is base64url-encoded — alphanumeric plus '-', '_', '.'
 * separators — and is always well over 20 characters in length.
 *
 * Payload: { sub, role, iat, exp }
 */
function issueToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role },
    SECRET,
    { algorithm: ALG, expiresIn: EXPIRY }
  );
}

function verifyToken(token) {
  return jwt.verify(token, SECRET, { algorithms: [ALG] });
}

module.exports = { issueToken, verifyToken };
