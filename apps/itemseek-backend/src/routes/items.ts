import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db/connection.js';
import { items } from '@itemseek/db';
import { eq, like } from 'drizzle-orm';
import { ItemSchema } from '@itemseek/api-contracts';
import { authMiddleware } from '../middleware/auth.js';

export const itemsRouter = Router();

// Get all items (<30 lines)
itemsRouter.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { category, search } = req.query;
    let query = db.select().from(items);
    
    if (category && category !== 'all') {
      query = query.where(eq(items.category, category as string));
    }
    
    if (search) {
      query = query.where(like(items.name, `%${search}%`));
    }
    
    const result = await query;
    res.json(result);
  } catch (error) {
    next(error);
  }
});

// Create item (<20 lines)
itemsRouter.post('/', authMiddleware, async (req, res, next) => {
  try {
    const data = ItemSchema.parse(req.body);
    const result = await db.insert(items).values({
      ...data,
      id: crypto.randomUUID()
    }).returning();
    res.status(201).json(result[0]);
  } catch (error) {
    next(error);
  }
});

// Update item quantity (<25 lines)
itemsRouter.post('/:id/transact', authMiddleware, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { type, quantity, reason } = z.object({
      type: z.enum(['in', 'out', 'adjust']),
      quantity: z.number().positive(),
      reason: z.string()
    }).parse(req.body);
    
    const [item] = await db.select().from(items).where(eq(items.id, id));
    if (!item) return res.status(404).json({ error: 'Item not found' });
    
    const delta = type === 'out' ? -quantity : quantity;
    const newQuantity = Math.max(0, item.quantity + delta);
    
    await db.update(items)
      .set({ quantity: newQuantity, lastUpdated: new Date() })
      .where(eq(items.id, id));
    
    res.json({ success: true, newQuantity });
  } catch (error) {
    next(error);
  }
});