const bcrypt       = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const pool         = require('../config/db');
const { issueToken } = require('../utils/token');
const { validationResult } = require('express-validator');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

function safeUser(row) {
  const { password_hash, oauth_sub, ...safe } = row;
  return safe;
}

async function register(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ error: 'Validation failed', details: errors.array() });
  }
  const { username, email, password } = req.body;
  try {
    const hash = await bcrypt.hash(password, 12);
    const [result] = await pool.query(
      'INSERT INTO users (username, email, password_hash, oauth_provider, role) VALUES (?,?,?,?,?)',
      [username, email, hash, 'local', 'user']
    );
    const [[row]] = await pool.query('SELECT * FROM users WHERE id=?', [result.insertId]);
    res.status(201).json({ user: safeUser(row) });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Username or email already taken' });
    }
    next(err);
  }
}

async function login(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ error: 'Validation failed', details: errors.array() });
  }
  const { username, password } = req.body;
  try {
    const [[row]] = await pool.query('SELECT * FROM users WHERE username=?', [username]);
    if (!row || !row.password_hash) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const match = await bcrypt.compare(password, row.password_hash);
    if (!match) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = issueToken(row);
    res.json({ token, user: safeUser(row) });
  } catch (err) {
    next(err);
  }
}

async function googleAuth(req, res, next) {
  const { idToken } = req.body;
  if (!idToken) {
    return res.status(400).json({ error: 'idToken is required' });
  }
  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { sub, email, name } = payload;

    const [[existing]] = await pool.query(
      'SELECT * FROM users WHERE oauth_provider=? AND oauth_sub=?',
      ['google', sub]
    );

    let row;
    if (existing) {
      row = existing;
    } else {
      const username = (name || email.split('@')[0]).replace(/\s+/g, '_').slice(0, 50);
      const safeUsername = `${username}_g${sub.slice(-4)}`;
      const [result] = await pool.query(
        'INSERT INTO users (username, email, oauth_provider, oauth_sub, role) VALUES (?,?,?,?,?)',
        [safeUsername, email, 'google', sub, 'user']
      );
      [[row]] = await pool.query('SELECT * FROM users WHERE id=?', [result.insertId]);
    }

    const token = issueToken(row);
    res.json({ token, user: safeUser(row) });
  } catch (err) {
    if (err.message && err.message.includes('Invalid token')) {
      return res.status(401).json({ error: 'Invalid Google ID token' });
    }
    next(err);
  }
}

async function me(req, res, next) {
  try {
    const [[row]] = await pool.query('SELECT * FROM users WHERE id=?', [req.user.sub]);
    if (!row) return res.status(404).json({ error: 'User not found' });
    res.json({ user: safeUser(row) });
  } catch (err) {
    next(err);
  }
}

module.exports = { register, login, googleAuth, me };
