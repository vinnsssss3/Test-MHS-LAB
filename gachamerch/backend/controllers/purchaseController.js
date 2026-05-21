const pool = require('../config/db');

async function myPurchases(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, i.name AS item_name, i.image AS item_image
       FROM purchases p
       JOIN items i ON p.item_id = i.id
       WHERE p.user_id = ?
       ORDER BY p.created_at DESC`,
      [req.user.sub]
    );
    res.json({ purchases: rows });
  } catch (err) {
    next(err);
  }
}

async function allPurchases(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, i.name AS item_name, u.username
       FROM purchases p
       JOIN items i ON p.item_id = i.id
       JOIN users u ON p.user_id = u.id
       ORDER BY p.created_at DESC`
    );
    res.json({ purchases: rows });
  } catch (err) {
    next(err);
  }
}

module.exports = { myPurchases, allPurchases };
