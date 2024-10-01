import { UserType } from "@prisma/client";
import { IsEmail, IsNotEmpty, IsOptional, IsString, Length, Matches } from "class-validator";

export class UpdateUserDto {
    @Matches(/^(STUDENT|ADULT)$/)
    @IsOptional()
    userType?: UserType;

    @IsString()
    @IsOptional()
    firstName?: string;

    @IsString()
    @IsOptional()
    lastName?: string;

    @IsString()
    @IsOptional()
    username?: string;

    @IsString()
    @IsOptional()
    profilePicture?: string;


    // @IsEmail()
    // @IsOptional()
    // email?: string;

    @IsString()
    @IsOptional()
    phone?: string;

    @IsString()
    @IsOptional()
    address?: string;

    @IsString()
    @IsOptional()
    city?: string;

    @IsString()
    @IsOptional()
    state?: string;

    @IsString()
    @IsOptional()
    country?: string;

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