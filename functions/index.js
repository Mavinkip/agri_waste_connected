const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();
const db = admin.firestore();
const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

// ============================================
// FARMER APIs FOR USSD
// ============================================

// 1. GET FARMER BALANCE
// USSD calls: GET /api/farmer/{phone}/balance
app.get('/api/farmer/:phone/balance', async (req, res) => {
  try {
    const { phone } = req.params;
    const farmerQuery = await db.collection('farmers')
      .where('phoneNumber', '==', phone)
      .limit(1)
      .get();

    if (farmerQuery.empty) {
      return res.status(404).json({ error: 'Farmer not found' });
    }

    const farmer = farmerQuery.docs[0].data();
    
    // Get wallet balance
    const walletQuery = await db.collection('wallets')
      .where('farmerId', '==', farmerQuery.docs[0].id)
      .limit(1)
      .get();

    const wallet = walletQuery.empty ? { balance: 0, totalEarnings: 0 } : walletQuery.docs[0].data();

    return res.json({
      success: true,
      data: {
        phone: phone,
        name: farmer.fullName,
        totalEarnings: wallet.totalEarnings || 0,
        availableBalance: wallet.balance || 0,
        pendingBalance: (wallet.totalEarnings || 0) - (wallet.balance || 0),
        completedSales: farmer.completedPickups || 0,
        activeListings: farmer.activeListings || 0,
        consistencyScore: farmer.consistencyScore || 0
      }
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// 2. GET FARMER STATS (Dashboard Summary)
// USSD calls: GET /api/farmer/{phone}/stats
app.get('/api/farmer/:phone/stats', async (req, res) => {
  try {
    const { phone } = req.params;
    const farmerQuery = await db.collection('farmers')
      .where('phoneNumber', '==', phone)
      .limit(1)
      .get();

    if (farmerQuery.empty) {
      return res.status(404).json({ error: 'Farmer not found' });
    }

    const farmer = farmerQuery.docs[0].data();
    const farmerId = farmerQuery.docs[0].id;

    // Get active listings count
    const listingsQuery = await db.collection('listings')
      .where('farmerId', '==', farmerId)
      .where('status', 'in', ['pending', 'assigned', 'inTransit'])
      .get();

    // Get completed sales
    const completedQuery = await db.collection('listings')
      .where('farmerId', '==', farmerId)
      .where('status', '==', 'completed')
      .get();

    return res.json({
      success: true,
      data: {
        activeListings: listingsQuery.size,
        completedSales: completedQuery.size,
        totalPickups: farmer.completedPickups || 0,
        averageRating: farmer.averageRating || 0,
        earningsToday: await getTodaysEarnings(farmerId)
      }
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// 3. GET RECENT TRANSACTIONS
// USSD calls: GET /api/farmer/{phone}/transactions?limit=5
app.get('/api/farmer/:phone/transactions', async (req, res) => {
  try {
    const { phone } = req.params;
    const limit = parseInt(req.query.limit) || 5;

    const farmerQuery = await db.collection('farmers')
      .where('phoneNumber', '==', phone)
      .limit(1)
      .get();

    if (farmerQuery.empty) {
      return res.status(404).json({ error: 'Farmer not found' });
    }

    const farmerId = farmerQuery.docs[0].id;

    const transactionsQuery = await db.collection('transactions')
      .where('farmerId', '==', farmerId)
      .orderBy('date', 'desc')
      .limit(limit)
      .get();

    const transactions = [];
    transactionsQuery.forEach(doc => {
      const data = doc.data();
      transactions.push({
        id: doc.id,
        date: data.date?.toDate()?.toISOString() || new Date().toISOString(),
        amount: data.amount || 0,
        wasteType: data.wasteType || 'Unknown',
        quantity: data.quantity || 0,
        status: data.status || 'completed'
      });
    });

    return res.json({
      success: true,
      data: transactions
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// 4. CREATE LISTING (from USSD)
// USSD calls: POST /api/listing
app.post('/api/listing', async (req, res) => {
  try {
    const { phone, wasteType, estimatedQuantity, pickupAddress } = req.body;

    // Find farmer by phone
    const farmerQuery = await db.collection('farmers')
      .where('phoneNumber', '==', phone)
      .limit(1)
      .get();

    if (farmerQuery.empty) {
      return res.status(404).json({ error: 'Farmer not found' });
    }

    const farmer = farmerQuery.docs[0];
    const farmerId = farmer.id;

    // Create listing
    const listing = {
      farmerId: farmerId,
      farmerName: farmer.data().fullName || 'Farmer',
      wasteType: wasteType || 'other',
      estimatedQuantity: parseFloat(estimatedQuantity) || 0,
      pickupAddress: pickupAddress || 'Default Location',
      pickupLat: '0',
      pickupLng: '0',
      status: 'pending',
      pickupType: 'manual',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isPhotoRequired: false,
      notes: 'Created via USSD'
    };

    const docRef = await db.collection('listings').add(listing);

    return res.json({
      success: true,
      message: 'Listing created successfully',
      data: {
        listingId: docRef.id,
        status: 'pending'
      }
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// 5. GET PRICING INFO
// USSD calls: GET /api/pricing
app.get('/api/pricing', async (req, res) => {
  try {
    const pricingDoc = await db.collection('settings')
      .doc('pricing')
      .get();

    const pricing = pricingDoc.exists ? pricingDoc.data() : {
      cropResidue: 5.00,
      fruitWaste: 4.50,
      vegetableWaste: 4.00,
      livestockManure: 3.00,
      coffeeHusks: 4.00,
      riceHulls: 3.50,
      cornStover: 4.00,
      other: 3.00
    };

    return res.json({
      success: true,
      data: pricing
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  return res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Helper function
async function getTodaysEarnings(farmerId) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const transactionsQuery = await db.collection('transactions')
    .where('farmerId', '==', farmerId)
    .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
    .get();

  let total = 0;
  transactionsQuery.forEach(doc => {
    total += doc.data().amount || 0;
  });

  return total;
}

// Export the API
exports.api = functions.https.onRequest(app);
