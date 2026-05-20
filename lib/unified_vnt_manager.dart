import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:vnt_app/network_config.dart';
import 'package:vnt_app/vnt/vnt_manager.dart';
import 'package:vnt_app/web_demo_vnt_manager.dart';

/// 统一的连接管理器
/// 自动判断是否使用 Web Demo 模式
class UnifiedVntManager {
  static final Map<String, StreamSubscription> _webDemoSubscriptions = {};
  
  /// 连接
  static Future<void> connect(NetworkConfig config, SendPort sendPort) async {
    if (kIsWeb) {
      // Web Demo 模式
      final success = await WebDemoVntManager.connect(config);
      if (success) {
        sendPort.send('success');
        
        // 订阅状态更新
        _webDemoSubscriptions[config.itemKey] = 
            WebDemoVntManager.statusStream.listen((status) {
          sendPort.send(status);
        });
      } else {
        sendPort.send({'error': 'Connection failed'});
      }
    } else {
      // 原生模式
      await vntManager.create(config, sendPort);
    }
  }
  
  /// 断开连接
  static Future<void> disconnect(String configKey) async {
    if (kIsWeb) {
      // Web Demo 模式
      _webDemoSubscriptions[configKey]?.cancel();
      _webDemoSubscriptions.remove(configKey);
      await WebDemoVntManager.disconnect();
    } else {
      // 原生模式
      await vntManager.remove(configKey);
    }
  }
  
  /// 检查是否已连接
  static bool isConnected(String configKey) {
    if (kIsWeb) {
      return WebDemoVntManager.isConnected;
    } else {
      return vntManager.hasConnectionItem(configKey);
    }
  }
  
  /// 检查是否有任何连接
  static bool hasAnyConnection() {
    if (kIsWeb) {
      return WebDemoVntManager.isConnected;
    } else {
      return vntManager.hasConnection();
    }
  }
  
  /// 清理所有连接
  static Future<void> disconnectAll() async {
    if (kIsWeb) {
      for (var sub in _webDemoSubscriptions.values) {
        sub.cancel();
      }
      _webDemoSubscriptions.clear();
      await WebDemoVntManager.disconnect();
    } else {
      await vntManager.removeAll();
    }
  }
}
