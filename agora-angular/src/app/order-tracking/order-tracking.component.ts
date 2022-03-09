import { Component, OnInit } from '@angular/core';
import { faCheckCircle, faCircle, faGripLinesVertical, faLongArrowAltDown, faLongArrowAltUp, faTruck } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';

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
          else if (this.orders[i].products) {
            let statuses:string[] = [];
            order.products.forEach(x=>{
              if(x.status != 'Arrived' && x.status != 'Unavailable') statuses.push(x.status);
            })
            if(statuses.every( x => x == statuses[0])) order.status = statuses[0];
          }
        }
      }
    })
  }

  ngOnInit(): void {
  }

  orderArrived(orderId:number, productId?:number){
    let cartproducts: CartProduct[] = [];
    console.log(orderId, productId);
    if (productId != undefined) {
      this.orders[orderId].products[productId].status = 'Arrived';
      cartproducts = [this.orders[orderId].products[productId]];
    }
    else if (productId == undefined) {
      this.orders[orderId].products.forEach(x => x.status = 'Arrived');
      cartproducts = this.orders[orderId].products;
    }
    this.cartService.updateCartProducts(cartproducts).subscribe({
      next: () => {

      }
    });
  }

}
