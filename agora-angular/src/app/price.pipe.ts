import { Pipe, PipeTransform } from '@angular/core';

@Pipe({name: 'price'})
export class PricePipe implements PipeTransform {
  transform(value: number) {
    let price:string = value.toString();
    let length:number = price.length;
    price = price.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$& ');
    return price + " Ft";
  }
}