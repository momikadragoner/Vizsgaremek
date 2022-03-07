import { Component, OnInit } from '@angular/core';
import { faCheckCircle, faCircle, faGripLinesVertical, faLongArrowAltDown, faLongArrowAltUp, faTruck } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartService } from '../services/cart.service';

@Component({
  selector: 'app-order-tracking',
  templateUrl: './order-tracking.component.html',
  styleUrls: ['./order-tracking.component.scss']
})
export class OrderTrackingComponent implements OnInit {

  faTruck = faTruck;
  faLongArrowAltUp = faLongArrowAltDown;
  faCircle = faCircle;
  faCheckCircle = faCheckCircle;

  orders:Cart[] = [new Cart()];

  constructor(
    private cartService:CartService
  ) 
  { 
    cartService.getMyOrders().subscribe({
      next: data => {
        this.orders = [...data];
        for (let i = 0; i < this.orders.length; i++) {
          let order = this.orders[i];
          if (this.orders[i].products && order.products.every( x => x.status == order.products[0].status))
          {
            order.status = order.products[0].status;
          }
        }
      }
    })
  }

  ngOnInit(): void {
  }

  orderArrived(orderId:number, productId?:number){
    
  }

}
