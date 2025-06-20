import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';

export const configRouter = Router();

// Get business configuration (<40 lines)
// In production, this would be stored in DB per tenant
configRouter.get('/', authMiddleware, async (req, res) => {
  const industry = process.env.INDUSTRY || 'general';
  
  const configs: Record<string, any> = {
    hotel: {
      id: '1',
      name: 'Hotel Management',
      industry: 'hotel',
      itemCategories: ['Linens', 'Amenities', 'Minibar', 'Maintenance Supplies'],
      itemStatuses: ['available', 'in-use', 'laundry', 'damaged'],
      locationTypes: ['Guest Room', 'Suite', 'Storage', 'Laundry Room'],
      taskTypes: ['Room Cleaning', 'Laundry', 'Maintenance', 'Inspection'],
      units: ['pieces', 'sets', 'bottles', 'packs']
    },
    restaurant: {
      id: '2',
      name: 'Restaurant Management',
      industry: 'restaurant',
      itemCategories: ['Ingredients', 'Beverages', 'Disposables', 'Equipment'],
      itemStatuses: ['in-stock', 'low', 'out', 'expired'],
      locationTypes: ['Kitchen', 'Pantry', 'Walk-in Cooler', 'Bar', 'Dining Area'],
      taskTypes: ['Prep', 'Cleaning', 'Inventory Check', 'Equipment Maintenance'],
      units: ['kg', 'g', 'liters', 'pieces', 'portions']
    },
    general: {
      id: '3',
      name: 'Inventory Management',
      industry: 'general',
      itemCategories: ['Products', 'Supplies', 'Equipment', 'Materials'],
      itemStatuses: ['available', 'low', 'out-of-stock', 'reserved'],
      locationTypes: ['Warehouse', 'Shelf', 'Storage Room', 'Office'],
      taskTypes: ['Restock', 'Count', 'Maintenance', 'Delivery'],
      units: ['pieces', 'boxes', 'pallets', 'units']
    }
  };
  
  res.json(configs[industry] || configs.general);
});