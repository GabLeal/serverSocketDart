import 'dart:io';
import 'package:socket_io/socket_io.dart';

import 'socket_event.dart';

void main(List<String> arguments) {
  final server = Server();

  server.on('connection', (client) {
    print('cliente connectado');
    onConnection(client);
  });

  server.listen(Platform.environment['PORT'] ?? 3000);
}

void onConnection(Socket socket) {
  socket.on(
    'enter_room',
    (data) {
      final name = data['name'];
      final room = data['room'];

      print(data.toString());

      // apenas um grupo de socketes convercem
      socket.join(room);

      //o .TO evite uma mensagem e o brodcast emite a mensagem apra todos menos para o proprio cliente que emitiu a mensagem
      socket.to(room).broadcast.emit(
            'message',
            SocketEvent(
              name: name,
              room: room,
              type: SocketEventType.enter_room,
            ).toJson(),
          );

      socket.on('disconnect', (data) {
        socket.to(room).broadcast.emit(
              'message',
              SocketEvent(
                name: name,
                room: room,
                type: SocketEventType.leave_room,
              ).toJson(),
            );
      });

      socket.on('message', (json) {
        socket.to(name).broadcast.emit('message', json);
      });
    },
  );
}
