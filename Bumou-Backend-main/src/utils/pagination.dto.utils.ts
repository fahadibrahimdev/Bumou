import { Transform } from 'class-transformer';
import { IsNumber, IsOptional } from 'class-validator';

export class PaginationRequest {
  @Transform(({ value }) => Number(value))
  @IsNumber()
  @IsOptional()
  page: number = 0;

  @Transform(({ value }) => Number(value))
  @IsNumber()
  @IsOptional()
  size: number = 20;
}
