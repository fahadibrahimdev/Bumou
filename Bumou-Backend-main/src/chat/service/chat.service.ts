import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async markMessageAsRead(
    userId: string,
    messageId: string,
    chatroomId: string,
  ) {
    let existingStatus = await this.prisma.chatroomReadStatus.findFirst({
      where: {
        userId,
        messageId,
        chatroomId,
      },
    });

    if (existingStatus) {
      throw new ForbiddenException('Message already read');
    }
    existingStatus = await this.prisma.chatroomReadStatus.create({
      data: {
        userId,
        messageId,
        chatroomId,
      },
    });

    return existingStatus;
  }
}
