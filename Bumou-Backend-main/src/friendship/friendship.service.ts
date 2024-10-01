import { ForbiddenException, Injectable } from '@nestjs/common';
import { AddFriendDto, UpdateFriendshipDto } from './dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { FriendshipStatus, User } from '@prisma/client';
import { I18nContext, I18nService } from 'nestjs-i18n';
import { PushNotificationService } from 'src/push-notification/push-notification.service';
import { NotificationType } from 'src/push-notification/dto/notification-payload.dto';
import { UserService } from 'src/user/user.service';

@Injectable()
export class FriendshipService {
  constructor(
    private prisma: PrismaService,
    private readonly i18n: I18nService,
    private readonly pushNotificationService: PushNotificationService,
    private readonly userService: UserService,
  ) {}

  async removeFriend(user: User, friendId: string) {
    try {
      const friendship = await this.prisma.friendship.findFirst({
        where: {
          OR: [
            {
              user1Id: user.id,
              user2Id: friendId,
            },
            {
              user1Id: friendId,
              user2Id: user.id,
            },
          ],
        },
      });

      if (!friendship) {
        throw new ForbiddenException(
          this.i18n.translate('t.friendship_not_found', {
            lang: I18nContext.current().lang,
          }),
        );
      }

      await this.prisma.friendship.delete({
        where: {
          id: friendship.id,
        },
      });

      return {
        message: this.i18n.translate('t.friend_removed', {
          lang: I18nContext.current().lang,
        }),
      };
    } catch (error) {
      throw new Error(
        this.i18n.translate('t.friendship_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }
  }

  async getFriendships(userId: string) {
    const friendships = await this.prisma.friendship.findMany({
      where: {
        AND: [
          {
            OR: [{ user1Id: userId }, { user2Id: userId }],
          },
          { status: FriendshipStatus.ACCEPTED },
        ],
      },
      include: {
        user1: true,
        user2: true,
      },
    });

    const friendsData = friendships.map((friendship) => {
      const friendUser =
        userId === friendship.user1Id ? friendship.user2 : friendship.user1;
      delete friendUser.password;
      return { friendshipId: friendship.id, ...friendUser };
    });

    return friendsData;
  }

  async getPendingFriendship(userId: string) {
    const pendingFriendship = await this.prisma.friendship.findMany({
      where: {
        user2Id: userId,
        status: FriendshipStatus.PENDING,
      },
    });
    return pendingFriendship;
  }

  async acceptFriendship(user: User, request: UpdateFriendshipDto) {
    const friendship = await this.prisma.friendship.findFirst({
      where: {
        id: request.friendshipId,
        user2Id: user.id,
      },
    });

    if (!friendship) {
      throw new ForbiddenException(
        this.i18n.translate('t.friendship_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    if (friendship.status === FriendshipStatus.ACCEPTED) {
      throw new ForbiddenException(
        this.i18n.translate('t.friendship_already_accepted', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    if (request.status === FriendshipStatus.REJECTED) {
      await this.prisma.friendship.delete({
        where: {
          id: request.friendshipId,
        },
      });
      return {
        message: this.i18n.translate('t.friend_request_rejected_successfuly', {
          lang: I18nContext.current().lang,
        }),
      };
    }

    const updatedFriendship = await this.prisma.friendship.update({
      where: {
        id: request.friendshipId,
      },
      data: {
        status: FriendshipStatus.ACCEPTED,
      },
    });

    const user1 = await this.userService.getUserById(friendship.user1Id);

    this.pushNotificationService.sendPushNotification({
      userIds: [friendship.user1Id],
      title: this.i18n.translate('t.friend_request_accepted', {
        lang: user1.local || I18nContext.current().lang,
      }),
      subtitle: this.i18n.translate(
        user.firstName +
          ' ' +
          user.lastName +
          ' ' +
          't.friend_request_accepted',
        { lang: user1.local || I18nContext.current().lang },
      ),
      type: NotificationType.FRIENDSHIP,
      data: {
        userId: user.id,
      },
    });

    return updatedFriendship;
  }

  async addFriend(userData: User, addFriendDto: AddFriendDto) {
    const friendId = addFriendDto.userId;
    const friend = await this.prisma.user.findUnique({
      where: {
        id: friendId,
      },
    });

    if (!friend) {
      throw new ForbiddenException(
        this.i18n.translate('t.requested_user_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const friendship = await this.prisma.friendship.findFirst({
      where: {
        OR: [
          {
            user1Id: userData.id,
            user2Id: friendId,
          },
          {
            user1Id: friendId,
            user2Id: userData.id,
          },
        ],
      },
    });

    if (friendship) {
      if (friendship.status === FriendshipStatus.ACCEPTED) {
        throw new ForbiddenException(
          this.i18n.translate('t.friendship_already_exists', {
            lang: I18nContext.current().lang,
          }),
        );
      } else if (friendship.status === FriendshipStatus.PENDING) {
        throw new ForbiddenException(
          this.i18n.translate('t.friendship_request_already_sent', {
            lang: I18nContext.current().lang,
          }),
        );
      } else if (friendship.status === FriendshipStatus.REJECTED) {
        throw new ForbiddenException(
          this.i18n.translate('t.friendship_request_already_rejected', {
            lang: I18nContext.current().lang,
          }),
        );
      } else {
        throw new ForbiddenException(
          this.i18n.translate('t.unknown_friendship_status', {
            lang: I18nContext.current().lang,
          }),
        );
      }
    }
    const newFriendship = await this.prisma.friendship.create({
      data: {
        user1Id: userData.id,
        user2Id: friendId,
        status: FriendshipStatus.PENDING,
      },
    });

    this.pushNotificationService.sendPushNotification({
      userIds: [friendId],
      title: this.i18n.translate('t.new_friend_request', {
        lang: friend.local || I18nContext.current().lang,
      }),
      subtitle:
        userData.firstName +
        ' ' +
        userData.lastName +
        this.i18n.translate('t.has_sent_you_a_friend_request', {
          lang: friend.local || I18nContext.current().lang,
        }),
      type: NotificationType.FRIENDSHIP,
      data: {
        userId: userData.id,
      },
    });

    return newFriendship;
  }

  async getFriendSuggestions(user: User, page: number, pageSize: number) {
    const suggestedFriends = await this.prisma.user.findMany({
      where: {
        id: {
          not: user.id,
        },
        userType: user.userType,
        friends1: {
          none: {
            user2Id: user.id,
          },
        },
        friends2: {
          none: {
            user1Id: user.id,
          },
        },
      },
      orderBy: [{ updatedAt: 'desc' }],
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return suggestedFriends;
  }
}
