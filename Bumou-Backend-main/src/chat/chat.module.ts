import { Module } from '@nestjs/common';
import { AuthModule } from 'src/auth/auth.module';

import { UserModule } from 'src/user/user.module';
import { ChatService } from './service/chat.service';
import { UserConnectionService } from './service/user-connection.service';
import { MessageService } from './service/message.service';
import { ChatController } from './chat.controller';
import { WebSocketExceptionFilter } from './filter/websocket-exception.filter';
import { PushNotificationModule } from 'src/push-notification/push-notification.module';
import { ChatGateway } from './gateway/chat.gateway';
import { HelpChatService } from './service/help-chat.service';
import { HelpModule } from 'src/help/help.module';
import { SharedModule } from 'src/shared/shared.module';

@Module({
  imports: [
    AuthModule,
    UserModule,
    PushNotificationModule,
    HelpModule,
    SharedModule,
  ],
  controllers: [ChatController],
  providers: [
    ChatService,
    HelpChatService,
    UserConnectionService,
    MessageService,
    // WebSocketExceptionFilter,
    // ChatGateway,
  ],
  exports: [
    UserConnectionService,
    MessageService,
    ChatService,
    HelpChatService,
    // ChatGateway,
  ],
})
export class ChatModule {}
