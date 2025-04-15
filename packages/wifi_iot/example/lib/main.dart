import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi 连接 Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:  WiFiConnectPage(),
    );
  }
}

class WiFiConnectPage extends StatefulWidget {
  @override
  State<WiFiConnectPage> createState() => _WiFiConnectPageState();
}

class _WiFiConnectPageState extends State<WiFiConnectPage> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  String _connectionStatus = '';
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    setState(() {
      _hasPermissions = status.isGranted;
    });
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connectToWiFi() async {
    if (!_hasPermissions) {
      setState(() {
        _connectionStatus = '请授予位置权限';
      });
      await _requestPermissions();
      return;
    }

    if (_ssidController.text.isEmpty) {
      setState(() {
        _connectionStatus = '请输入 SSID';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectionStatus = '正在连接...';
    });

    try {
      final success = await WiFiForIoTPlugin.connect(
        _ssidController.text,
        password: _passwordController.text,
        security: NetworkSecurity.WPA2PSK,
      );

      setState(() {
        _connectionStatus = success ? '连接成功' : '连接失败';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '连接出错: $e';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi 连接'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_hasPermissions)
              const Text(
                '需要位置权限来扫描和连接 WiFi',
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'WiFi 名称 (SSID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'WiFi 密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConnecting ? null : _connectToWiFi,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isConnecting
                  ? const CircularProgressIndicator()
                  : const Text('连接'),
            ),
            const SizedBox(height: 16),
            Text(
              _connectionStatus,
              style: TextStyle(
                color: _connectionStatus.contains('成功')
                    ? Colors.green
                    : _connectionStatus.contains('失败') || _connectionStatus.contains('错误')
                        ? Colors.red
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
