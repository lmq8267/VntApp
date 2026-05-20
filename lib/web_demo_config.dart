// Web Demo Mode - 模拟VPN连接，无需真实后端
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

const bool kIsWebDemo = kIsWeb;

class DemoModeConfig {
  static final _rng = Random();
  static bool get isEnabled => kIsWebDemo;
  
  // 模拟连接延迟
  static const Duration connectDelay = Duration(milliseconds: 800);
  
  // 当前连接的配置
  static String? _connectedConfigKey;
  static String? get connectedConfigKey => _connectedConfigKey;
  static void setConnected(String? key) => _connectedConfigKey = key;
  
  // 模拟配置列表
  static const List<Map<String, dynamic>> mockConfigs = [
    {
      'itemKey': 'demo-config-1',
      'configName': 'Demo Network 1',
      'serverAddress': 'demo.vnt.example.com:29872',
      'deviceName': 'My Device',
      'virtualIPv4': '10.26.0.100',
    },
    {
      'itemKey': 'demo-config-2',
      'configName': 'Demo Network 2',
      'serverAddress': 'demo2.vnt.example.com:29872',
      'deviceName': 'My Device 2',
      'virtualIPv4': '10.26.1.100',
    },
  ];
  
  // 模拟设备列表（房间页面）
  static List<Map<String, dynamic>> getMockDevices() {
    return [
      {
        'name': 'Device-001',
        'ip': '10.26.0.2',
        'virtualIp': '10.26.0.2',
        'latency': 15 + _rng.nextInt(10),
        'status': 'online',
        'natType': 'Symmetric',
        'publicIps': ['203.0.113.1:12345'],
        'localIpv4': '192.168.1.100',
        'upStream': '${_rng.nextInt(100) + 50} KB',
        'downStream': '${_rng.nextInt(200) + 100} KB',
      },
      {
        'name': 'Device-002',
        'ip': '10.26.0.3',
        'virtualIp': '10.26.0.3',
        'latency': 23 + _rng.nextInt(15),
        'status': 'online',
        'natType': 'FullCone',
        'publicIps': ['203.0.113.2:54321'],
        'localIpv4': '192.168.1.101',
        'upStream': '${_rng.nextInt(80) + 30} KB',
        'downStream': '${_rng.nextInt(150) + 80} KB',
      },
      {
        'name': 'Device-003',
        'ip': '10.26.0.4',
        'virtualIp': '10.26.0.4',
        'latency': 0,
        'status': 'offline',
        'natType': 'Unknown',
        'publicIps': [],
        'localIpv4': '',
        'upStream': '0 B',
        'downStream': '0 B',
      },
      {
        'name': 'Device-004',
        'ip': '10.26.0.5',
        'virtualIp': '10.26.0.5',
        'latency': 12 + _rng.nextInt(8),
        'status': 'online',
        'natType': 'Restricted',
        'publicIps': ['203.0.113.3:33333'],
        'localIpv4': '192.168.1.102',
        'upStream': '${_rng.nextInt(120) + 60} KB',
        'downStream': '${_rng.nextInt(250) + 150} KB',
      },
    ];
  }
  
  // 模拟路由表
  static List<Map<String, dynamic>> getMockRoutes() {
    return [
      {
        'destination': '10.26.0.0/24',
        'gateway': '10.26.0.1',
        'metric': 0,
      },
      {
        'destination': '192.168.1.0/24',
        'gateway': '10.26.0.2',
        'metric': 1,
      },
    ];
  }
  
  // 模拟流量数据
  static int _uploadBytes = 0;
  static int _downloadBytes = 0;
  static int _lastUpdate = DateTime.now().millisecondsSinceEpoch;
  
  static void simulateTraffic() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = (now - _lastUpdate) / 1000.0; // 秒
    _lastUpdate = now;
    
    // 模拟随机流量：上传 10-100 KB/s，下载 50-500 KB/s
    final uploadSpeed = 10000 + _rng.nextInt(90) * 1000;
    final downloadSpeed = 50000 + _rng.nextInt(450) * 1000;
    
    _uploadBytes += (uploadSpeed * elapsed).toInt();
    _downloadBytes += (downloadSpeed * elapsed).toInt();
  }
  
  static int get uploadBytes => _uploadBytes;
  static int get downloadBytes => _downloadBytes;
  
  static void reset() {
    _uploadBytes = 0;
    _downloadBytes = 0;
    _lastUpdate = DateTime.now().millisecondsSinceEpoch;
    _connectedConfigKey = null;
  }
  
  // 模拟当前设备信息
  static Map<String, dynamic> getCurrentDeviceInfo(String virtualIp) {
    return {
      'virtualIp': virtualIp,
      'virtualNetmask': '255.255.255.0',
      'virtualGateway': '10.26.0.1',
      'virtualNetwork': '10.26.0.0/24',
      'broadcastIp': '10.26.0.255',
      'connectServer': 'demo.vnt.example.com:29872',
      'status': 'online',
      'publicIps': ['203.0.113.100:${20000 + DateTime.now().second}'],
      'natType': 'Symmetric',
      'localIpv4': '192.168.1.${100 + DateTime.now().second % 50}',
      'ipv6': '',
    };
  }
}


