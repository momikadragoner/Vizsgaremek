import { Component, Input, OnInit } from '@angular/core';
import { faShoppingCart, faPlus, faTrash, faEdit, faEllipsisV, faExclamationTriangle } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'my-product-list',
  templateUrl: './my-product-list.component.html',
  styleUrls: ['./my-product-list.component.scss']
})
export class MyProductListComponent implements OnInit {

  @Input() public products = [{productName: "", sellerName: "", price: "", imgUrl: "", public: false}];

  faShoppingCart = faShoppingCart;
  faPlus = faPlus;
  faTrash = faTrash;
  faEdit = faEdit;
  faMore = faEllipsisV;
  faExclamationTriangle = faExclamationTriangle;

  constructor() { }

  ngOnInit(): void {
  }

}