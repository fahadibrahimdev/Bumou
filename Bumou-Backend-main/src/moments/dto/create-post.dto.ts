import { MediaType } from "@prisma/client";
import { Type } from "class-transformer";
import { IsArray, IsBoolean, IsNotEmpty, IsOptional, IsString, Matches, ValidateNested } from "class-validator";

class MediaAttachmentDto {
    @IsString()
    @IsNotEmpty()
    @Matches(/^(IMAGE|VIDEO)$/)
    type: MediaType;

    @IsString()
    @IsNotEmpty()
    @Matches(/^(http|https):\/\/[^ "]+$/)
    url: string;
}

export class CreatePostDto {
    @IsString()
    @IsOptional()
    text?: string;

    @IsArray()
    @IsOptional()
    @ValidateNested({ each: true })
    @Type(() => MediaAttachmentDto)
    mediaAttachments?: MediaAttachmentDto[];

    @IsString()
    @IsOptional()
    mood?: string;

    @IsNotEmpty()
    @IsBoolean()
    isAnonymous: boolean;


}