import { Component, OnInit } from '@angular/core';
import { Product, ProductService } from "../services/product.service";
import { faShoppingCart, faChevronRight, faTrash, faHeart } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';
import { WishListService } from '../services/wishlist.service';
import { AuthService } from '../account-forms/services/auth.service';

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
  faShoppingCart = faShoppingCart;

  cart: Cart = new Cart();
  currentUserId = this.authService.getUserDetails()[0].member_id;

  constructor(
    private cartService: CartService,
    private productService: ProductService,
    private wishListService: WishListService,
    private authService: AuthService
  ) {
    cartService.getCartProducts().subscribe({
      next: (data: [CartProduct]) => {
        this.cart.products = [...data];
        this.cart.sumPrice = 0;
        this.cart.products.forEach( product => {
          if (product.discount) {
            this.cart.sumPrice += ((product.price * (1 - (product.discount / 100))) * product.amount);
          }
          else{
            this.cart.sumPrice += (product.price * product.amount);
          }
        });
      }
    });
  }

  addToWishList($event: any, id: number) {
    $event.preventDefault();
    this.wishListService.postWishList(id, this.currentUserId)
      .subscribe({
        next: data => {}
      });
  }

  deleteFromCart($event: any, id: number){
    $event.preventDefault();
    this.cartService.deleteCartProduct(id)
    .subscribe({
      next: data => {
        let deleteProduct: CartProduct = new CartProduct();
        this.cart.products.forEach(p => {
          if (p.cartProductId == id) {
            deleteProduct = p;
          }
        })
        console.log(deleteProduct);
        this.cart.products.splice(this.cart.products.indexOf(deleteProduct),1);
      }
    });
  }

  ngOnInit(): void {
  }

}
