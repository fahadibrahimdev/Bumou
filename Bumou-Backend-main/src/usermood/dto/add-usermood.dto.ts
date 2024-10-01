import { UserMoodType } from "@prisma/client";
import { IsNotEmpty, IsOptional, IsString, Matches } from "class-validator";

export class AddUsermoodDto {
    @IsString()
    @IsNotEmpty()
    @Matches(/^(VERYGOOD|GOOD|NEUTRAL|BAD|VERYBAD)$/)
    mood: UserMoodType;

    @IsString()
    @IsOptional()
    note?: string;
}