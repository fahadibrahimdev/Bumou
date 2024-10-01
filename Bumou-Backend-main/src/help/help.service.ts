import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { NewHelpDto } from './dto';
import { PushNotificationService } from 'src/push-notification/push-notification.service';
import {
  NotificationPayloadDto,
  NotificationType,
} from 'src/push-notification/dto/notification-payload.dto';
import { ChatroomMessageType, HelpStatus, Prisma } from '@prisma/client';
import { HelpMessageRequestDto } from './dto/accept-help.dto';
import { ChatGateway } from 'src/chat/gateway/chat.gateway';
import { HelpChatService } from 'src/chat/service/help-chat.service';

@Injectable()
export class HelpService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notification: PushNotificationService,
    private readonly chatGateway: ChatGateway,
    private readonly helpChatService: HelpChatService,
  ) {}

  static expiresIn = 2 * 60 * 60 * 1000;

  async getMyPendingHelpRequests(userId: string) {
    const helps = await this.prisma.help.findMany({
      where: {
        requestedById: userId,
        status: HelpStatus.PENDING,
        createdAt: {
          gte: new Date(new Date().getTime() - HelpService.expiresIn),
        },
      },
      include: {
        requestedBy: true,
        helper: true,
        messages: {
          include: { sender: true },
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
      take: 1,
      orderBy: {
        createdAt: 'desc',
      },
    });
    return helps.length > 0 ? helps[0] : null;
  }

  async getOngoingHelp(userId: string) {
    const myHelp = await this.prisma.help.findMany({
      where: {
        OR: [
          {
            requestedById: userId,
          },
          {
            helperId: userId,
          },
        ],
        status: {
          in: [HelpStatus.ACCEPTED],
        },
      },
      include: {
        requestedBy: true,
        helper: true,
        messages: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
          include: {
            sender: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 50,
    });

    return myHelp;
  }

  async getIncomingRequests(userId: string) {
    // current time
    const currentTime = new Date();
    const help = await this.prisma.help.findMany({
      where: {
        requestedById: {
          not: userId,
        },
        status: HelpStatus.PENDING,
        createdAt: {
          gte: new Date(currentTime.getTime() - HelpService.expiresIn),
        },
      },
      include: {
        requestedBy: true,
        helper: true,
        messages: {
          include: { sender: true },
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
      take: 50,
      orderBy: {
        createdAt: 'desc',
      },
    });
    return help;
  }

  async askForHelp(id: string, payload: NewHelpDto) {
    console.log('payload', payload);

    const help = await this.prisma.help.create({
      data: {
        messages: {
          create: {
            message: payload.message,
            type: ChatroomMessageType.TEXT,
            sender: {
              connect: {
                id,
              },
            },
          },
        },
        requestedBy: {
          connect: {
            id,
          },
        },
      },
      include: {
        requestedBy: true,
        messages: {
          include: { sender: true },
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
    });

    const userIds = await this.prisma.user.findMany({
      where: {
        isHelping: true,
      },
      orderBy: {
        updatedAt: 'desc',
      },
      take: 500,
      select: {
        id: true,
      },
    });

    let enHelpMessage = payload.message;
    let zhHelpMessage = payload.message;
    if (!enHelpMessage) {
      enHelpMessage = 'Someone needs help!';
      zhHelpMessage = '有人需要帮助！';
    }

    const notificationPayload: any = {
      enHelpMessage,
      zhHelpMessage,
      ...help,
    };

    await this.notification.sendHelpNotification(
      notificationPayload,
      userIds.map((user) => user.id),
    );

    this.chatGateway.emitHelpRequest(help);

    return help;
  }

  async cancelHelp(id: string) {
    try {
      const help = await this.prisma.help.delete({
        where: {
          id,
          status: HelpStatus.PENDING,
        },
        include: {
          requestedBy: true,
          helper: true,
          messages: {
            include: { sender: true },
            orderBy: {
              createdAt: 'desc',
            },
            take: 1,
          },
        },
      });

      this.chatGateway.emitHelpRequestRemove(id);
      return {
        success: true,
        message: 'Help request cancelled',
        help,
      };
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2025') {
          throw new NotFoundException('找不到帮助请求');
        }
        throw new ForbiddenException(
          `Code: ${error.code}, Message: ${error.message}`,
        );
      }
      throw error;
    }
  }

  async acceptHelp(userId: string, helpId: string) {
    try {
      const help = await this.prisma.help.update({
        where: {
          id: helpId,
          status: HelpStatus.PENDING,
        },
        data: {
          status: HelpStatus.ACCEPTED,
          helper: {
            connect: {
              id: userId,
            },
          },
        },
      });

      this.chatGateway.emitHelpRequestRemove(helpId);

      const notificationPayload: NotificationPayloadDto = {
        userIds: [help.requestedById],
        type: NotificationType.HELP,
        content: '您的帮助请求已被接受',
        data: {
          type: NotificationType.HELP,
          message: '您的帮助请求已被接受',
          help,
        },
      };
      this.notification.sendPushNotification(notificationPayload);
      const message = await this.helpChatService.handleNewHelpMessage({
        message: '来这里帮忙！',
        helpId: helpId,
        senderId: userId,
        type: ChatroomMessageType.JOIN,
      });

      this.chatGateway.emitHelpMessage(message, [help.requestedById, userId]);

      return help;
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2025') {
          throw new NotFoundException('找不到帮助请求');
        }
        throw new ForbiddenException(
          `Code: ${error.code}, 信息: ${error.message}`,
        );
      }
      throw error;
    }
  }

  async deleteHelp(helpId: string) {
    return this.prisma.help.delete({ where: { id: helpId } });
  }

  async getHelpMessages(userId: string, helpId: string) {
    const helpMessages: any = await this.prisma.helpMessage.findMany({
      where: {
        helpId,
      },
      include: {
        sender: true,
      },
      take: 100,
      orderBy: {
        createdAt: 'desc',
      },
    });
    return helpMessages;
  }

  // async completeHelp(helpId: string) {
  //   throw new Error('Method not implemented.');
  // }

  // async getOngoingHelp(id: string) {
  //   const help = await this.prisma.help.findFirst({
  //     where: {
  //       OR: [
  //         {
  //           requestedById: id,
  //         },
  //         {
  //           helperId: id,
  //         },
  //       ],
  //       status: {
  //         in: [HelpStatus.PENDING, HelpStatus.ACCEPTED],
  //       },
  //     },
  //     include: {
  //       requestedBy: true,
  //       helper: true,
  //       messages: {
  //         orderBy: {
  //           createdAt: 'desc',
  //         },
  //         take: 50,
  //       },
  //     },
  //     orderBy: {
  //       createdAt: 'desc',
  //     },
  //   });
  //   if (!help) {
  //     return new NotFoundException('No ongoing help found');
  //   }
  //   return help;
  // }

  // async addNewHelpMessage(payload: HelpMessageRequestDto) {
  //   try {
  //     const help = await this.prisma.help.findUnique({
  //       where: {
  //         id: payload.helpId,
  //       },
  //     });
  //     if (!help) {
  //       return;
  //     }
  //     const message = await this.prisma.helpMessage.create({
  //       data: {
  //         message: payload.message,
  //         sender: {
  //           connect: {
  //             id: payload.senderId,
  //           },
  //         },
  //         help: {
  //           connect: {
  //             id: help.id,
  //           },
  //         },
  //       },
  //     });
  //     let userIds = [help.requestedById];
  //     if (help.helperId) {
  //       userIds.push(help.helperId);
  //     }

  //     this.chatGateway.emitHelpMessage(
  //       {
  //         type: NotificationType.HELP,
  //         message,
  //         help,
  //       },
  //       userIds,
  //     );

  //     // remove userid of sender
  //     userIds = userIds.filter((id) => id !== payload.senderId);

  //     const notificationPayload: NotificationPayloadDto = {
  //       userIds: userIds,
  //       type: NotificationType.HELP,
  //       content: payload.message,
  //       data: {
  //         type: NotificationType.HELP,
  //         message,
  //         help,
  //       },
  //     };

  //     this.notification.sendPushNotification(notificationPayload);

  //     return {
  //       help,
  //       message,
  //     };
  //   } catch (error) {}
  // }
}
