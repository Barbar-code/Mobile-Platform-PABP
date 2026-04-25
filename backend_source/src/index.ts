import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { sign, verify } from 'hono/jwt'

const app = new Hono()

// Mengizinkan Flutter (Front-end) mengambil data
app.use('/*', cors())

const SECRET = 'kunci-rahasia-tugas-platform'

// --- 1. MOCK DATABASE (In-Memory Array) ---
let games = [
  { id: 1, title: 'Mobile Legends', genre: 'MOBA', developer: 'Moonton' },
  { id: 2, title: 'Blue Archive', genre: 'RPG', developer: 'Nexon' },
  { id: 3, title: 'Clash of Clans', genre: 'Strategy', developer: 'Supercell' }
];

// --- 2. ROUTE LOGIN (Menghasilkan JWT) ---
app.post('/login', async (c) => {
  try {
    const body = await c.req.json()
    if (body.username === 'admin' && body.password === 'admin123') {
      const token = await sign({ username: body.username, role: 'admin' }, SECRET)
      return c.json({ token, message: 'Login sukses' })
    }
    return c.json({ error: 'Username atau password salah' }, 401)
  } catch (error) {
    return c.json({ error: 'Format request salah' }, 400)
  }
})

// --- 3. MIDDLEWARE PROTEKSI API (Wajib bawa Token) ---
app.use('/api/*', async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Akses ditolak. Token tidak ditemukan.' }, 401)
  }
  
  const token = authHeader.split(' ')[1]
  try {
    await verify(token, SECRET, 'HS256')
    await next() // Lanjut ke proses CRUD kalau token valid
  } catch (e) {
    return c.json({ error: 'Akses ditolak. Token tidak valid atau kadaluarsa.' }, 401)
  }
})

// --- 4. ROUTES CRUD FULLSTACK ---

// [R]EAD - Mengambil semua data game
app.get('/api/games', (c) => {
  return c.json({ data: games })
})

// [C]REATE - Menambahkan game baru
app.post('/api/games', async (c) => {
  const body = await c.req.json()
  
  const newGame = {
    // Bikin ID otomatis (Mencari ID paling besar, lalu ditambah 1)
    id: games.length > 0 ? Math.max(...games.map(g => g.id)) + 1 : 1,
    title: body.title,
    genre: body.genre,
    developer: body.developer
  }
  
  games.push(newGame)
  return c.json({ message: 'Game berhasil ditambahkan!', data: newGame }, 201)
})

// [U]PDATE - Mengubah data game berdasarkan ID
app.put('/api/games/:id', async (c) => {
  const id = parseInt(c.req.param('id'))
  const body = await c.req.json()
  
  // Cari posisi (index) game yang mau diedit
  const index = games.findIndex(g => g.id === id)
  
  if (index !== -1) {
    // Timpa data lama dengan data baru
    games[index] = { ...games[index], ...body, id: id }
    return c.json({ message: 'Game berhasil diperbarui!', data: games[index] })
  }
  
  return c.json({ error: 'Game tidak ditemukan' }, 404)
})

// [D]ELETE - Menghapus data game berdasarkan ID
app.delete('/api/games/:id', (c) => {
  const id = parseInt(c.req.param('id'))
  const initialLength = games.length
  
  // Filter array: simpan semua game KECUALI yang ID-nya sama dengan yang dihapus
  games = games.filter(g => g.id !== id)
  
  if (games.length < initialLength) {
    return c.json({ message: 'Game berhasil dihapus!' })
  }
  
  return c.json({ error: 'Game tidak ditemukan' }, 404)
})

// --- 5. NYALAKAN SERVER ---
const port = 3000
console.log(`Server backend siap tempur di port ${port}!`)

serve({
  fetch: app.fetch,
  port
})