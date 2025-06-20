import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db/connection.js';
import { locations } from '@itemseek/db';
import { eq } from 'drizzle-orm';
import { LocationSchema } from '@itemseek/api-contracts';
import { authMiddleware } from '../middleware/auth.js';

export const locationsRouter = Router();

// Get all locations (<20 lines)
locationsRouter.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { type } = req.query;
    let query = db.select().from(locations);
    
    if (type && type !== 'all') {
      query = query.where(eq(locations.type, type as string));
    }
    
    const result = await query;
    res.json(result);
  } catch (error) {
    next(error);
  }
});

// Update location status (<20 lines)
locationsRouter.patch('/:id', authMiddleware, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = z.object({
      status: z.string()
    }).parse(req.body);
    
    const result = await db.update(locations)
      .set({ status })
      .where(eq(locations.id, id))
      .returning();
    
    if (!result.length) {
      return res.status(404).json({ error: 'Location not found' });
    }
    
    res.json(result[0]);
  } catch (error) {
    next(error);
  }
});

// Create location (<20 lines)
locationsRouter.post('/', authMiddleware, async (req, res, next) => {
  try {
    const data = LocationSchema.parse(req.body);
    const result = await db.insert(locations).values({
      ...data,
      id: crypto.randomUUID()
    }).returning();
    res.status(201).json(result[0]);
  } catch (error) {
    next(error);
  }
});