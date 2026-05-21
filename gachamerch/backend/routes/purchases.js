const router = require('express').Router();
const { requireAuth, requireAdmin } = require('../middleware/auth');
const ctrl = require('../controllers/purchaseController');

router.get('/me', requireAuth,  ctrl.myPurchases);   // GET #4
router.get('/',   requireAdmin, ctrl.allPurchases);  // GET #5

module.exports = router;
