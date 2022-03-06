import { Component, Input, OnInit } from '@angular/core';
import { faShoppingCart } from '@fortawesome/free-solid-svg-icons';
import { Auth } from 'src/app/services/auth';
import { CartService } from 'src/app/services/cart.service';
import { ProductShort as Product } from 'src/app/services/product.service';

@Component({
  selector: 'product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.scss']
})
export class ProductCardComponent implements OnInit {

  @Input() public product: Product = {productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''};
  @Input() public wide: boolean =  true;
  @Input() public sideScrollable: boolean = false;

  faShoppingCart = faShoppingCart;
  currentUser: Auth = Auth.currentUser;
  
  constructor(
    private cartService: CartService
  ) {   }

  ngOnInit(): void {
  }

  addToCart($event: any, id: number) {
    $event.preventDefault();
    $event.stopPropagation();
    this.cartService.postCart(id, this.currentUser.userId)
      .subscribe({
        next: data => {
        },
      });
  }

}
