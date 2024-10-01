import { ChatroomMessageStatus, ChatroomMessageType } from "@prisma/client";
import { IsNotEmpty, IsOptional, IsString, Matches } from "class-validator";

export class ChatMessageDto {

    @IsString()
    @IsOptional()
    id?: string;

    @IsString()
    @IsNotEmpty()
    receiverId?: string;


    @IsString()
    @IsNotEmpty()
    senderId?: string;

    @IsString()
    @IsNotEmpty()
    chatroomId?: string;

    @IsString()
    @IsNotEmpty()
    message: string;

    @Matches(/^(TEXT|IMAGE|VIDEO|AUDIO|VOICE|FILE)$/)
    type: ChatroomMessageType;

    @IsOptional()
    @Matches(/^(PENDING|SENT|DELIVERED|READ)$/)
    status: ChatroomMessageStatus;

    @IsOptional()
    file?: string;
}