require('dotenv').config();
const express = require('express');
const cors    = require('cors');

const authRoutes     = require('./routes/auth');
const itemRoutes     = require('./routes/items');
const purchaseRoutes = require('./routes/purchases');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check
app.get('/api/health', (_req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// Routes
app.use('/api/auth',      authRoutes);
app.use('/api/items',     itemRoutes);
app.use('/api/purchases', purchaseRoutes);

// 404
app.use((_req, res) => res.status(404).json({ error: 'Route not found' }));

// Centralized error handler — never leaks stack traces
app.use((err, _req, res, _next) => {
  console.error('[ERROR]', err.message);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({
    error:   err.message || 'Internal server error',
    details: err.details || [],
  });
});

app.listen(PORT, () => {
  console.log(`GachaMerch API listening on http://localhost:${PORT}`);
  console.log(`Health: GET http://localhost:${PORT}/api/health`);
});
