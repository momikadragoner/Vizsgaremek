import { Component, OnInit } from '@angular/core';
import { Product, ProductService } from "../services/product.service";
import { faShoppingCart, faChevronRight, faTrash, faHeart } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';
import { Auth } from '../services/auth';

@Component({
  selector: 'app-cart',
  templateUrl:
    './cart.component.html',
  styleUrls: ['./cart.component.scss']
})
export class CartComponent implements OnInit {

  faChevronRight = faChevronRight;
  faTrash = faTrash;
  faHeart = faHeart;

  cart: Cart = new Cart();
  currentUser: Auth = Auth.currentUser;

  constructor(
    private cartService: CartService,
    private productService: ProductService
  ) {
    cartService.getCart().subscribe({
      next: (data: [CartProduct]) => {
        this.cart.products = [...data];
        this.cart.sumPrice = 0;
        this.cart.products.forEach( product => {
          this.cart.sumPrice += product.price;
        });
      }
    });
    console.log(this.cart.products);
  }

  addToWishList($event: any, id: number) {
    $event.preventDefault();
    this.productService.postWishList(id, this.currentUser.userId)
      .subscribe({
        next: data => {}
      });
  }

  ngOnInit(): void {
  }

}
