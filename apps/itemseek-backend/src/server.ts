import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { itemsRouter } from './routes/items.js';
import { locationsRouter } from './routes/locations.js';
import { tasksRouter } from './routes/tasks.js';
import { configRouter } from './routes/config.js';
import { authRouter } from './routes/auth.js';
import { errorHandler } from './middleware/error.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3100;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3001', 'http://localhost:3002', 'http://localhost:3003'],
  credentials: true
}));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRouter);
app.use('/api/config', configRouter);
app.use('/api/items', itemsRouter);
app.use('/api/locations', locationsRouter);
app.use('/api/tasks', tasksRouter);

// Error handling
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Backend server running on http://localhost:${PORT}`);
  console.log(`📊 Database: ${process.env.DATABASE_URL ? 'Connected' : 'Not configured'}`);
});