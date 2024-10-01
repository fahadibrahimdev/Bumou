import { Module } from '@nestjs/common';
import { FriendshipController } from './friendship.controller';
import { FriendshipService } from './friendship.service';
import { PushNotificationModule } from 'src/push-notification/push-notification.module';
import { UserModule } from 'src/user/user.module';

@Module({
  imports: [PushNotificationModule, UserModule],
  controllers: [FriendshipController],
  providers: [FriendshipService],
})
export class FriendshipModule { }
