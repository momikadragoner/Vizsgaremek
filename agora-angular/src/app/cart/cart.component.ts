import { Component, OnInit } from '@angular/core';
import { Product, ProductService } from "../services/product.service";
import { faShoppingCart, faChevronRight, faTrash, faHeart } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';
import { Auth } from '../services/auth';
import { WishListService } from '../services/wishlist.service';

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
  currentUser: Auth = Auth.currentUser;

  constructor(
    private cartService: CartService,
    private productService: ProductService,
    private wishListService: WishListService
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
    //console.log(this.cart.products);
  }

  addToWishList($event: any, id: number) {
    $event.preventDefault();
    this.wishListService.postWishList(id, this.currentUser.userId)
      .subscribe({
        next: data => {}
      });
  }

  deleteFromCart($event: any, id: number){
    $event.preventDefault();
    this.cartService.deleteCart(id)
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
