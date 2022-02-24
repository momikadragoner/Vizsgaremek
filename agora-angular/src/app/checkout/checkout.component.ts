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
    cartService.getCart().subscribe({
      next: (data: Cart) => {
        this.cart = {...data};
        addressService.getAddress().subscribe({
          next: data => {
            let shippingAddress:Address = new Address();
            data.forEach( address => {
              if (address.addressId = this.cart.shippingId) {
                shippingAddress = address;
              }
            })
            if (shippingAddress == new Address()) return;
            this.address = { ...shippingAddress };
          }
        })
      }
    });
  }

  ngOnInit(): void {
  }

}
