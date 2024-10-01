import { Module } from '@nestjs/common';
import { PushNotificationController } from './push-notification.controller';
import { PushNotificationService } from './push-notification.service';
import { OneSignalModule } from 'onesignal-api-client-nest';
import { UserModule } from 'src/user/user.module';

@Module({
  imports: [
    OneSignalModule.forRoot({
      appId: 'd7785c40-cb60-4c08-bf09-d64a59dc0066',
      restApiKey: 'NjY1NmY3NWMtY2MwMC00YzQ0LThkMzItZTcyOTk4NjRlMDFj',
    }),
    UserModule,
  ],
  controllers: [PushNotificationController],
  providers: [PushNotificationService],
  exports: [PushNotificationService],
})
export class PushNotificationModule {}
