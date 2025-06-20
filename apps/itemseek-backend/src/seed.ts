import { db } from './db/connection.js';
import { organizations, items, locations, tasks, users } from '@itemseek/db';
import dotenv from 'dotenv';

dotenv.config();

async function seed() {
  console.log('🌱 Seeding database...');
  
  try {
    // Create demo organization
    const [org] = await db.insert(organizations).values({
      name: 'Demo Hotel',
      industry: 'hotel',
      config: {
        id: '1',
        name: 'Demo Hotel',
        industry: 'hotel',
        itemCategories: ['Linens', 'Amenities', 'Minibar', 'Maintenance'],
        itemStatuses: ['available', 'in-use', 'laundry', 'low'],
        locationTypes: ['Guest Room', 'Suite', 'Storage', 'Laundry'],
        taskTypes: ['Cleaning', 'Laundry', 'Maintenance', 'Restock'],
        units: ['pieces', 'sets', 'bottles', 'packs']
      }
    }).returning();
    
    console.log('✓ Created organization:', org.name);
    
    // Create demo user
    await db.insert(users).values({
      organizationId: org.id,
      email: 'demo@itemseek.com',
      name: 'Demo User',
      role: 'admin'
    });
    
    // Create locations
    const roomNumbers = ['101', '102', '103', '201', '202', '203'];
    const rooms = await db.insert(locations).values(
      roomNumbers.map(num => ({
        organizationId: org.id,
        name: num,
        type: 'Guest Room',
        status: Math.random() > 0.7 ? 'occupied' : 'available'
      }))
    ).returning();
    
    console.log(`✓ Created ${rooms.length} rooms`);
    
    // Create items
    const itemsData = [
      { name: 'Bath Towel', category: 'Linens', quantity: 150, unit: 'pieces', location: 'Storage A' },
      { name: 'Hand Towel', category: 'Linens', quantity: 200, unit: 'pieces', location: 'Storage A' },
      { name: 'Bed Sheet Set', category: 'Linens', quantity: 80, unit: 'sets', location: 'Storage B' },
      { name: 'Shampoo', category: 'Amenities', quantity: 300, unit: 'bottles', location: 'Storage C' },
      { name: 'Soap', category: 'Amenities', quantity: 400, unit: 'pieces', location: 'Storage C' },
      { name: 'Mini Wine', category: 'Minibar', quantity: 50, unit: 'bottles', location: 'Bar Storage' },
      { name: 'Cleaning Supplies', category: 'Maintenance', quantity: 20, unit: 'packs', location: 'Janitor Room' }
    ];
    
    const createdItems = await db.insert(items).values(
      itemsData.map(item => ({
        ...item,
        organizationId: org.id,
        status: item.quantity < 100 ? 'low' : 'available'
      }))
    ).returning();
    
    console.log(`✓ Created ${createdItems.length} items`);
    
    // Create tasks
    await db.insert(tasks).values([
      {
        organizationId: org.id,
        type: 'Cleaning',
        targetId: rooms[0].id,
        targetType: 'location',
        status: 'pending',
        priority: 'high',
        dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000) // 2 hours
      },
      {
        organizationId: org.id,
        type: 'Laundry',
        targetId: createdItems[0].id,
        targetType: 'item',
        status: 'in-progress',
        priority: 'normal',
        assignee: 'John Doe'
      }
    ]);
    
    console.log('✓ Created sample tasks');
    console.log('🎉 Seeding complete!');
    
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

seed();