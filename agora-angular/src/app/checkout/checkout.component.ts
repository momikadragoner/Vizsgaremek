import { Component, OnInit } from '@angular/core';
import { faChevronLeft, faChevronRight, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { Address, AddressService } from '../services/address.service';
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
  address: Address = new Address();

  constructor(
    private cartService: CartService,
    private addressService: AddressService,
  ) {
    cartService.getCartProducts().subscribe({
      next: (data: [CartProduct]) => {
        this.cart.products = [...data];
        this.cart.sumPrice = 0;
        this.cart.products.forEach(product => {
          this.cart.sumPrice += (product.price * product.amount);
        });
      }
    });
    addressService.getAddress().subscribe({
      next: data => {
        this.address = { ...data[this.cart.shippingId] };
      }
    })
  }

  ngOnInit(): void {
  }

}
