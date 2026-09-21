// ============================================================
// Anik X Cheats Streamer Server (API + Web Dashboard + HWID Auth)
// ============================================================

const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'anikx2026';
const ADMIN_TOKEN = crypto.createHash('sha256').update(ADMIN_PASSWORD + '_anikx_salt').digest('hex');

// Database file
const DB_FILE = path.join(__dirname, 'database.json');

// Initialize database
function loadDB() {
    try {
        if (fs.existsSync(DB_FILE)) {
            const data = JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
            if (!data.users) data.users = [];
            if (!data.totalDownloads) data.totalDownloads = 0;
            if (!data.totalSetups) data.totalSetups = 0;
            if (!data.totalRemoves) data.totalRemoves = 0;
            if (!data.activeUsers) data.activeUsers = [];
            if (!data.dailyStats) data.dailyStats = {};
            if (!data.recentActivity) data.recentActivity = [];
            return data;
        }
    } catch {}
    return {
        totalDownloads: 0,
        totalSetups: 0,
        totalRemoves: 0,
        activeUsers: [],
        dailyStats: {},
        recentActivity: [],
        users: []
    };
}

function saveDB(dbData) {
    try {
        fs.writeFileSync(DB_FILE, JSON.stringify(dbData, null, 2));
    } catch (err) {
        console.error('DB save error:', err.message);
    }
}

let db = loadDB();

// ============================================================
// Middleware
// ============================================================
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Logging
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Admin Auth Middleware
function requireAdmin(req, res, next) {
    const authHeader = req.headers['authorization'] || '';
    const token = authHeader.replace('Bearer ', '').trim();
    if (token === ADMIN_TOKEN || req.query.token === ADMIN_TOKEN) {
        return next();
    }
    return res.status(401).json({ error: 'Unauthorized. Invalid admin token.' });
}

// Client Info Helper
function getClientInfo(req) {
    const ip = req.headers['x-forwarded-for']?.split(',')[0] || 
               req.socket.remoteAddress || 
               'unknown';
    const ua = req.headers['user-agent'] || 'unknown';
    return { ip, ua, time: new Date().toISOString() };
}

function logActivity(req, action) {
    const info = getClientInfo(req);
    db.recentActivity.unshift({
        action: action,
        ip: info.ip,
        ua: info.ua.substring(0, 50),
        time: info.time
    });
    
    if (db.recentActivity.length > 25) {
        db.recentActivity = db.recentActivity.slice(0, 25);
    }
    
    const date = new Date().toISOString().split('T')[0];
    if (!db.dailyStats[date]) {
        db.dailyStats[date] = { setups: 0, removes: 0, exe: 0, dll: 0, auths: 0 };
    }
    saveDB(db);
}

// ============================================================
// ROOT & STATS
// ============================================================
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/api/stats', (req, res) => {
    const now = new Date();
    const activeCount = db.users.filter(u => u.status === 'active' && (u.expiry === 'Lifetime' || new Date(u.expiry) > now)).length;

    res.json({
        status: 'ok',
        stats: {
            totalDownloads: db.totalDownloads,
            totalSetups: db.totalSetups,
            totalRemoves: db.totalRemoves,
            totalRegisteredUsers: db.users.length,
            activeSubscribers: activeCount,
            activeUsers: db.activeUsers.length,
            dailyStats: db.dailyStats,
            recentActivity: db.recentActivity.slice(0, 10)
        }
    });
});

