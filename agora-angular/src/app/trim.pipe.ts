import { Pipe, PipeTransform } from '@angular/core';
@Pipe({name: 'trim'})
export class TrimPipe implements PipeTransform {
  transform(value: string, leng = 80): string {
    if (value.length >= leng)
    {
      value = value.substring(0, leng)
      if(value[value.length-1] == " ") value = value.slice(0, value.length-1);
      value += "...";
    }
    return value;
  }
}
