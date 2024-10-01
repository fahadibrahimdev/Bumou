import { Catch, ArgumentsHost } from '@nestjs/common';
import { BaseWsExceptionFilter, WsException } from '@nestjs/websockets';
// import { BaseWsExceptionFilter, WebSocketAdapter } from '@nestjs/platform-ws';

@Catch(WsException)
export class WebSocketExceptionFilter extends BaseWsExceptionFilter {
  catch(exception: WsException, host: ArgumentsHost) {
    const client = host.switchToWs().getClient();
    const status = 'error';
    const error = exception.getError();
    const name = exception.name;

    if (client) {
      client.send(JSON.stringify({ status, error, name }));
    }
  }
}
