import 'package:flutter/foundation.dart';
import 'package:vnt_app/network_config.dart';
import 'package:vnt_app/web_demo_config.dart';

/// Web Demo 模式的数据持久化
/// 使用内存存储，模拟真实的增删改查
class WebDemoPersistence {
  static final List<NetworkConfig> _configs = [];
  static bool _initialized = false;
  
  /// 初始化默认配置
  static void _initDefaults() {
    if (_initialized) return;
    _initialized = true;
    
    // 添加两个示例配置
    for (var mockConfig in DemoModeConfig.mockConfigs) {
      _configs.add(NetworkConfig(
        itemKey: mockConfig['itemKey'] as String,
        configName: mockConfig['configName'] as String,
        token: 'demo-token-${mockConfig['itemKey']}',
        deviceName: mockConfig['deviceName'] as String,
        virtualIPv4: mockConfig['virtualIPv4'] as String,
        serverAddress: mockConfig['serverAddress'] as String,
        stunServers: ['stun.demo.com:3478'],
        inIps: [],
        outIps: [],
        portMappings: [],
        groupPassword: '',
        isServerEncrypted: true,
        protocol: 'udp',
        dataFingerprintVerification: true,
        encryptionAlgorithm: 'aes_gcm',
        deviceID: 'demo-device-${mockConfig['itemKey']}',
        virtualNetworkCardName: '',
        mtu: 1400,
        ports: [],
        firstLatency: true,
        noInIpProxy: false,
        dns: [],
        simulatedPacketLossRate: 0,
        simulatedLatency: 0,
        punchModel: 'all',
        useChannelType: 'all',
        compressor: 'lz4',
        allowWg: false,
        localDev: '',
        disableRelay: false,
      ));
    }
  }
  
  /// 加载所有配置
  static Future<List<NetworkConfig>> loadConfigs() async {
    if (!kIsWeb) return [];
    _initDefaults();
    await Future.delayed(const Duration(milliseconds: 100)); // 模拟异步
    return List.from(_configs);
  }
  
  /// 保存配置
  static Future<void> saveConfig(NetworkConfig config) async {
    if (!kIsWeb) return;
    await Future.delayed(const Duration(milliseconds: 50));
    
    final index = _configs.indexWhere((c) => c.itemKey == config.itemKey);
    if (index >= 0) {
      _configs[index] = config;
    } else {
      _configs.add(config);
    }
  }
  
  /// 删除配置
  static Future<void> deleteConfig(String itemKey) async {
    if (!kIsWeb) return;
    await Future.delayed(const Duration(milliseconds: 50));
    _configs.removeWhere((c) => c.itemKey == itemKey);
  }
  
  /// 获取单个配置
  static Future<NetworkConfig?> getConfig(String itemKey) async {
    if (!kIsWeb) return null;
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _configs.firstWhere((c) => c.itemKey == itemKey);
    } catch (e) {
      return null;
    }
  }
  
  /// 清空所有配置
  static Future<void> clearAll() async {
    if (!kIsWeb) return;
    _configs.clear();
    _initialized = false;
  }
}
