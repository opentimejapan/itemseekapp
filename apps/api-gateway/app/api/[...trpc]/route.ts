import { initTRPC } from '@trpc/server';
import { z } from 'zod';
import { db, items, locations, tasks } from '@itemseek/db';
import { eq } from 'drizzle-orm';
import { 
  ItemSchema, 
  LocationSchema, 
  TaskSchema,
  BusinessConfigSchema 
} from '@itemseek/api-contracts';

const t = initTRPC.create();

// Industry-agnostic API (<100 lines)
export const appRouter = t.router({
  // Business configuration
  config: t.procedure.query(async () => {
    // In production, this would come from DB based on tenant
    return {
      id: '1',
      name: 'Your Business',
      industry: process.env.INDUSTRY || 'general',
      itemCategories: ['Category A', 'Category B', 'Category C'],
      itemStatuses: ['available', 'low', 'out-of-stock'],
      locationTypes: ['Zone A', 'Zone B', 'Storage'],
      taskTypes: ['maintenance', 'cleaning', 'inspection'],
      units: ['pieces', 'kg', 'liters'],
      customFields: {}
    };
  }),

  // Items
  items: t.procedure.query(async () => {
    return await db.select().from(items);
  }),
  
  updateItem: t.procedure
    .input(z.object({ 
      id: z.string(), 
      delta: z.number() 
    }))
    .mutation(async ({ input }) => {
      const item = await db.select().from(items).where(eq(items.id, input.id)).limit(1);
      if (item[0]) {
        await db.update(items)
          .set({ quantity: item[0].quantity + input.delta })
          .where(eq(items.id, input.id));
      }
    }),

  // Locations
  locations: t.procedure.query(async () => {
    return await db.select().from(locations);
  }),
  
  updateLocation: t.procedure
    .input(z.object({ 
      id: z.string(), 
      status: z.string() 
    }))
    .mutation(async ({ input }) => {
      await db.update(locations)
        .set({ status: input.status })
        .where(eq(locations.id, input.id));
    }),

  // Tasks
  tasks: t.procedure.query(async () => {
    return await db.select().from(tasks);
  }),
  
  updateTask: t.procedure
    .input(z.object({ 
      id: z.string(), 
      status: z.string() 
    }))
    .mutation(async ({ input }) => {
      await db.update(tasks)
        .set({ status: input.status })
        .where(eq(tasks.id, input.id));
    })
});

export type AppRouter = typeof appRouter;

// Next.js route handler
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api',
    req,
    router: appRouter,
    createContext: () => ({})
  });

export { handler as GET, handler as POST };