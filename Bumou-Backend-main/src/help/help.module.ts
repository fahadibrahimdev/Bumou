import { Module } from '@nestjs/common';
import { HelpController } from './help.controller';
import { HelpService } from './help.service';
import { PushNotificationModule } from 'src/push-notification/push-notification.module';
import { AuthModule } from 'src/auth/auth.module';
import { UserModule } from 'src/user/user.module';
import { ChatModule } from 'src/chat/chat.module';
import { ChatGateway } from 'src/chat/gateway/chat.gateway';
import { MessageService } from 'src/chat/service/message.service';
import { HelpChatService } from 'src/chat/service/help-chat.service';
import { SharedModule } from 'src/shared/shared.module';

@Module({
  imports: [PushNotificationModule, AuthModule, UserModule, SharedModule],
  controllers: [HelpController],
  providers: [
    // ChatGateway,
    HelpService,
    MessageService,
    HelpChatService,
  ],
  exports: [HelpService],
})
export class HelpModule {}
