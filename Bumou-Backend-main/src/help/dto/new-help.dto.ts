import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class NewHelpDto {
  @IsString()
  @IsNotEmpty()
  message!: string;
}
