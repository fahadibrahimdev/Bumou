import { Controller, Post, Query, UseGuards } from '@nestjs/common';
import { JwtGuard } from 'src/auth/guard';
import { PushNotificationService } from './push-notification.service';
import { GetUser } from 'src/decorator';
import {
  NotificationPayloadDto,
  NotificationType,
} from './dto/notification-payload.dto';

@UseGuards(JwtGuard)
@Controller('push-notification')
export class PushNotificationController {
  constructor(private pushNotificationService: PushNotificationService) {}

  @Post('/send')
  async sendPushNotification(
    @GetUser('id') userId: string,
    @Query('message') message: string,
    @Query('email') email: string,
  ) {
    const notificationPayload: NotificationPayloadDto = {
      userIds: [userId],
      title: 'Test',
      subtitle: message,
      content: message,
      type: NotificationType.GENERAL,
      data: {
        email: email,
      },
    };
    return await this.pushNotificationService.sendPushNotification(
      notificationPayload,
    );
  }
}
