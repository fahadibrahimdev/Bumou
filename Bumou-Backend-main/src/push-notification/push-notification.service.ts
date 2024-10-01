import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { OneSignalService } from 'onesignal-api-client-nest';
import { NotificationByDeviceBuilder } from 'onesignal-api-client-core';
import {
  NotificationPayloadDto,
  NotificationType,
} from './dto/notification-payload.dto';
import { ChatMessageDto } from 'src/chat/dto';
import { UserService } from 'src/user/user.service';
import { ChatroomMessageType } from '@prisma/client';
import { I18nContext, I18nService } from 'nestjs-i18n';
import { log } from 'console';
import { response } from 'express';

@Injectable()
export class PushNotificationService {
  logger: Logger = new Logger('PushNotificationService');
  constructor(
    private readonly oneSignalService: OneSignalService,
    private readonly userService: UserService,
    private readonly i18n: I18nService,
  ) {}

  async sendPushNotification(payload: NotificationPayloadDto) {
    try {
      const type = payload.type || NotificationType.GENERAL;

      const tokens: string[] = [];

      for (let j = 0; j < payload.userIds.length; j++) {
        const t = await this.userService.getDeviceTokens(payload.userIds[j]);

        for (let i = 0; i < t.length; i++) {
          tokens.push(t[i]);
        }
      }

      this.logger.debug('Tokens found :: ' + JSON.stringify(tokens));
      this.logger.debug('USER_IDS :: ' + JSON.stringify(payload.userIds));

      if (tokens.length == 0) {
        this.logger.debug('NO TOKEN FOUND');
      } else {
        const data = {
          to: tokens,
          data: {
            subtitle: payload.subtitle,
            type: type,
            title: payload.title,
            content: payload.content,
            data: JSON.stringify(payload.data),
          },
          notification: {
            title: payload.title,
            body: payload.content,
          },
        };
        const response = await fetch(
          'https://api.pushy.me/push?api_key=c077de68546762924b2a0bacaad605054815f5799cb0384042ae6eb1e83b5ab7',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
          },
        );

        this.logger.debug(
          'API RESPONSE ---> ' + tokens + '-->' + (await response.text()),
        );

        // await this.oneSignalService.createNotification(input);
      }
      this.logger.debug(
        '---------------------------------------------------------------',
      );
      this.logger.debug('User IDs: ' + payload.userIds);
      this.logger.debug('Type: ' + payload.type);
      this.logger.debug('Title: ' + payload.title);
      this.logger.debug('Subtitle: ' + payload.subtitle);
      this.logger.debug('Content: ' + payload.content);
      this.logger.debug(
        '---------------------------------------------------------------',
      );
    } catch (error) {
      this.logger.error('Error in sending notification' + error);
    }
  }

  async sendHelpNotification(data: any, userIds: any) {
    try {
      const type = NotificationType.HELP;
      const input = new NotificationByDeviceBuilder()
        .setIncludeExternalUserIds(userIds)
        .notification()
        .setHeadings({ en: '🚨 I need help', zh: '🚨 我需要帮助' })
        .setContents({ en: data.enHelpMessage, zh: data.zhHelpMessage })
        .setContentAvailable(data.enHelpMessage !== null)
        .setPlatform({ isIos: true, isAndroid: true })
        .setAppearance({
          ios_badgeCount: +1,
          apns_alert: {
            body: data.message,
          },
          android_visibility: 1,
          android_led_color: 'FF0000FF',
        })
        .setPlatform({ isIos: true, isAndroid: true })
        .setAttachments({ data: { type, ...data } })
        .setDelivery({ ttl: 3600, priority: 10 })
        .build();

      const resutl = await this.oneSignalService.createNotification(input);
      console.log('help notification resutl: ', resutl);
      return resutl;
    } catch (error) {
      this.logger.error('Error in sending help notification');
    }
  }

  async cancelNotification(notificationId: any) {
    try {
      const result = await this.oneSignalService.cancelNotification({
        id: notificationId,
      });

      return result;
    } catch (error) {
      this.logger.error('Error in canceling notification');
    }
  }

  async sendMessageNotification(chatMessage: ChatMessageDto) {
    const notificationPayload: NotificationPayloadDto = {
      userIds: [chatMessage.receiverId],
      type: NotificationType.MESSAGE,
      content: chatMessage.message,
    };
    const users = await this.userService.getUsersByIds([
      chatMessage.senderId,
      chatMessage.receiverId,
    ]);
    for (let i = 0; i < users.length; i++) {
      if (users[i].id === chatMessage.senderId) {
        notificationPayload.title = `${users[i].firstName} ${users[i].lastName}`;
        break;
      }
    }

    const local: string = users[1].local || 'en_US';
    if (chatMessage.type !== ChatroomMessageType.TEXT) {
      if (chatMessage.type === ChatroomMessageType.IMAGE) {
        notificationPayload.content = this.i18n.translate('t.sent_a_photo', {
          lang: local,
        });
      } else if (chatMessage.type === ChatroomMessageType.VIDEO) {
        notificationPayload.content = this.i18n.translate('t.sent_a_video', {
          lang: local,
        });
      } else if (chatMessage.type === ChatroomMessageType.AUDIO) {
        notificationPayload.content = this.i18n.translate('t.sent_an_audio', {
          lang: local,
        });
      } else if (chatMessage.type === ChatroomMessageType.VOICE) {
        notificationPayload.content = this.i18n.translate(
          't.sent_a_voice_message',
          { lang: local },
        );
      } else if (chatMessage.type === ChatroomMessageType.FILE) {
        notificationPayload.content = this.i18n.translate('t.sent_a_file', {
          lang: local,
        });
      } else {
        notificationPayload.content = this.i18n.translate('t.sent_a_message', {
          lang: local,
        });
      }
    }
    if (notificationPayload.content.length > 80) {
      notificationPayload.content =
        notificationPayload.content.substring(0, 80) + '...';
    }

    if (notificationPayload.data == null) {
      notificationPayload.data = {
        sender: chatMessage.senderId,
      };
    } else {
      notificationPayload.data = {
        ...notificationPayload.data,
        sender: chatMessage.senderId,
      };
    }

    await this.sendPushNotification(notificationPayload);
  }
}
