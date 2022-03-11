import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';
import { faEdit, faEnvelope, faHeart, faSave, faShoppingCart, faSpinner, faTrash, faTruck } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';

@Component({
  selector: 'app-order-management',
  templateUrl: './order-management.component.html',
  styleUrls: ['./order-management.component.scss']
})
export class OrderManagementComponent implements OnInit {

  orders:Cart[] = [];
  fieldSetDisabled: boolean[] = [];
  isLoading: boolean[] = [];
  deleteModalOpen:boolean = false;
  selectedOrderId:number = 0;

  faTrash = faTrash;
  faEdit = faEdit;
  faSave = faSave;
  faTruck = faTruck;
  faEnvelope = faEnvelope;
  faSpinner = faSpinner;

  constructor(
    private cartService: CartService,
  )
  {
    cartService.getOrders().subscribe({
      next: data => {
        this.orders = [...data];
        for (let i = 0; i < this.orders.length; i++) {
          let order = this.orders[i];
          this.fieldSetDisabled[i] = true;
          this.isLoading[i] = false;
          if (order.products) {
            let sum:number = 0;
            order.products.forEach(x => {
              if(x.discount){
                sum += x.price * (1-(x.discount / 100));
              }
              else{
                sum += x.price;
              }
            });
            order.sumPrice = sum;
          }
          if (this.orders[i].products && order.products.every( x => x.status == order.products[0].status))
          {
            order.status = order.products[0].status;
          }
        }
      }
    })
  }

  enableEdit(id:number){
    this.fieldSetDisabled[id] =  !this.fieldSetDisabled[id];
  }

  orderStatusChange(id:number){
    if(!this.orders[id].products) return;
    let order = this.orders[id];
    if (order.status == "Unavailable") {
      this.selectedOrderId = id;
      this.deleteModalOpen = true;
      return;
    }
    order.products.forEach(product => {
      product.status = order.status;
    })
  }

  productStatusChange(orderId:number, productId:number){
    if(!this.orders[orderId].products) return;
    let order = this.orders[orderId];
    let product = order.products[productId];
    if (order.products.every( x => x.status == "Unavailable"))
    {
      this.selectedOrderId = orderId;
      this.deleteModalOpen = true;
      return;
    }
    if (order.products.every( x => x.status == product.status))
    {
      order.status = product.status;
    }
  }

  rejectOrder($event:any, id:number){
    $event.preventDefault();
    this.cartService.deleteCartOrder(this.orders[id].cartId).subscribe({
      next: () => {
        this.orders.splice(id, 1);
        this.deleteModalOpen = false;
      }
    });
  }

  back($event:any){
    $event.preventDefault();
    this.orders[this.selectedOrderId].status = "Ordered";
    this.orders[this.selectedOrderId].products.forEach(product => {
      product.status = "Ordered";
    });
    this.deleteModalOpen = false;
  }

  save($event:any, id:number){
    this.isLoading[id]= true;
    $event.preventDefault();
    let order = this.orders[id];
    this.cartService.updateCartProducts(order.products).subscribe({
      next: () => {
        this.isLoading[id] = false;
        this.fieldSetDisabled[id] = true;
      }
    });
  }

  statuses = [
    {value: "Ordered", name: "Rendelés fogadva", disabled: false },
    {value: "Packaging", name: "Összekészítés alatt", disabled: false },
    {value: "Delivery in progress", name: "Szállítás folyamatban", disabled: false },
    {value: "Unavailable", name: "Nem elérhető", disabled: false },
    {value: "Arrived", name: "Megérkezett", disabled: true }
  ]

  ngOnInit(): void {
  }

}
