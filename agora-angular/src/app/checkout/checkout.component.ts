import { Component, OnInit } from '@angular/core';
import { faChevronLeft, faChevronRight, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';

@Component({
  selector: 'app-checkout',
  templateUrl: './checkout.component.html',
  styleUrls: ['./checkout.component.scss']
})
export class CheckoutComponent implements OnInit {

  faChevronLeft = faChevronLeft;
  faChevronRight = faChevronRight;
  faSpinner = faSpinner;

  cart: Cart = new Cart();

  constructor(
    private cartService: CartService,
  ) {
    cartService.getCart().subscribe({
      next: (data: [CartProduct]) => {
        this.cart.products = [...data];
        this.cart.sumPrice = 0;
        this.cart.products.forEach( product => {
          this.cart.sumPrice += (product.price * product.amount);
        });
      }
    });
  }

  ngOnInit(): void {
  }

}
