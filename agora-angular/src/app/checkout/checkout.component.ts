import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
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
  modalOpen: boolean = false;

  constructor(
    private cartService: CartService,
    private addressService: AddressService,
    private router: Router,
  ) {
    cartService.getCart().subscribe({
      next: (data: Cart) => {
        this.cart = {...data};
        addressService.getAddress().subscribe({
          next: data => {
            let shippingAddress:Address = new Address();
            data.forEach( address => {
              if (address.addressId == this.cart.shippingId) {
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

  confirm($event:any){
    $event.preventDefault();
    this.cart.status = 'Ordered';
    if (this.cart != new Cart() && this.address != new Address()) {
      this.cartService.sendCart(this.cart)
      .subscribe({
        next: data => {
          this.modalOpen = true;
        }
      });
    }
  }

  ngOnInit(): void {
  }

}
