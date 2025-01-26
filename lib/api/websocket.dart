// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// final videoTransferSocketProvider = Provider.autoDispose<VideoTransferSocket>((ref) {
//   ref.onDispose(() {
//     print("VideoTransferSocket disposed");
//   });
//   ref.onCancel(() {
//     print("VideoTransferSocket cancelled");
//   });
//   ref.onDispose(() {
//     print("VideoTransferSocket resumed");
//   });
//   ref.onAddListener(() {
//     print("VideoTransferSocket added");
//   });
//   ref.onRemoveListener(() {
//     print("VideoTransferSocket removed");
//   });
//
//   return VideoTransferSocket();
// });
//
// class VideoTransferSocket {
//   final url = "wss://fuckyourass";
//
//   VideoTransferSocket() {
//     print("Websocket created");
//   }
//
//   WebSocketChannel connect() {
//     return WebSocketChannel.connect(Uri.parse(url));
//   }
//
//
// }