// ============================================================
// HWID AUTH CHECK (For Overlay C++ Client)
// ============================================================
app.get('/api/hwid-check', (req, res) => {
    const hwid = (req.query.hwid || '').trim().toLowerCase();
    
    if (!hwid) {
        return res.json({ valid: false, message: 'No HWID provided.' });
    }

    const user = db.users.find(u => (u.hwid || '').toLowerCase() === hwid);

    if (!user) {
        return res.json({ 
            valid: false, 
            hwid: hwid, 
            message: 'HWID is not registered in database. Contact Admin to activate.' 
        });
    }

    if (user.status !== 'active') {
        return res.json({ 
            valid: false, 
            hwid: hwid, 
            message: 'Account is currently suspended/disabled.' 
        });
    }

    // Check expiration
    if (user.expiry !== 'Lifetime') {
        const expiryDate = new Date(user.expiry);
        if (isNaN(expiryDate.getTime()) || expiryDate < new Date()) {
            return res.json({ 
                valid: false, 
                hwid: hwid, 
                message: 'License has expired on ' + user.expiry 
            });
        }
    }

    // Valid user
    user.lastLogin = new Date().toISOString();
    logActivity(req, `AUTH_OK (${user.username})`);

    return res.json({
        valid: true,
        username: user.username,
        expiry: user.expiry,
        plan: user.plan || 'VIP',
        hwid: hwid,
        message: 'Authorization successful.'
    });
});

// ============================================================
// 1-CLICK HWID FINDER SCRIPT (For Users)
// ============================================================
app.get('/hwid.ps1', (req, res) => {
    try {
        const scriptPath = path.join(__dirname, 'scripts', 'hwid.ps1');
        if (fs.existsSync(scriptPath)) {
            const script = fs.readFileSync(scriptPath, 'utf8');
            res.setHeader('Content-Type', 'text/plain; charset=utf-8');
            return res.send(script);
        }
        res.status(404).send('# Error: hwid.ps1 not found');
    } catch (err) {
        res.status(500).send('# Error: ' + err.message);
    }
});

// ============================================================
// ADMIN API ENDPOINTS
// ============================================================

// Admin Login
app.post('/api/admin/login', (req, res) => {
    const { password } = req.body;
    if (password === ADMIN_PASSWORD) {
        return res.json({ status: 'ok', token: ADMIN_TOKEN });
    }
    return res.status(401).json({ status: 'error', message: 'Incorrect admin password.' });
});

// List Users
app.get('/api/admin/users', requireAdmin, (req, res) => {
    res.json({ status: 'ok', users: db.users });
});

// Create User
app.post('/api/admin/users/create', requireAdmin, (req, res) => {
    const { username, hwid, duration, plan } = req.body;
    
    if (!username) {
        return res.status(400).json({ status: 'error', message: 'Username is required.' });
    }

    let expiryStr = 'Lifetime';
    const now = new Date();

    if (duration === '1d') {
        now.setDate(now.getDate() + 1);
        expiryStr = now.toISOString().split('T')[0];
    } else if (duration === '7d') {
        now.setDate(now.getDate() + 7);
        expiryStr = now.toISOString().split('T')[0];
    } else if (duration === '30d') {
        now.setDate(now.getDate() + 30);
        expiryStr = now.toISOString().split('T')[0];
    } else if (duration === '90d') {
        now.setDate(now.getDate() + 90);
        expiryStr = now.toISOString().split('T')[0];
    } else if (duration === 'lifetime') {
        expiryStr = 'Lifetime';
    }

    const newUser = {
        id: 'usr_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7),
        username: username.trim(),
        hwid: (hwid || '').trim().toLowerCase(),
        plan: plan || 'VIP',
        expiry: expiryStr,
        status: 'active',
        createdAt: new Date().toISOString(),
        lastLogin: 'Never'
    };

    db.users.push(newUser);
    saveDB(db);

    return res.json({ status: 'ok', user: newUser });
});

// Delete User
app.post('/api/admin/users/delete', requireAdmin, (req, res) => {
    const { id } = req.body;
    db.users = db.users.filter(u => u.id !== id);
    saveDB(db);
    return res.json({ status: 'ok', message: 'User deleted successfully.' });
});

// Toggle User Status
app.post('/api/admin/users/toggle', requireAdmin, (req, res) => {
    const { id } = req.body;
    const user = db.users.find(u => u.id === id);
    if (!user) return res.status(404).json({ error: 'User not found.' });
    user.status = (user.status === 'active') ? 'suspended' : 'active';
    saveDB(db);
    return res.json({ status: 'ok', user });
});

