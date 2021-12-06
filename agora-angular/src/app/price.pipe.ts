import { Pipe, PipeTransform } from '@angular/core';

@Pipe({name: 'price'})
export class PricePipe implements PipeTransform {
  transform(value: number) {
    let price:string = value.toString();
    // if(price.length >= 4){
    //   price[price.length-3].
    // }
    return value.toString() + " Ft";
  }
}