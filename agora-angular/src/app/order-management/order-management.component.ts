import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';
import { faEdit, faHeart, faSave, faShoppingCart, faTrash, faTruck } from '@fortawesome/free-solid-svg-icons';
import { Cart, CartProduct, CartService } from '../services/cart.service';

@Component({
  selector: 'app-order-management',
  templateUrl: './order-management.component.html',
  styleUrls: ['./order-management.component.scss']
})
export class OrderManagementComponent implements OnInit {

  orders:Cart[] = [];

  orderStatus: string[] = [];
  orderProductStatus:string[][] = [[]];
  fieldSetDisabled: Boolean[] = [];

  faTrash = faTrash;
  faEdit = faEdit;
  faSave = faSave;
  faTruck = faTruck;

  constructor(
    private cartService: CartService,
  ) 
  {
    cartService.getOrders().subscribe({
      next: data => {
        this.orders = [...data];
        for (let i = 0; i < data.length; i++) {
          const d = data[i];
          this.orderStatus[i] = d.status;
          this.fieldSetDisabled[i] = true;
          if (d.products){
            for (let j = 0; j < d.products.length; j++) {
              const product:CartProduct = d.products[j];
              //console.log(this.orderProductStatus[i][j]);
              //this.orderProductStatus[i][j] = product.status;
            }
          }
        }
        //console.log(this.orderProductStatus);
      }
    })
  }

  enableEdit(id:number){
    this.fieldSetDisabled[id] =  !this.fieldSetDisabled[id];
  }

  save($event:any, id:number){
    $event.preventDefault();
    let order = this.orders[id];
    order.status = this.orderStatus[id];
    
    console.log(order);

    // this.cartService.updateCart(order).subscribe({
    //   next: data => {
    //     this.enableEdit(id);
    //   }
    // });
  }

  statuses = [
    {value: "Ordered", name: "Rendelés fogadva" },
    {value: "Packaging", name: "Összekészítés alatt" },
    {value: "Delivery in progress", name: "Szállítás folyamatban" },
    {value: "Unavailable", name: "Nem elérhető" }
  ]

  ngOnInit(): void {
  }

}
