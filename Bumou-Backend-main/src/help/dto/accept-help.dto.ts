import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class HelpMessageRequestDto {
  @IsString()
  @IsNotEmpty()
  message: string;

  @IsString()
  @IsOptional()
  senderId: string;
}
