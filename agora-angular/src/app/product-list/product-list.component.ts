import { Component, Input, OnInit } from '@angular/core';
import { faChevronUp, faShoppingCart } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.scss']
})
export class ProductListComponent implements OnInit {

  @Input() public products = [{productName: "", sellerName: "", price: "", imgUrl: ""}];

  faShoppingCart = faShoppingCart;

  constructor() { }

  ngOnInit(): void {
  }

}
