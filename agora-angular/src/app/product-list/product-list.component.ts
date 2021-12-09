import { Component, Input, OnInit } from '@angular/core';
import { faShoppingCart } from '@fortawesome/free-solid-svg-icons';
import { Product } from '../model/product';

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.scss']
})
export class ProductListComponent implements OnInit {

  @Input() public products: Product[] = [];
  @Input() public wide: boolean = true;
  @Input() public sideScrollable: boolean = false;

  faShoppingCart = faShoppingCart;

  constructor() { }

  ngOnInit(): void {
  }

}
