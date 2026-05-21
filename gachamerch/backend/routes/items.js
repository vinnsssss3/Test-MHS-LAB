const router = require('express').Router();
const { body } = require('express-validator');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const ctrl = require('../controllers/itemController');

const STORE_ENUM = ['honkai_star_retail', 'genshin_import', 'wuthering_wares'];

const itemRules = [
  body('store').isIn(STORE_ENUM).withMessage('Invalid store value'),
  body('name').trim().isLength({ min: 1, max: 120 }).withMessage('Name must be 1–120 characters'),
  body('type').trim().isLength({ min: 1, max: 40 }).withMessage('Type must be 1–40 characters'),
  body('description').trim().notEmpty().withMessage('Description is required'),
  body('stock').isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
  body('image').trim().notEmpty().withMessage('Image path is required'),
  body('price').isFloat({ min: 0 }).withMessage('Price must be a non-negative number'),
];

const buyRules = [
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
];

// Public
router.get('/stores',  ctrl.listStores);    // GET #3
router.get('/',        ctrl.listItems);      // GET #1
router.get('/:id',     ctrl.getItem);        // GET #2

// Admin CRUD
router.post('/',       requireAdmin, itemRules, ctrl.createItem);   // POST
router.put('/:id',     requireAdmin, itemRules, ctrl.updateItem);   // PUT
router.delete('/:id',  requireAdmin,            ctrl.deleteItem);   // DELETE

// Authenticated user
router.post('/:id/buy', requireAuth, buyRules, ctrl.buyItem);

module.exports = router;
