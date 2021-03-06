import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { faShoppingCart, faPlus, faTrash, faEdit, faEllipsisV, faExclamationTriangle } from '@fortawesome/free-solid-svg-icons';
import { ProductShort as Product } from "../../services/product.service";

@Component({
  selector: 'my-product-list',
  templateUrl: './my-product-list.component.html',
  styleUrls: ['./my-product-list.component.scss']
})
export class MyProductListComponent implements OnInit {

  @Input() public products: Product[] = [];
  @Output() deleteClick = new EventEmitter<number>();
  @Output() moreClick = new EventEmitter<number>();

  faShoppingCart = faShoppingCart;
  faPlus = faPlus;
  faTrash = faTrash;
  faEdit = faEdit;
  faMore = faEllipsisV;
  faExclamationTriangle = faExclamationTriangle;

  constructor() { }

  ngOnInit(): void {
  }

  showMore($event:any, id:any){
    $event.preventDefault();
    this.moreClick.emit(id);
  }

  delete($event:any, id: any){
    $event.preventDefault();
    this.deleteClick.emit(id);
  }

}
