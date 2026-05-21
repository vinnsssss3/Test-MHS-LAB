const pool = require('../config/db');
const { validationResult } = require('express-validator');

const STORES_META = [
  {
    id: 'honkai_star_retail',
    label: 'Honkai Star Retail',
    tagline: 'Galactic resources & light cones',
    accent: '#FFD86B',
    background: '#0B1026',
    types: ['Light Cone', 'Galactic Resource'],
  },
  {
    id: 'genshin_import',
    label: 'Genshin Import',
    tagline: 'Teyvat weapons & artifacts',
    accent: '#5BD0C7',
    background: '#0E1A2B',
    types: ['Weapon', 'Artifact'],
  },
  {
    id: 'wuthering_wares',
    label: 'Wuthering Wares',
    tagline: 'Resonator equipment & terminal supplies',
    accent: '#E0455B',
    background: '#13121A',
    types: ['Resonator Equipment', 'Terminal Supply'],
  },
];

async function listStores(req, res) {
  res.json({ stores: STORES_META });
}

async function listItems(req, res, next) {
  try {
    const { store, type, q } = req.query;
    let sql = 'SELECT * FROM items WHERE 1=1';
    const params = [];

    if (store) { sql += ' AND store=?'; params.push(store); }
    if (type)  { sql += ' AND type=?';  params.push(type);  }
    if (q)     { sql += ' AND (name LIKE ? OR description LIKE ?)'; params.push(`%${q}%`, `%${q}%`); }

    sql += ' ORDER BY store, name';
    const [rows] = await pool.query(sql, params);
    res.json({ items: rows });
  } catch (err) {
    next(err);
  }
}

async function getItem(req, res, next) {
  try {
    const [[row]] = await pool.query('SELECT * FROM items WHERE id=?', [req.params.id]);
    if (!row) return res.status(404).json({ error: 'Item not found' });
    res.json({ item: row });
  } catch (err) {
    next(err);
  }
}

async function createItem(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ error: 'Validation failed', details: errors.array() });
  }
  const { store, name, type, description, stock, image, price } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO items (store, name, type, description, stock, image, price) VALUES (?,?,?,?,?,?,?)',
      [store, name, type, description, stock, image, price]
    );
    const [[row]] = await pool.query('SELECT * FROM items WHERE id=?', [result.insertId]);
    res.status(201).json({ item: row });
  } catch (err) {
    next(err);
  }
}

async function updateItem(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ error: 'Validation failed', details: errors.array() });
  }
  const { store, name, type, description, stock, image, price } = req.body;
  try {
    const [result] = await pool.query(
      'UPDATE items SET store=?, name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?',
      [store, name, type, description, stock, image, price, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Item not found' });
    const [[row]] = await pool.query('SELECT * FROM items WHERE id=?', [req.params.id]);
    res.json({ item: row });
  } catch (err) {
    next(err);
  }
}

async function deleteItem(req, res, next) {
  try {
    const [result] = await pool.query('DELETE FROM items WHERE id=?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Item not found' });
    res.json({ message: 'Item deleted' });
  } catch (err) {
    next(err);
  }
}

async function buyItem(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ error: 'Validation failed', details: errors.array() });
  }
  const quantity = parseInt(req.body.quantity, 10);
  const itemId   = parseInt(req.params.id, 10);
  const userId   = req.user.sub;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [[row]] = await conn.query(
      'SELECT stock, price, store FROM items WHERE id=? FOR UPDATE',
      [itemId]
    );
    if (!row) {
      await conn.rollback();
      return res.status(404).json({ error: 'Item not found' });
    }
    if (row.stock < quantity) {
      await conn.rollback();
      return res.status(400).json({ error: `Insufficient stock. Only ${row.stock} available.` });
    }

    await conn.query('UPDATE items SET stock = stock - ? WHERE id=?', [quantity, itemId]);
    const total = parseFloat(row.price) * quantity;
    const [ins] = await conn.query(
      'INSERT INTO purchases(user_id, item_id, store, quantity, unit_price, total) VALUES (?,?,?,?,?,?)',
      [userId, itemId, row.store, quantity, row.price, total]
    );

    await conn.commit();

    const [[purchase]] = await conn.query('SELECT * FROM purchases WHERE id=?', [ins.insertId]);
    res.status(201).json({ purchase });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

module.exports = { listStores, listItems, getItem, createItem, updateItem, deleteItem, buyItem };
