import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WalletRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _uid => _auth.currentUser!.uid;

  Future<WalletBalance> getWalletBalance() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      final data = doc.data() ?? {};
      return WalletBalance(
        availableBalance: (data['walletBalance'] ?? 0).toDouble(),
        pendingBalance: (data['pendingBalance'] ?? 0).toDouble(),
        totalEarned: (data['totalEarnings'] ?? 0).toDouble(),
        totalWithdrawn: (data['totalWithdrawn'] ?? 0).toDouble(),
        lastUpdated: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      return WalletBalance.empty();
    }
  }

  Future<List<WalletTransaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      Query query = _firestore
          .collection('transactions')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (type != null) query = query.where('type', isEqualTo: type);

      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return WalletTransaction(
          id: doc.id,
          type: d['type'] ?? 'credit',
          amount: (d['amount'] ?? 0).toDouble(),
          status: d['status'] ?? 'completed',
          description: d['description'] ?? '',
          createdAt:
              (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          reference: d['mpesaRef'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final docRef =
          await _firestore.collection('withdrawals').add({
        'farmerId': _uid,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'notes': notes,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      return WithdrawalResponse(
        success: true,
        withdrawalId: docRef.id,
        message: 'Withdrawal request submitted',
        status: 'pending',
      );
    } catch (e) {
      return WithdrawalResponse.failure('Withdrawal request failed');
    }
  }

  Future<List<Withdrawal>> getWithdrawalHistory(
      {int page = 1, int limit = 20}) async {
    try {
      final snap = await _firestore
          .collection('withdrawals')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return Withdrawal(
          id: doc.id,
          amount: (d['amount'] ?? 0).toDouble(),
          status: d['status'] ?? 'pending',
          phoneNumber: d['phoneNumber'] ?? '',
          requestedAt:
              (d['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          processedAt: (d['processedAt'] as Timestamp?)?.toDate(),
          transactionId: d['mpesaRef'],
          failureReason: d['failureReason'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, double>> getEarningsByWasteType() async {
    try {
      final snap = await _firestore
          .collection('transactions')
          .where('farmerId', isEqualTo: _uid)
          .where('type', isEqualTo: 'credit')
          .get();

      final Map<String, double> result = {};
      for (final doc in snap.docs) {
        final d = doc.data();
        final type = d['wasteType'] as String? ?? 'other';
        final amount = (d['amount'] ?? 0).toDouble();
        result[type] = (result[type] ?? 0) + amount;
      }
      return result;
    } catch (e) {
      return {};
    }
  }
}

// ── Model classes ──

class WalletBalance {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final String lastUpdated;

  WalletBalance({
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.lastUpdated,
  });

  factory WalletBalance.empty() => WalletBalance(
        availableBalance: 0,
        pendingBalance: 0,
        totalEarned: 0,
        totalWithdrawn: 0,
        lastUpdated: DateTime.now().toIso8601String(),
      );
}

class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? reference;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.reference,
  });
}

class Withdrawal {
  final String id;
  final double amount;
  final String status;
  final String phoneNumber;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? transactionId;
  final String? failureReason;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.phoneNumber,
    required this.requestedAt,
    this.processedAt,
    this.transactionId,
    this.failureReason,
  });
}

class WithdrawalResponse {
  final bool success;
  final String? withdrawalId;
  final String? message;
  final String? status;

  WithdrawalResponse({
    required this.success,
    this.withdrawalId,
    this.message,
    this.status,
  });

  factory WithdrawalResponse.failure(String message) =>
      WithdrawalResponse(success: false, message: message);
}

class MpesaPaymentStatus {
  final bool success;
  final String status;
  final String? message;
  final String? transactionId;
  final DateTime? completedAt;

  MpesaPaymentStatus({
    required this.success,
    required this.status,
    this.message,
    this.transactionId,
    this.completedAt,
  });

  factory MpesaPaymentStatus.failure(String message) =>
      MpesaPaymentStatus(success: false, status: 'failed', message: message);
}