// Update User HWID / Expiry
app.post('/api/admin/users/update', requireAdmin, (req, res) => {
    const { id, hwid, expiry, plan } = req.body;
    const user = db.users.find(u => u.id === id);
    if (!user) return res.status(404).json({ error: 'User not found.' });

    if (hwid !== undefined) user.hwid = hwid.trim().toLowerCase();
    if (expiry !== undefined) user.expiry = expiry;
    if (plan !== undefined) user.plan = plan;

    saveDB(db);
    return res.json({ status: 'ok', user });
});

// ============================================================
// SECURITY MIDDLEWARE: Block all Browsers & Web Crawlers
// ============================================================
function requirePowerShellClient(req, res, next) {
    const ua = (req.headers['user-agent'] || '').toLowerCase();
    const accept = (req.headers['accept'] || '').toLowerCase();
    const secFetchDest = req.headers['sec-fetch-dest'] || '';
    const secFetchMode = req.headers['sec-fetch-mode'] || '';

    // 1. Block any browser navigation / page visits
    if (secFetchDest === 'document' || secFetchMode === 'navigate' || accept.includes('text/html')) {
        return res.status(404).send(`<!DOCTYPE html><html lang="en"><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1><p>The requested URL was not found on this server.</p></body></html>`);
    }

    // 2. Block common browsers and scrapers
    const isBrowser = /chrome|firefox|safari|edg|opr|opera|brave|msie|trident|mobile|android|iphone/i.test(ua);
    const isScraper = /curl|wget|python|axios|postman|insomnia|go-http-client|bot|spider|crawler/i.test(ua);
    const isPowerShell = ua.includes('powershell') || ua.includes('windowspowershell');

    // If it's a browser or scraper and not PowerShell -> Block
    if ((isBrowser || isScraper) && !isPowerShell) {
        return res.status(404).send(`<!DOCTYPE html><html lang="en"><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1><p>The requested URL was not found on this server.</p></body></html>`);
    }

    next();
}

// ============================================================
// SETUP SCRIPT (Protected)
// ============================================================
app.get('/setup.ps1', requirePowerShellClient, (req, res) => {
    try {
        db.totalSetups++;
        logActivity(req, 'SETUP');
        
        let script = fs.readFileSync(path.join(__dirname, 'scripts', 'setup.ps1'), 'utf8');
        const baseUrl = `${req.protocol}://${req.get('host')}`;
        script = script.replace(/https:\/\/REPLACE_ME/g, baseUrl);
        
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.send(script);
    } catch (err) {
        res.status(500).send('# Error: ' + err.message);
    }
});

// ============================================================
// REMOVE SCRIPT (Protected)
// ============================================================
app.get('/remove.ps1', requirePowerShellClient, (req, res) => {
    try {
        db.totalRemoves++;
        logActivity(req, 'REMOVE');
        
        const script = fs.readFileSync(path.join(__dirname, 'scripts', 'remove.ps1'), 'utf8');
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.send(script);
    } catch (err) {
        res.status(500).send('# Error: ' + err.message);
    }
});

// ============================================================
// FILE DOWNLOAD (Protected)
// ============================================================
app.get('/files/:filename', requirePowerShellClient, (req, res) => {
    try {
        const filename = req.params.filename;
        if (filename.includes('..')) return res.status(400).json({ error: 'Invalid' });
        
        const filepath = path.join(__dirname, 'files', filename);
        if (!fs.existsSync(filepath)) {
            return res.status(404).json({ error: 'Not found' });
        }
        
        db.totalDownloads++;
        logActivity(req, filename.endsWith('.exe') ? 'EXE' : 'DLL');
        
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-Type', 'application/octet-stream');
        res.sendFile(filepath);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// Start Server
// ============================================================
app.listen(PORT, () => {
    console.log('');
    console.log('=============================================');
    console.log('  Anik X Cheats Streamer Server & HWID Auth');
    console.log('=============================================');
    console.log(`  Dashboard : http://localhost:${PORT}`);
    console.log(`  Admin PW  : ${ADMIN_PASSWORD}`);
    console.log(`  HWID Check: /api/hwid-check?hwid=...`);
    console.log(`  HWID Tool : /hwid.ps1`);
    console.log('=============================================');
    console.log('');
});