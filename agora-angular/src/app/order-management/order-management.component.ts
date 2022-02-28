import { Component, OnInit } from '@angular/core';
import { faHeart, faShoppingCart, faTrash } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartService } from '../services/cart.service';

@Component({
  selector: 'app-order-management',
  templateUrl: './order-management.component.html',
  styleUrls: ['./order-management.component.scss']
})
export class OrderManagementComponent implements OnInit {

  orders:Cart[] = [];

  faShoppingCart = faShoppingCart;
  faHeart = faHeart;
  faTrash = faTrash;

  constructor(
    private cartService: CartService
  ) 
  {
    cartService.getOrders().subscribe({
      next: data => {
        this.orders = [...data];
      }
    })
  }

  ngOnInit(): void {
  }

}
