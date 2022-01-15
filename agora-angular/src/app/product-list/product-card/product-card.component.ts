import { Component, Input, OnInit } from '@angular/core';
import { faShoppingCart } from '@fortawesome/free-solid-svg-icons';
import { ProductShort as Product } from 'src/app/services/product.service';

@Component({
  selector: 'product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.scss']
})
export class ProductCardComponent implements OnInit {

  @Input() public product: Product = {productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''};
  @Input() public wide: boolean =  true;
  @Input() public sideScrollable: boolean = false;

  faShoppingCart = faShoppingCart;
  
  constructor() {   }

  ngOnInit(): void {
  }

}
