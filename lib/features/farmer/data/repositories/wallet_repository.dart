import '../../../../core/network/api_client.dart';

class WalletRepository {
  final ApiClient _apiClient;
  
  WalletRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  // Get wallet balance
  Future<WalletBalance> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/farmer/wallet/balance');
      return WalletBalance.fromJson(response['data']);
    } catch (e) {
      return WalletBalance.empty();
    }
  }
  
  // Get transaction history
  Future<List<WalletTransaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      String url = '/farmer/wallet/transactions?page=$page&limit=$limit';
      if (type != null) {
        url += '&type=$type';
      }
      
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => WalletTransaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Request withdrawal
  Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/farmer/wallet/withdraw', {
        'amount': amount,
        'phone_number': phoneNumber,
        'notes': notes,
      });
      
      return WithdrawalResponse.fromJson(response['data']);
    } catch (e) {
      if (e is ApiException) {
        return WithdrawalResponse.failure(e.message);
      }
      return WithdrawalResponse.failure('Withdrawal failed');
    }
  }
  
  // Get withdrawal history
  Future<List<Withdrawal>> getWithdrawalHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/farmer/wallet/withdrawals?page=$page&limit=$limit');
      final List<dynamic> data = response['data'];
      return data.map((json) => Withdrawal.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get M-Pesa payment status
  Future<MpesaPaymentStatus> getMpesaPaymentStatus(String transactionId) async {
    try {
      final response = await _apiClient.get('/payments/mpesa/$transactionId/status');
      return MpesaPaymentStatus.fromJson(response['data']);
    } catch (e) {
      return MpesaPaymentStatus.failure('Failed to get payment status');
    }
  }
  
  // Get earnings breakdown by waste type
  Future<Map<String, double>> getEarningsByWasteType() async {
    try {
      final response = await _apiClient.get('/farmer/wallet/earnings-by-type');
      return Map<String, double>.from(response['data']);
    } catch (e) {
      return {};
    }
  }
  
  // Get earnings breakdown by time period
  Future<Map<String, double>> getEarningsByPeriod(String period) async {
    try {
      final response = await _apiClient.get('/farmer/wallet/earnings-by-period?period=$period');
      return Map<String, double>.from(response['data']);
    } catch (e) {
      return {};
    }
  }
}

// Wallet Balance Model
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
  
  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      availableBalance: (json['available_balance'] ?? 0).toDouble(),
      pendingBalance: (json['pending_balance'] ?? 0).toDouble(),
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      totalWithdrawn: (json['total_withdrawn'] ?? 0).toDouble(),
      lastUpdated: json['last_updated'] ?? DateTime.now().toIso8601String(),
    );
  }
  
  factory WalletBalance.empty() {
    return WalletBalance(
      availableBalance: 0,
      pendingBalance: 0,
      totalEarned: 0,
      totalWithdrawn: 0,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }
}

// Wallet Transaction Model
class WalletTransaction {
  final String id;
  final String type; // 'credit', 'debit', 'withdrawal'
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? reference;
  final Map<String, dynamic>? metadata;
  
  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.reference,
    this.metadata,
  });
  
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount']).toDouble(),
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      reference: json['reference'],
      metadata: json['metadata'],
    );
  }
}

// Withdrawal Model
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
  
  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'],
      amount: (json['amount']).toDouble(),
      status: json['status'],
      phoneNumber: json['phone_number'],
      requestedAt: DateTime.parse(json['requested_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      transactionId: json['transaction_id'],
      failureReason: json['failure_reason'],
    );
  }
}

// Withdrawal Response Model
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
  
  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      success: true,
      withdrawalId: json['withdrawal_id'],
      message: json['message'],
      status: json['status'],
    );
  }
  
  factory WithdrawalResponse.failure(String message) {
    return WithdrawalResponse(
      success: false,
      message: message,
    );
  }
}

// M-Pesa Payment Status Model
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
  
  factory MpesaPaymentStatus.fromJson(Map<String, dynamic> json) {
    return MpesaPaymentStatus(
      success: json['success'] ?? false,
      status: json['status'] ?? 'unknown',
      message: json['message'],
      transactionId: json['transaction_id'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
  
  factory MpesaPaymentStatus.failure(String message) {
    return MpesaPaymentStatus(
      success: false,
      status: 'failed',
      message: message,
    );
  }
}
