import 'dart:async';
import 'dart:io';
import 'package:stream_channel/stream_channel.dart';

class WebSocketChannelAdapter extends StreamChannelMixin<List<int>> {
  final WebSocket _webSocket;
  final StreamController<List<int>> _controller = StreamController();

  WebSocketChannelAdapter(this._webSocket) {
    _webSocket.listen((data) {
      if (!_controller.isClosed) {
        if (data is String) {
          print("Received string data: $data");
          _controller.add(data.codeUnits);
        } else if (data is List<int>) {
          print("Received binary data: $data");
          _controller.add(data);
        }
      }
    }, onDone: () {
      if (!_controller.isClosed) {
        print("WebSocket done");
        _controller.close();
      }
    }, onError: (error) {
      if (!_controller.isClosed) {
        print("WebSocket error: $error");
        _controller.addError(error);
        _controller.close();
      }
    });
  }

  @override
  Stream<List<int>> get stream => _controller.stream;

  @override
  StreamSink<List<int>> get sink => _controller.sink;
}
