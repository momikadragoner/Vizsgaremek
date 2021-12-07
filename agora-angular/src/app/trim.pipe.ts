import { Pipe, PipeTransform } from '@angular/core';
@Pipe({name: 'trim'})
export class TrimPipe implements PipeTransform {
  transform(value: string, lenght = 80): string {
    let trimmed : string //= value.length < length ? value.substring(0, lenght - 3) + "..." : value + "---";
    if (value.length >= length) {
        return value.substring(0, lenght);
    }
    else{
        return value;
    }
  }
}