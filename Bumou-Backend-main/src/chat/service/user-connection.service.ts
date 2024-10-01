import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class UserConnectionService {
  constructor(private prisma: PrismaService) {}
  logger: Logger = new Logger('UserConnectionService');

  async addSession(sessionId: string, userId: string) {
    this.logger.debug(`Adding session for user ${userId} with id ${sessionId}`);
    try {
      const session = await this.prisma.userSession.create({
        data: {
          id: sessionId.toString(),
          token: sessionId,
          userId,
        },
      });

      await this.prisma.user.update({
        where: { id: userId },
        data: { isOnline: true },
      });
      return session;
    } catch (error) {
      this.logger.debug(error);
    }
  }

  async getAllSessions(userId: string) {
    const sessions = await this.prisma.userSession.findMany({
      where: { userId },
    });
    return sessions;
  }

  async deleteSession(sessionId: string) {
    const session = await this.prisma.userSession.findFirst({
      where: { token: sessionId },
    });
    if (!session) {
      return;
    }
    await this.prisma.userSession.delete({ where: { id: session.id } });
    await this.prisma.user.update({
      where: { id: session.userId },
      data: { isOnline: false },
    });
    return session;
  }
}
