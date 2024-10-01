import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  Length,
  Matches,
} from 'class-validator';
import { UserType } from '../../enum';

export class RegisterDto {
  @Matches(/^(STUDENT|ADULT)$/)
  userType: UserType;

  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsString()
  @IsNotEmpty()
  username: string;

  @IsEmail()
  @IsOptional()
  email: string;

  @IsString()
  @IsNotEmpty()
  @Length(5, 20, { message: '密码必须介于 5 到 20 个字符之间' })
  password: string;

  @IsString()
  @IsNotEmpty()
  phone: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  city: string;

  @IsString()
  @IsOptional()
  state?: string;

  @IsString()
  @IsOptional()
  country: string;

  @IsString()
  @IsOptional()
  schoolName?: string;

  @IsString()
  @IsOptional()
  className?: string;

  @IsString()
  @IsOptional()
  teacherName?: string;

  @IsString()
  @IsOptional()
  local?: string;
}
