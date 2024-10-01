import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { ChatMessageDto } from '../dto';
import {
  Chatroom,
  ChatroomMessage,
  ChatroomMessageType,
  User,
} from '@prisma/client';
import { PushNotificationService } from 'src/push-notification/push-notification.service';
import { NotificationPayloadDto } from 'src/push-notification/dto/notification-payload.dto';
import { I18nContext, logger } from 'nestjs-i18n';

@Injectable()
export class MessageService {
  i18n: any;
  constructor(
    private prisma: PrismaService,
    private readonly pushNotificationService: PushNotificationService,
  ) {}

  async onNewMessage(message: ChatMessageDto) {
    let chatroomId = message.chatroomId;
    if (!chatroomId) {
      chatroomId = [message.receiverId, message.senderId].sort().join('_');
    }
    let chatroom: any = await this.getChatRoomById(
      chatroomId,
      message.senderId,
    );

    let lastMessage: string = message.message;

    if (message.type == ChatroomMessageType.TEXT) {
      lastMessage = message.message;
    } else {
      lastMessage = `*${message.type}*`;
    }

    if (!chatroom) {
      chatroom = await this.prisma.chatroom.create({
        data: {
          id: chatroomId,
          lastMessage: lastMessage,
          name: 'Private',
          members: {
            connect: [{ id: message.senderId }, { id: message.receiverId }],
          },
          messages: {
            create: {
              message: message.message,
              type: message.type,
              status: message.status,
              senderId: message.senderId,
              file: message.file,
              readBy: {
                create: {
                  userId: message.senderId,
                  chatroomId: message.chatroomId,
                },
              },
            },
          },
        },
        include: {
          members: true,
          messages: {
            orderBy: {
              createdAt: 'desc',
            },
            take: 1,
            include: {
              readBy: {
                where: {
                  userId: message.senderId,
                },
              },
            },
          },
        },
      });

      chatroom = { ...chatroom, unreadCount: 1 };
    } else {
      chatroom = await this.prisma.chatroom.update({
        where: {
          id: chatroomId,
        },
        data: {
          lastMessage: lastMessage,
          messages: {
            create: {
              message: message.message,
              type: message.type,
              status: message.status,
              senderId: message.senderId,
              file: message.file,
              readBy: {
                create: {
                  userId: message.senderId,
                  chatroomId: message.chatroomId,
                },
              },
            },
          },
        },
        include: {
          members: true,
          messages: {
            orderBy: {
              createdAt: 'desc',
            },
            take: 1,
            include: {
              readBy: {
                where: {
                  userId: message.senderId,
                },
              },
            },
          },
        },
      });

      /// Refresh User
      chatroom = await this.prisma.chatroom.findUnique({
        where: { id: chatroomId },
        include: {
          members: true,
          messages: {
            orderBy: {
              createdAt: 'desc',
            },
            take: 1,
            include: {
              readBy: {
                where: {
                  userId: message.senderId,
                },
              },
            },
          },
          _count: {
            select: {
              messages: {
                where: {
                  readBy: {
                    none: {
                      userId: message.receiverId,
                    },
                  },
                },
              },
            },
          },
        },
      });

      chatroom = { ...chatroom, unreadCount: chatroom._count?.messages };
    }

    this.pushNotificationService.sendMessageNotification(message);

    logger.debug('CHATROOM ' + chatroom);

    return {
      chatroom: chatroom,
      message: chatroom.messages[0],
    };
  }

  async getMessages(
    chatroomId: string,
    userId: string,
    page: number,
    pageSize: number,
  ) {
    return this.prisma.chatroomMessage.findMany({
      where: { chatroomId: chatroomId },
      include: {
        readBy: {
          where: { userId: userId },
        },
      },
      skip: page * pageSize,
      take: pageSize,
      orderBy: { createdAt: 'desc' },
    });
  }

  async deleteChatRoom(chatroomId: string) {
    const chartRoom = await this.prisma.chatroom.findUnique({
      where: { id: chatroomId },
    });
    if (!chartRoom) {
      throw new ForbiddenException(
        this.i18n.translate('t.chatroom_not_found_with_the_given_id', {
          lang: I18nContext.current().lang,
        }) + chatroomId,
      );
    }

    const chatRoomReadStatus = this.prisma.chatroomReadStatus.deleteMany({
      where: { chatroom: chartRoom },
    });
    const deleteChatRoom = this.prisma.chatroom.delete({
      where: { id: chatroomId },
    });

    return this.prisma.$transaction([chatRoomReadStatus, deleteChatRoom]);
  }

  async getChatRoomsByUser(userId: string, page: number, pageSize: number) {
    logger.debug('Fetching chatroom for ::  ' + userId);
    const chatRooms = await this.prisma.chatroom.findMany({
      where: {
        members: {
          some: {
            id: userId,
          },
        },
      },
      skip: page * pageSize,
      take: pageSize,
      orderBy: {
        updatedAt: 'desc',
      },
      // Include 'members' except the current user
      include: {
        members: {
          where: {
            id: {
              not: userId,
            },
          },
        },
        messages: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
          include: {
            readBy: {
              where: {
                userId,
              },
            },
          },
        },
        // Include the count of messages that have not been read by the current user
        _count: {
          select: {
            messages: {
              where: {
                readBy: {
                  none: {
                    userId: userId,
                  },
                },
              },
            },
          },
        },
      },
    });

    // Map the results to include the unread count and remove the `_count` wrapping
    const chatroomWithUnreadCount = chatRooms.map((chatroom) => {
      logger.debug('CHATROOM UNREAD COUNT :: ' + chatroom._count);

      return {
        ...chatroom,
        unreadCount: chatroom._count?.messages,
      };
    });

    return chatroomWithUnreadCount;
  }

  async getChatRoomById(chatroomId: string, userId: string) {
    return this.prisma.chatroom.findUnique({
      where: { id: chatroomId },
      include: {
        members: true,
        messages: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
        _count: {
          select: {
            messages: {
              where: {
                readBy: {
                  none: {
                    userId,
                  },
                },
              },
            },
          },
        },
      },
    });
  }
}
