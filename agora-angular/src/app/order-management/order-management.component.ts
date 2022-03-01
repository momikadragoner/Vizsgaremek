import { Component, OnInit } from '@angular/core';
import { faEdit, faHeart, faSave, faShoppingCart, faTrash, faTruck } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartService } from '../services/cart.service';

@Component({
  selector: 'app-order-management',
  templateUrl: './order-management.component.html',
  styleUrls: ['./order-management.component.scss']
})
export class OrderManagementComponent implements OnInit {

  orders:Cart[] = [];

  faTrash = faTrash;
  faEdit = faEdit;
  faSave = faSave;
  faTruck = faTruck;

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
