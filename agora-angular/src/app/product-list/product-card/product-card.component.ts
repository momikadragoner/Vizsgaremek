import { Component, Input, OnInit } from '@angular/core';
import { faShoppingCart } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.scss']
})
export class ProductCardComponent implements OnInit {

  @Input() public name: string = "";
  @Input() public seller: string =  "";
  @Input() public price: number = 0;
  @Input() public imgUrl: string =  "";

  faShoppingCart = faShoppingCart;
  
  constructor() {   }

  ngOnInit(): void {
  }

}
