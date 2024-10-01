import { FriendshipStatus } from "@prisma/client";
import { IsNotEmpty, IsString, Matches } from "class-validator";

export class UpdateFriendshipDto {
    @IsString()
    @IsNotEmpty()
    friendshipId: string;

    @Matches(/^(ACCEPTED|REJECTED)$/)
    status: FriendshipStatus;
}