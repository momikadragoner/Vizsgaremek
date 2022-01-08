import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { faShoppingCart } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'add-to-cart',
  templateUrl: './add-to-cart.component.html',
  styleUrls: ['./add-to-cart.component.scss']
})
export class AddToCartComponent implements OnInit {

  constructor() { }

  faShoppingCart = faShoppingCart;

  @Output() modalState = new EventEmitter<boolean>();
  rating:number = -1;

  @Input() product:any;
  @Input() recommendedProducts:any;

  solidStars(i:number){
    this.rating = i;
  }

  back($event:any){
    $event.preventDefault();
    this.modalState.emit(false);
  }

  ngOnInit(): void {
  }

}
