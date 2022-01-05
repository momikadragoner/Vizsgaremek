import { Component, OnInit } from '@angular/core';
import { Product, productListShort } from "../model/product";
import { faShoppingCart, faChevronRight, faTrash, faHeart } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-cart',
  templateUrl: './cart.component.html',
  styleUrls: ['./cart.component.scss']
})
export class CartComponent implements OnInit {

  productListShort = productListShort;
  faChevronRight = faChevronRight;
  faTrash = faTrash;
  faHeart = faHeart;

  constructor() { }

  ngOnInit(): void {
  }

}
