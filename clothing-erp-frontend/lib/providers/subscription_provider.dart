import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/subscription.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class PlanFeature {
  final String name;
  final bool freeEnabled;
  final bool basicEnabled;
  final bool proEnabled;

  PlanFeature({
    required this.name,
    required this.freeEnabled,
    required this.basicEnabled,
    required this.proEnabled,
  });
}

class SubscriptionProvider extends ChangeNotifier {
  Subscription? _subscription;
  List<PlanFeature> _planCompare = [];
  bool _isLoading = false;
  String? _error;

  Subscription? get subscription => _subscription;
  List<PlanFeature> get planCompare => _planCompare;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPro => _subscription?.planType == 'pro';
  bool get isBasic => _subscription?.planType == 'basic';
  bool get isFree => _subscription?.planType == 'free' || _subscription == null;

  Future<void> loadSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.subscriptionDetail,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _subscription = Subscription.fromJson(response.data!);
      } else {
        _error = response.message;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPlanCompare() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<List<dynamic>>(
        ApiConfig.subscriptionPlanCompare,
        fromJson: (json) => json as List<dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _planCompare = (response.data! as List).map((e) {
          final map = e as Map<String, dynamic>;
          return PlanFeature(
            name: map['name'] as String? ?? '',
            freeEnabled: map['freeEnabled'] as bool? ?? false,
            basicEnabled: map['basicEnabled'] as bool? ?? false,
            proEnabled: map['proEnabled'] as bool? ?? false,
          );
        }).toList();
      } else {
        _error = response.message;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> checkFeature(String featureKey) async {
    if (isPro) return true;

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.subscriptionCheckFeature,
        queryParameters: {'feature': featureKey},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!['enabled'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
