import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db/connection.js';
import { tasks } from '@itemseek/db';
import { eq } from 'drizzle-orm';
import { TaskSchema } from '@itemseek/api-contracts';
import { authMiddleware } from '../middleware/auth.js';

export const tasksRouter = Router();

// Get all tasks (<20 lines)
tasksRouter.get('/', authMiddleware, async (req, res, next) => {
  try {
    const { status, type } = req.query;
    let query = db.select().from(tasks);
    
    if (status) {
      query = query.where(eq(tasks.status, status as string));
    }
    
    if (type) {
      query = query.where(eq(tasks.type, type as string));
    }
    
    const result = await query;
    res.json(result);
  } catch (error) {
    next(error);
  }
});

// Update task (<20 lines)
tasksRouter.patch('/:id', authMiddleware, async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = z.object({
      status: z.string().optional(),
      assignee: z.string().optional(),
      completedAt: z.date().optional()
    }).parse(req.body);
    
    const result = await db.update(tasks)
      .set(updates)
      .where(eq(tasks.id, id))
      .returning();
    
    if (!result.length) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    res.json(result[0]);
  } catch (error) {
    next(error);
  }
});

// Create task (<20 lines)
tasksRouter.post('/', authMiddleware, async (req, res, next) => {
  try {
    const data = TaskSchema.parse(req.body);
    const result = await db.insert(tasks).values({
      ...data,
      id: crypto.randomUUID()
    }).returning();
    res.status(201).json(result[0]);
  } catch (error) {
    next(error);
  }
});