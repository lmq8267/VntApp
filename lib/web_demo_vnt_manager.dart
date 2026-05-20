import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vnt_app/network_config.dart';
import 'package:vnt_app/web_demo_config.dart';

/// Web Demo 模式的 VNT Manager
/// 模拟真实的 VPN 连接行为
class WebDemoVntManager {
  static bool _isConnected = false;
  static Timer? _trafficTimer;
  static NetworkConfig? _currentConfig;
  static final StreamController<Map<String, dynamic>> _statusController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  static Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  
  /// 模拟连接
  static Future<bool> connect(NetworkConfig config) async {
    if (_isConnected) return true;
    
    // 模拟连接延迟
    await Future.delayed(DemoModeConfig.connectDelay);
    
    DemoModeConfig.reset();
    _isConnected = true;
    _currentConfig = config;
    DemoModeConfig.setConnected(config.itemKey);
    
    // 启动流量模拟
    _trafficTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DemoModeConfig.simulateTraffic();
      _statusController.add({
        'connected': true,
        'upload': DemoModeConfig.uploadBytes,
        'download': DemoModeConfig.downloadBytes,
        'devices': DemoModeConfig.getMockDevices(),
        'currentDevice': DemoModeConfig.getCurrentDeviceInfo(
          config.virtualIPv4.isEmpty ? '10.26.0.100' : config.virtualIPv4
        ),
        'routes': DemoModeConfig.getMockRoutes(),
      });
    });
    
    // 立即发送一次状态
    _statusController.add({
      'connected': true,
      'upload': 0,
      'download': 0,
      'devices': DemoModeConfig.getMockDevices(),
      'currentDevice': DemoModeConfig.getCurrentDeviceInfo(
        config.virtualIPv4.isEmpty ? '10.26.0.100' : config.virtualIPv4
      ),
      'routes': DemoModeConfig.getMockRoutes(),
    });
    
    if (kDebugMode) {
      print('🎮 Demo Mode: Connected to ${config.configName}');
    }
    
    return true;
  }
  
  /// 模拟断开连接
  static Future<bool> disconnect() async {
    if (!_isConnected) return true;
    
    _isConnected = false;
    _currentConfig = null;
    _trafficTimer?.cancel();
    _trafficTimer = null;
    DemoModeConfig.reset();
    
    _statusController.add({
      'connected': false,
    });
    
    if (kDebugMode) {
      print('🎮 Demo Mode: Disconnected');
    }
    
    return true;
  }
  
  /// 获取连接状态
  static bool get isConnected => _isConnected;
  
  /// 获取当前配置
  static NetworkConfig? get currentConfig => _currentConfig;
  
  /// 获取设备列表
  static List<Map<String, dynamic>> getDevices() {
    return DemoModeConfig.getMockDevices();
  }
  
  /// 获取路由表
  static List<Map<String, dynamic>> getRoutes() {
    return DemoModeConfig.getMockRoutes();
  }
  
  /// 获取当前设备信息
  static Map<String, dynamic> getCurrentDevice() {
    if (_currentConfig == null) {
      return {};
    }
    return DemoModeConfig.getCurrentDeviceInfo(
      _currentConfig!.virtualIPv4.isEmpty ? '10.26.0.1' : _currentConfig!.virtualIPv4
    );
  }
  
  /// 清理资源
  static void dispose() {
    _trafficTimer?.cancel();
    _statusController.close();
  }
}
