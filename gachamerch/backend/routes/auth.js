const router = require('express').Router();
const { body } = require('express-validator');
const { requireAuth } = require('../middleware/auth');
const ctrl = require('../controllers/authController');

const registerRules = [
  body('username')
    .trim().isLength({ min: 3, max: 50 })
    .withMessage('Username must be 3–50 characters')
    .matches(/^[A-Za-z0-9_]+$/)
    .withMessage('Username may only contain letters, digits, and underscores'),
  body('email')
    .isEmail().withMessage('Must be a valid email address').normalizeEmail(),
  body('password')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Za-z]/).withMessage('Password must contain at least one letter')
    .matches(/\d/).withMessage('Password must contain at least one digit'),
];

const loginRules = [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required'),
];

router.post('/register', registerRules, ctrl.register);
router.post('/login',    loginRules,    ctrl.login);
router.post('/google',                  ctrl.googleAuth);
router.get('/me',        requireAuth,   ctrl.me);

module.exports = router;
