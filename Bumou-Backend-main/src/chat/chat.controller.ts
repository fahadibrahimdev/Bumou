import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Delete,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guard';
import { GetUser } from 'src/decorator';
import { MessageService } from './service/message.service';
import { ChatService } from './service/chat.service';

@UseGuards(JwtGuard)
@Controller('chat')
export class ChatController {
  constructor(
    private messageService: MessageService,
    private readonly chatService: ChatService,
  ) {}

  @Get('chatrooms')
  async getChatRooms(
    @GetUser('id') userId: string,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,
  ) {
    return this.messageService.getChatRoomsByUser(userId, page, pageSize);
  }

  @Delete('chatrooms/:chatroomId')
  async deleteChatRoom(@Param('chatroomId') chatroomId: string) {
    return this.messageService.deleteChatRoom(chatroomId);
  }

  @Get('messages/:chatroomId')
  async getMessages(
    @Param('chatroomId') chatroomId: string,
    @GetUser('id') userId: string,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,
  ) {
    return this.messageService.getMessages(chatroomId, userId, page, pageSize);
  }

  @Put('mark-read/:chatroomId/:messageId')
  async markMessageAsRead(
    @GetUser('id') userId: string,
    @Param('messageId') messageId: string,
    @Param('chatroomId') chatroomId: string,
  ) {
    return this.chatService.markMessageAsRead(userId, messageId, chatroomId);
  }
}
