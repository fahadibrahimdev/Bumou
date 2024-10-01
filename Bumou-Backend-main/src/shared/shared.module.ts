import { forwardRef, Module } from '@nestjs/common';
import { AuthModule } from 'src/auth/auth.module';
import { ChatModule } from 'src/chat/chat.module';
import { WebSocketExceptionFilter } from 'src/chat/filter/websocket-exception.filter';
import { ChatGateway } from 'src/chat/gateway/chat.gateway';

@Module({
  imports: [AuthModule, forwardRef(() => ChatModule)],
  providers: [ChatGateway, WebSocketExceptionFilter],
  exports: [ChatGateway],
})
export class SharedModule {}
