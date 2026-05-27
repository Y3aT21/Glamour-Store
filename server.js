const express = require('express');
const session = require('express-session');
const flash = require('connect-flash');
const methodOverride = require('method-override');
const path = require('path');
require('dotenv').config();

const app = express();

// ===== MIDDLEWARE =====
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(methodOverride('_method'));
app.use(express.static(path.join(__dirname, 'public')));

app.use(session({
    secret: process.env.SESSION_SECRET || 'glamour_secret_key',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 } // 24 hours
}));

app.use(flash());

const { attachUser } = require('./middleware/auth');
app.use(attachUser);

// ===== ROUTES =====
app.use('/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/cart', require('./routes/cart'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api', require('./routes/api'));

// ===== PAGE ROUTES =====
app.get('/', (req, res) => res.sendFile('index.html', { root: './public' }));
app.get('/shop', (req, res) => res.sendFile('shop.html', { root: './public' }));
app.get('/product/:id', (req, res) => res.sendFile('product.html', { root: './public' }));
app.get('/cart', (req, res) => res.sendFile('cart.html', { root: './public' }));
app.get('/checkout', (req, res) => res.sendFile('checkout.html', { root: './public' }));
app.get('/orders', (req, res) => res.sendFile('orders.html', { root: './public' }));
app.get('/profile', (req, res) => res.sendFile('profile.html', { root: './public' }));
app.get('/wishlist', (req, res) => res.sendFile('wishlist.html', { root: './public' }));
app.get('/admin', (req, res) => res.sendFile('admin.html', { root: './public' }));
app.get('/auth/login', (req, res) => res.sendFile('login.html', { root: './public' }));
app.get('/auth/register', (req, res) => res.sendFile('register.html', { root: './public' }));

// Session check endpoint
app.get('/api/session', (req, res) => {
    res.json({ user: req.session.user || null });
});

// ===== 404 =====
app.use((req, res) => {
    res.status(404).sendFile('404.html', { root: './public' });
});

// ===== ERROR HANDLER =====
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ success: false, message: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`\n🛍️  Glamour Store running on http://localhost:${PORT}`);
    console.log(`📦  Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🔐  Admin login: admin@glamourstore.com / Admin@1234\n`);
});
