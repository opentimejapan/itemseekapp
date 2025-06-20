import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { z } from 'zod';

export const authRouter = Router();

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-in-production';

// Simple auth for demo - in production use proper auth service
authRouter.post('/login', async (req, res, next) => {
  try {
    const { email, password } = z.object({
      email: z.string().email(),
      password: z.string().min(6)
    }).parse(req.body);
    
    // Demo auth - accept any valid email/password combo
    // In production, validate against database
    if (email && password) {
      const token = jwt.sign(
        { userId: crypto.randomUUID(), email },
        JWT_SECRET,
        { expiresIn: '7d' }
      );
      
      res.json({ token, user: { email } });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    next(error);
  }
});

// Verify token
authRouter.get('/verify', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    res.json({ valid: true, user: decoded });
  } catch {
    res.status(401).json({ valid: false });
  }
});