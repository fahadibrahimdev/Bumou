import { OnModuleInit } from '@nestjs/common';
import {
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Socket, Server } from 'socket.io';
import { AuthService } from 'src/auth/auth.service';
import { UserService } from 'src/user/user.service';
import { CallDto, ChatMessageDto } from '../dto';
import { MessageService } from '../service/message.service';
import { PrismaService } from 'src/prisma/prisma.service';

import { PushNotificationService } from 'src/push-notification/push-notification.service';
import { HelpChatService } from '../service/help-chat.service';
import { HelpService } from 'src/help/help.service';
import { Prisma } from '@prisma/client';

@WebSocketGateway()
export class ChatGateway
  implements OnGatewayConnection, OnGatewayDisconnect, OnModuleInit
{
  @WebSocketServer()
  server: Server;

  constructor(
    private authService: AuthService,
    private messageService: MessageService,
    private prisma: PrismaService,
    private helpChatService: HelpChatService, // private helpService: HelpService,
  ) {}

  private static connectionEvent: string = 'connection';
  private static chatEvent: string = 'chat';
  private static newMessageEvent: string = 'new-message';
  private static helpRequestEvent: string = 'help-request';
  private static helpRequestRemoveEvent: string = 'help-request-remove';
  private static helpMessageEvent: string = 'help-message';

  async onModuleInit() {
    console.log('Socket server is running');
  }

  emitHelpRequest(payload: any) {
    this.server.emit(ChatGateway.helpRequestEvent, payload);
  }

  emitHelpRequestRemove(helpId: string) {
    this.server.emit(ChatGateway.helpRequestRemoveEvent, helpId);
  }

  emitHelpMessage(payload: any, userIds: string[]) {
    this.server.to(userIds).emit(ChatGateway.helpMessageEvent, payload);
  }

  async handleConnection(socket: Socket) {
    try {
      const decodedToken = await this.authService.verifyJwt(
        socket.handshake.headers.authorization,
      );
      const userId = decodedToken.sub;
      if (!userId) {
        throw new Error('Invalid User ID');
      }
      console.log('User: ' + userId + ' connected with ID: ' + socket.id);
      socket.join(userId);
      this.server
        .to(socket.id)
        .emit(ChatGateway.connectionEvent, { message: 'Connected' });
      this.addUserSession(socket.id, userId);

      console.log('Connected: ', socket.id);
    } catch (error) {
      console.log('Socket Connection Exception: ', error);
      this.server
        .to(socket.id)
        .emit(ChatGateway.connectionEvent, { error: error.message });
      socket.disconnect();
    }
  }

  async addUserSession(sessionId: string, userId: string) {
    try {
      await this.prisma.userSession.create({
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
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2002') {
          console.log('User is already online');
          return;
        }
      }
    }
  }

  async deleteUserSession(sessionId: string) {
    const session = await this.prisma.userSession.findFirst({
      where: { token: sessionId },
    });
    if (!session) {
      return;
    }
    await this.prisma.userSession.delete({ where: { id: session.id } });
    this.prisma.userSession
      .aggregate({
        where: {
          userId: session.userId,
        },
        _count: true,
      })
      .then((count) => {
        if (count._count === 0) {
          this.prisma.user.update({
            where: { id: session.userId },
            data: { isOnline: false },
          });
        }
      });

    return session;
  }

  async handleDisconnect(client: Socket) {
    try {
      const session = await this.deleteUserSession(client.id);
      if (session) {
        console.log('User Left with ID: ', session.userId);
        client.leave(session.userId);
      }
      this.server.to(client.id).emit('You have been disconnected');
      console.log('Diconnected: ', client.id);
    } catch (error) {
      console.log('Socket Disconnection Exception: ', error);
    }
  }

  @SubscribeMessage(ChatGateway.newMessageEvent)
  async handleMessage(client: Socket, message: ChatMessageDto) {
    if (!message) {
      return;
    }
    const success = true;
    client.emit('acknowledge', { success });

    const response = await this.messageService.onNewMessage(message);

    this.server
      .to([message.senderId, message.receiverId])
      .emit(ChatGateway.chatEvent, response);
  }

  @SubscribeMessage(ChatGateway.helpMessageEvent)
  async handleHelpMessage(client: Socket, payload: any) {
    try {
      if (
        !payload ||
        !payload.message ||
        !payload.senderId ||
        !payload.helpId
      ) {
        console.log('Invalid help message payload: ', payload);
        return;
      }
      const success = true;
      client.emit('acknowledge', { success });

      const response = await this.helpChatService.handleNewHelpMessage(payload);

      const senderId = response.help.helper.id;
      const receiverId = response.help.requestedBy.id;
      this.emitHelpMessage(response, [senderId, receiverId]);
    } catch (error) {
      console.log('Error handling help message: ', error);
    }
  }

  @SubscribeMessage(ChatGateway.helpRequestEvent)
  async handleHelpRequestEvent(client: Socket, @MessageBody() payload: any) {}

  @SubscribeMessage(ChatGateway.helpMessageEvent)
  async handleHelpMessageEvent(client: Socket, @MessageBody() payload: any) {}

  // //! Calling Events //TODO: Move to a separate gateway
  // @SubscribeMessage('newCall')
  // async handleMakeCall(client: Socket, @MessageBody() data: CallDto) {
  //   try {
  //     this.validateCallPayload(data);

  //     const callId = this.generateCallId(data.senderId, data.receiverId);

  //     this.server.to(data.receiverId).emit('newCall', data);
  //   } catch (error) {}
  // }

  // @SubscribeMessage('answerCall')
  // async handleAnswerCall(client: Socket, @MessageBody() data: CallDto) {
  //   try {
  //     this.validateCallPayload(data);

  //     const callId = this.generateCallId(data.senderId, data.receiverId);

  //     this.server.to(data.receiverId).emit('answerCall', data);
  //   } catch (error) {}
  // }

  // @SubscribeMessage('endCall')
  // async handleEndCall(client: Socket, @MessageBody() data: CallDto) {
  //   try {
  //     this.validateCallPayload(data);

  //     const callId = this.generateCallId(data.senderId, data.receiverId);

  //     this.server.to(data.receiverId).emit('endCall', data);
  //   } catch (error) {}
  // }

  // @SubscribeMessage('signal')
  // handleIceCandidate(client: Socket, @MessageBody() data: CallDto) {
  //   try {
  //     this.validateCallPayload(data);

  //     this.server.to(data.receiverId).emit('signal', data);
  //   } catch (error) {}
  // }

  // private generateCallId(callerId: string, receiverId: string) {
  //   const ids = [callerId, receiverId];
  //   ids.sort();
  //   return ids.join('_');
  // }

  // private validateCallPayload(data: CallDto) {
  //   if (
  //     !data ||
  //     !data.senderId ||
  //     !data.receiverId ||
  //     !data.payload ||
  //     !data.type
  //   ) {
  //     return data;
  //   } else {
  //     throw new Error('Invalid Call Payload');
  //   }
  // }
}
