import { IsNotEmpty, IsString, Matches } from 'class-validator';
import { UserType } from '../../enum';

export class LoginDto {
  @IsString()
  @IsNotEmpty()
  username: string;

  @IsString()
  @IsNotEmpty()
  password: string;

  @Matches(/^(STUDENT|ADULT)$/)
  userType: UserType;
}
