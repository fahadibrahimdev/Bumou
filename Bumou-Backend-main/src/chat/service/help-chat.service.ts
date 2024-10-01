import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ChatroomMessageStatus, Prisma } from '@prisma/client';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class HelpChatService {
  constructor(private readonly prisma: PrismaService) {}

  async handleNewHelpMessage(payload: any) {
    console.log('Help message received: ', payload);
    try {
      const message = await this.prisma.helpMessage.create({
        data: {
          message: payload.message,
          helpId: payload.helpId,
          senderId: payload.senderId,
          status: ChatroomMessageStatus.SENT,
          type: payload.type,
          locationLat: payload.locationLat,
          locationLng: payload.locationLng,
        },
        include: {
          sender: true,
          help: {
            include: {
              requestedBy: true,
              helper: true,
            },
          },
        },
      });
      return message;
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2025') {
          throw new NotFoundException('Help request not found');
        }
        throw new ForbiddenException(
          `Code: ${error.code}, Message: ${error.message}`,
        );
      }
      throw error;
    }
  }
}
